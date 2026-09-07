"""Exercise workspace reuse without opening agents or changing live workspaces."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


LAUNCHER = Path(__file__).resolve().parents[1] / "config/scripts/cproj"


class ProjectReuseTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.project = self.root / "project with 'quotes'"
        self.project.mkdir()
        self.project = self.project.resolve()
        self.fixture = self.root / "fixture.json"
        self.log = self.root / "calls.jsonl"
        fake = self.root / "cmux"
        fake.write_text(f"#!{sys.executable}\n" + '''
import json, os, sys
args = [arg for arg in sys.argv[1:] if arg != '--json']
with open(os.environ['CPROJ_TEST_LOG'], 'a') as log:
    log.write(json.dumps(args) + '\\n')
data = json.load(open(os.environ['CPROJ_TEST_FIXTURE']))
if args[0] == 'tree':
    if data.get('fail'):
        print('connection failed', file=sys.stderr)
        sys.exit(1)
    print(json.dumps({'windows': [{'ref': ref} for ref in data['windows']]}))
elif args[0] == 'list-workspaces':
    window = args[args.index('--window') + 1]
    print(json.dumps({'workspaces': data['windows'][window]}))
else:
    print('OK')
''')
        fake.chmod(0o755)
        for name in ("nvim", "codex"):
            stub = self.root / name
            stub.write_text("#!/bin/sh\nexit 0\n")
            stub.chmod(0o755)
        self.env = dict(os.environ, PATH=f"{self.root}:{os.environ['PATH']}",
                        CPROJ_TEST_LOG=str(self.log), CPROJ_TEST_FIXTURE=str(self.fixture),
                        CPROJ_AGENT="codex")

    def workspace(self, **changes):
        return dict(id="saved-id", description=f"cproj:{self.project}",
                    current_directory="/somewhere/else", remote={"enabled": False},
                    has_custom_title=True, selected=False, **changes)

    def run_launcher(self, windows, *args, fail=False, project=None):
        self.fixture.write_text(json.dumps({"windows": windows, "fail": fail}))
        result = subprocess.run([str(LAUNCHER), *args, str(project or self.project)],
                                env=self.env, capture_output=True, text=True)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()]
        return result, calls

    def test_saved_identity_survives_rename_cwd_change_and_window_change(self):
        result, calls = self.run_launcher({"window:1": [], "window:2": [self.workspace()]},
                                          "--agent", "missing-agent-not-needed-for-reuse")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-2], ["select-workspace", "--workspace", "saved-id",
                                    "--window", "window:2"])
        self.assertEqual(calls[-1], ["focus-window", "--window", "window:2"])
        self.assertNotIn("new-workspace", [call[0] for call in calls])

    def test_symlink_resolves_to_same_project(self):
        alias = self.root / "alias"
        alias.symlink_to(self.project, target_is_directory=True)
        result, calls = self.run_launcher({"window:1": [self.workspace()]}, project=alias)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-1][0], "focus-window")

    def test_adopts_legacy_workspace_by_exact_directory(self):
        workspace = self.workspace()
        workspace.update(description=None, current_directory=str(self.project))
        result, calls = self.run_launcher({"window:1": [workspace]})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[2][0], "workspace-action")
        self.assertEqual(calls[2][-1], f"cproj:{self.project}")

    def test_remote_and_same_basename_elsewhere_do_not_match(self):
        remote = self.workspace()
        remote["remote"] = {"enabled": True}
        other = self.workspace()
        other.update(description=None, current_directory=f"/other/{self.project.name}")
        result, calls = self.run_launcher({"window:1": [remote, other]})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-1][0], "new-workspace")
        self.assertIn(f"cproj:{self.project}", calls[-1])

    def test_new_bypasses_reuse(self):
        result, calls = self.run_launcher({"window:1": [self.workspace()]}, "--new")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([call[0] for call in calls], ["new-workspace"])

    def test_connection_failure_does_not_create_duplicate(self):
        result, calls = self.run_launcher({}, fail=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual([call[0] for call in calls], ["tree"])


if __name__ == "__main__":
    unittest.main()
