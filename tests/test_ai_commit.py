"""Test commit drafting against disposable Git repos and a fake Codex CLI."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "config/scripts/ai-commit"


class AICommitTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo with spaces"
        self.repo.mkdir()
        self.env = dict(os.environ, PATH=f"{self.root}:{os.environ['PATH']}",
                        GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull,
                        GIT_AUTHOR_NAME="Test", GIT_AUTHOR_EMAIL="test@example.test",
                        GIT_COMMITTER_NAME="Test", GIT_COMMITTER_EMAIL="test@example.test",
                        AI_COMMIT_TEST_ROOT=str(self.root), AI_COMMIT_TEST_REPO=str(self.repo))
        # Isolate tests from whichever repo Git/lazygit is running in.
        for key in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE"):
            self.env.pop(key, None)
        self.git("init", "-q")
        fake = self.root / "codex"
        fake.write_text(f"#!{sys.executable}\n" + '''
import os, pathlib, subprocess, sys
root = pathlib.Path(os.environ['AI_COMMIT_TEST_ROOT'])
(root / 'prompt').write_text(sys.stdin.read())
if os.environ.get('TEST_FAIL'):
    sys.exit(1)
message = '' if os.environ.get('TEST_EMPTY') else 'Add sample configuration\\n'
pathlib.Path(sys.argv[sys.argv.index('--output-last-message') + 1]).write_text(message)
if os.environ.get('TEST_CHANGE_INDEX'):
    repo = pathlib.Path(os.environ['AI_COMMIT_TEST_REPO'])
    (repo / 'changed').write_text('intervening change')
    subprocess.run(['git', '-C', str(repo), 'add', 'changed'], check=True)
''')
        fake.chmod(0o755)
        editor = self.root / "editor"
        editor.write_text('#!/bin/sh\n'
                          'if [ -n "${TEST_EDITOR_MESSAGE:-}" ]; then\n'
                          '  printf "%s\\n" "$TEST_EDITOR_MESSAGE" > "$1"\n'
                          'fi\n'
                          'exit "${TEST_EDITOR_EXIT:-0}"\n')
        editor.chmod(0o755)
        self.env["VISUAL"] = str(editor)

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.repo), *args], env=self.env)

    def stage(self):
        (self.repo / "sample").write_text("staged content\n")
        self.git("add", "sample")
        (self.repo / "sample").write_text("unstaged content\n")

    def run_script(self, *args, answer="", **env):
        return subprocess.run([str(SCRIPT), *args], cwd=self.repo,
                              env=dict(self.env, **env), input=answer,
                              capture_output=True, text=True)

    def assert_no_commit(self):
        result = subprocess.run(["git", "-C", str(self.repo), "rev-parse", "--verify", "HEAD"],
                                env=self.env, capture_output=True)
        self.assertNotEqual(result.returncode, 0)

    def test_no_staged_changes_does_not_call_codex(self):
        result = self.run_script("--draft-only")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / "prompt").exists())

    def test_draft_only_uses_staged_content_and_never_commits(self):
        self.stage()
        result = self.run_script("--draft-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        prompt = (self.root / "prompt").read_text()
        self.assertIn("+staged content", prompt)
        self.assertNotIn("unstaged content", prompt)
        self.assertIn("Add sample configuration", result.stdout)
        self.assert_no_commit()

    def test_cancel_preserves_index(self):
        self.stage()
        before = self.git("write-tree")
        result = self.run_script(answer="q\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, self.git("write-tree"))
        self.assert_no_commit()

    def test_large_diff_includes_later_files_and_marks_omissions(self):
        (self.repo / "a-large.txt").write_text("large staged line\n" * 16000)
        (self.repo / "z-small.txt").write_text("important later change\n")
        self.git("add", ".")
        (self.repo / "z-small.txt").write_text("unstaged secret\n")
        result = self.run_script("--draft-only")
        self.assertEqual(result.returncode, 0, result.stderr)
        prompt = (self.root / "prompt").read_text()
        self.assertIn("STAGED FILE SUMMARY", prompt)
        self.assertIn("Further patch content for this file omitted", prompt)
        self.assertIn("+important later change", prompt)
        self.assertNotIn("unstaged secret", prompt)
        self.assertLess(len(prompt.encode()), 205000)
        self.assert_no_commit()

    def test_enter_commits_only_staged_changes(self):
        self.stage()
        result = self.run_script(answer="\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("show", "HEAD:sample"), b"staged content\n")
        self.assertEqual((self.repo / "sample").read_text(), "unstaged content\n")

    def test_edit_commits_reviewed_message_without_second_confirmation(self):
        self.stage()
        result = self.run_script(answer="e\n", TEST_EDITOR_MESSAGE="Use reviewed wording")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("log", "-1", "--format=%s").strip(), b"Use reviewed wording")

    def test_empty_or_failed_generation_never_commits(self):
        self.stage()
        for setting in ("TEST_EMPTY", "TEST_FAIL"):
            result = self.run_script(answer="yes\n", **{setting: "1"})
            self.assertNotEqual(result.returncode, 0)
            self.assert_no_commit()

    def test_editor_abort_never_commits(self):
        self.stage()
        result = self.run_script(answer="e\n", TEST_EDITOR_EXIT="1")
        self.assertNotEqual(result.returncode, 0)
        self.assert_no_commit()

    def test_intervening_staging_aborts(self):
        self.stage()
        result = self.run_script(answer="yes\n", TEST_CHANGE_INDEX="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Staged changes or HEAD changed", result.stderr)
        self.assert_no_commit()


if __name__ == "__main__":
    unittest.main()
