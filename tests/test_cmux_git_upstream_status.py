"""Exercise actionable cmux Git status against local repositories."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


HELPER = Path(__file__).resolve().parents[1] / "config/scripts/cmux-git-upstream-status"


class CmuxGitUpstreamStatusTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.remote = self.root / "remote.git"
        self.work = self.root / "work"
        self.peer = self.root / "peer"
        self.log = self.root / "cmux.jsonl"

        subprocess.run(["git", "init", "--bare", "--initial-branch=main", self.remote],
                       check=True, capture_output=True)
        self._clone(self.work)
        self._config(self.work)
        (self.work / "file.txt").write_text("initial\n")
        self._git(self.work, "add", "file.txt")
        self._git(self.work, "commit", "-m", "initial")
        self._git(self.work, "push", "-u", "origin", "main")
        self._clone(self.peer)
        self._config(self.peer)

        fake = self.root / "cmux"
        fake.write_text(f"#!{sys.executable}\n" + """
import json, os, sys
with open(os.environ['CMUX_TEST_LOG'], 'a') as log:
    log.write(json.dumps(sys.argv[1:]) + '\\n')
""")
        fake.chmod(0o755)
        self.env = dict(os.environ,
                        PATH=f"{self.root}:{os.environ['PATH']}",
                        CMUX_WORKSPACE_ID="workspace-id",
                        CMUX_GIT_FETCH_INTERVAL="0",
                        CMUX_TEST_LOG=str(self.log),
                        XDG_CACHE_HOME=str(self.root / "cache"))

    def _clone(self, path):
        subprocess.run(["git", "clone", str(self.remote), str(path)],
                       check=True, capture_output=True)

    def _config(self, repo):
        self._git(repo, "config", "user.name", "Test")
        self._git(repo, "config", "user.email", "test@example.com")

    def _git(self, repo, *args):
        return subprocess.run(["git", "-C", str(repo), *args], check=True,
                              capture_output=True, text=True)

    def _run(self):
        self.log.unlink(missing_ok=True)
        result = subprocess.run([str(HELPER)], cwd=self.work, env=self.env,
                                capture_output=True, text=True)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()]
        return result, calls

    def test_behind_and_diverged_are_visible_but_current_is_clear(self):
        result, calls = self._run()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-1][:2], ["clear-status", "git_upstream"])

        (self.peer / "file.txt").write_text("remote\n")
        self._git(self.peer, "add", "file.txt")
        self._git(self.peer, "commit", "-m", "remote")
        self._git(self.peer, "push")
        result, calls = self._run()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-1][0:3], ["set-status", "git_upstream", "↓1 behind"])
        self.assertIn("#FAB387", calls[-1])

        (self.work / "local.txt").write_text("local\n")
        self._git(self.work, "add", "local.txt")
        self._git(self.work, "commit", "-m", "local")
        result, calls = self._run()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-1][0:3],
                         ["set-status", "git_upstream", "↑1 ↓1 diverged"])
        self.assertIn("#F38BA8", calls[-1])

    def test_missing_upstream_clears_old_status(self):
        self._git(self.work, "branch", "--unset-upstream")
        result, calls = self._run()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-1][:2], ["clear-status", "git_upstream"])


if __name__ == "__main__":
    unittest.main()
