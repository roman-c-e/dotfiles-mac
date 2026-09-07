"""Exercise installation without touching the user's home directory."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallConfigTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'checkout with spaces'
        self.home = self.root / 'home'
        self.home.mkdir()
        (self.repo / 'config/zsh').mkdir(parents=True)
        (self.repo / 'config/zsh/zshrc').write_text('managed shell\n')
        (self.repo / 'config-links.txt').write_text('zsh/zshrc\n')
        shutil.copy2(ROOT / 'install-config.sh', self.repo)

    def run_installer(self, *args):
        result = subprocess.run(['zsh', str(self.repo / 'install-config.sh'), *args],
                                cwd=self.root, env=dict(os.environ, HOME=str(self.home)),
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def test_fresh_install_and_repeat(self):
        self.run_installer()
        self.assertTrue((self.home / '.config/zsh/zshrc').is_symlink())
        self.assertEqual((self.home / '.zshrc').read_text(), 'managed shell\n')
        self.run_installer()
        self.assertFalse((self.home / '.local/state/dotfiles/backups').exists())

    def test_legacy_link_preserves_state_and_source(self):
        (self.repo / 'config/local-state').write_text('keep me')
        (self.home / '.config').symlink_to(self.repo / 'config')
        self.run_installer()
        self.assertFalse((self.home / '.config').is_symlink())
        self.assertEqual((self.home / '.config/local-state').read_text(), 'keep me')
        (self.home / '.config/local-state').write_text('new state')
        self.assertEqual((self.repo / 'config/local-state').read_text(), 'keep me')
        self.assertTrue((self.home / '.config/zsh/zshrc').is_symlink())
        backups = list((self.home / '.local/state/dotfiles/backups').glob('install.*'))
        self.assertTrue((backups[0] / '1/.config').is_symlink())
        self.assertFalse((self.repo / 'config/zsh/zshrc').is_symlink())
        self.assertEqual((backups[0] / '2/.config/zsh/zshrc').read_text(), 'managed shell\n')

    def test_existing_file_backed_up_and_other_files_preserved(self):
        (self.home / '.config/zsh').mkdir(parents=True)
        (self.home / '.config/zsh/zshrc').write_text('old config')
        (self.home / '.config/zsh/local').write_text('local')
        self.run_installer()
        backups = list((self.home / '.local/state/dotfiles/backups').glob('install.*'))
        self.assertEqual((backups[0] / '1/.config/zsh/zshrc').read_text(), 'old config')
        self.assertEqual((self.home / '.config/zsh/local').read_text(), 'local')

    def test_nested_directory_link_detached(self):
        (self.home / '.config').mkdir()
        (self.home / '.config/zsh').symlink_to(self.repo / 'config/zsh')
        self.run_installer()
        self.assertFalse((self.home / '.config/zsh').is_symlink())
        self.assertFalse((self.repo / 'config/zsh/zshrc').is_symlink())

    def test_dry_run_leaves_legacy_link_untouched(self):
        (self.home / '.config').symlink_to(self.repo / 'config')
        self.run_installer('--dry-run')
        self.assertTrue((self.home / '.config').is_symlink())
        self.assertFalse((self.home / '.zshrc').exists())
        self.assertFalse((self.home / '.local').exists())


if __name__ == '__main__':
    unittest.main()
