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
        self.root = Path(self.temp.name).resolve()
        self.project = self.root / "project with 'quotes'"
        self.project.mkdir()
        self.project = self.project.resolve()
        self.fixture = self.root / "fixture.json"
        self.log = self.root / "calls.jsonl"
        fake = self.root / "cmux"
        fake.write_text(f"#!{sys.executable}\n" + '''
import json, os, sys, pathlib
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
elif args[:2] == ['workspace', 'create']:
    data.setdefault('windows', {}).setdefault('window:1', []).append({
        'id': 'new-id', 'ref': 'workspace:new',
        'description': args[args.index('--description') + 1]})
    pathlib.Path(os.environ['CPROJ_TEST_FIXTURE']).write_text(json.dumps(data))
    print(json.dumps({'workspace_ref': 'workspace:new', 'window_ref': 'window:1'}))
elif args[:2] == ['workspace-group', 'list']:
    print(json.dumps({'groups': data.get('groups', [])}))
elif args[:2] == ['workspace-group', 'create']:
    group = {'ref': 'workspace_group:1', 'name': args[args.index('--name') + 1],
             'anchor_workspace_ref': 'workspace:anchor', 'member_workspace_refs': ['workspace:new']}
    data['groups'] = [group]
    pathlib.Path(os.environ['CPROJ_TEST_FIXTURE']).write_text(json.dumps(data))
    print(json.dumps({'group': group}))
else:
    print('OK')
''')
        fake.chmod(0o755)
        for name in ("nvim", "codex"):
            stub = self.root / name
            stub.write_text("#!/bin/sh\nexit 0\n")
            stub.chmod(0o755)
        self.config = self.root / 'private-cproj.json'
        self.config.write_text(json.dumps({'groups': [
            {'path': '~/Developer/work', 'name': 'Work', 'color': '#fab387'},
            {'path': '~/Developer/product', 'name': 'Product', 'color': '#89b4fa'}]}))
        self.env = dict(os.environ, PATH=f"{self.root}:{os.environ['PATH']}",
                        CPROJ_TEST_LOG=str(self.log), CPROJ_TEST_FIXTURE=str(self.fixture),
                        CPROJ_CONFIG=str(self.config), CPROJ_AGENT="codex", HOME=str(self.root), XDG_STATE_HOME=str(self.root / "state"))

    def workspace(self, **changes):
        return dict(id="saved-id", description=f"cproj:{self.project}",
                    current_directory="/somewhere/else", remote={"enabled": False},
                    has_custom_title=True, selected=False, **changes)

    def run_launcher(self, windows, *args, fail=False, project=None):
        self.fixture.write_text(json.dumps({"windows": windows, "fail": fail}))
        result = subprocess.run([str(LAUNCHER), *args, str(project or self.project)],
                                env=self.env, capture_output=True, text=True)
        calls = ([json.loads(line) for line in self.log.read_text().splitlines()]
                 if self.log.exists() else [])
        return result, calls

    def test_saved_identity_survives_rename_cwd_change_and_window_change(self):
        result, calls = self.run_launcher({"window:1": [], "window:2": [self.workspace()]},
                                          "--agent", "missing-agent-not-needed-for-reuse")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-2], ["select-workspace", "--workspace", "saved-id",
                                    "--window", "window:2"])
        self.assertEqual(calls[-1], ["focus-window", "--window", "window:2"])
        self.assertFalse(any(c[:2] == ["workspace", "create"] for c in calls))

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
        self.assertEqual(calls[2][-1], f"⌘ {self.project.name}")

    def test_remote_and_same_basename_elsewhere_do_not_match(self):
        remote = self.workspace()
        remote["remote"] = {"enabled": True}
        other = self.workspace()
        other.update(description=None, current_directory=f"/other/{self.project.name}")
        result, calls = self.run_launcher({"window:1": [remote, other]})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(any(c[:2] == ["workspace", "create"] for c in calls))
        self.assertEqual(calls[-1][0], "select-workspace")

    def test_new_bypasses_reuse(self):
        result, calls = self.run_launcher({"window:1": [self.workspace()]}, "--new")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("tree", [call[0] for call in calls])
        self.assertEqual(calls[0][:2], ["workspace", "create"])

    def test_local_identity_preserves_custom_description_after_directory_change(self):
        state = self.root / 'state/cproj/workspaces'
        state.mkdir(parents=True)
        (state / 'saved-id.json').write_text(json.dumps({'id': 'saved-id', 'project': str(self.project)}))
        workspace = self.workspace()
        workspace['description'] = 'Release checklist'
        result, calls = self.run_launcher({'window:1': [workspace]})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any(c[:2] == ['workspace', 'create'] for c in calls))
        self.assertFalse(any('clear-description' in c or 'set-description' in c for c in calls))

    def test_sync_groups_known_roots_and_keeps_non_cproj_descriptions(self):
        self.project = self.root / 'Developer/work/sample'
        self.project.mkdir(parents=True)
        workspace = self.workspace()
        workspace.update(description='Useful note', current_directory=str(self.project))
        result, calls = self.run_launcher({'window:1': [workspace]}, '--sync-sidebar')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(any(c[:2] == ['workspace-group', 'create'] for c in calls))
        self.assertFalse(any('set-description' in c for c in calls))
        self.assertFalse((self.root / 'state/cproj/workspaces/saved-id.json').exists())

    def test_migration_saves_identity_before_replacing_description(self):
        result, calls = self.run_launcher({'window:1': [self.workspace()]})
        self.assertEqual(result.returncode, 0, result.stderr)
        state = json.loads((self.root / 'state/cproj/workspaces/saved-id.json').read_text())
        self.assertEqual(state['project'], str(self.project))
        self.assertTrue(any(f'⌘ {self.project.name}' in c for c in calls))
        self.assertTrue(any('clear-description' in c for c in calls))

    def test_symbol_moves_to_title_without_duplicate_prefix(self):
        state = self.root / 'state/cproj/workspaces'
        state.mkdir(parents=True)
        (state / 'saved-id.json').write_text(json.dumps({'id': 'saved-id', 'project': str(self.project)}))
        workspace = self.workspace()
        workspace.update(description='⌘', custom_title='⌘ My project')
        result, calls = self.run_launcher({'window:1': [workspace]})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(any('clear-description' in c for c in calls))
        self.assertFalse(any('rename' in c for c in calls))

    def test_missing_private_config_leaves_project_ungrouped(self):
        self.config.unlink()
        result, calls = self.run_launcher({}, '--new')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any(c[0] == 'workspace-group' for c in calls))

    def test_private_agent_setting_is_used(self):
        self.config.write_text(json.dumps({'agent': 'codex resume --last'}))
        self.env.pop('CPROJ_AGENT')
        result, calls = self.run_launcher({}, '--new')
        self.assertEqual(result.returncode, 0, result.stderr)
        creation = next(c for c in calls if c[:2] == ['workspace', 'create'])
        layout = json.loads(creation[creation.index('--layout') + 1])
        self.assertIn('codex resume --last', layout['children'][0]['pane']['surfaces'][0]['command'])

    def test_resume_uses_private_resume_agent(self):
        self.config.write_text(json.dumps({'agent': 'codex', 'resumeAgent': 'codex resume --last'}))
        result, calls = self.run_launcher({}, '--new', '--resume')
        self.assertEqual(result.returncode, 0, result.stderr)
        creation = next(c for c in calls if c[:2] == ['workspace', 'create'])
        layout = json.loads(creation[creation.index('--layout') + 1])
        self.assertIn('codex resume --last', layout['children'][0]['pane']['surfaces'][0]['command'])

    def test_resume_and_agent_are_mutually_exclusive(self):
        result, calls = self.run_launcher({}, '--new', '--resume', '--agent', 'codex')
        self.assertEqual(result.returncode, 2)
        self.assertIn('cannot be combined', result.stderr)
        self.assertEqual(calls, [])

    def test_sibling_prefix_does_not_match_group(self):
        self.project = self.root / 'Developer/work-other/sample'
        self.project.mkdir(parents=True)
        result, calls = self.run_launcher({}, '--new')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(any(c[0] == 'workspace-group' for c in calls))

    def test_private_layout_expands_commands_and_preserves_names(self):
        self.config.write_text(json.dumps({'layout': {'direction':'vertical', 'split':0.75,
            'children':[{'pane':{'surfaces':[{'name':'Agent','command':'{{agent}}'}]}},
                        {'pane':{'surfaces':[{'name':'Git','command':'{{git}}'},
                                             {'name':'Logs','command':'{{shell}}'}]}}]}}))
        result, calls = self.run_launcher({}, '--new')
        self.assertEqual(result.returncode, 0, result.stderr)
        creation = next(c for c in calls if c[:2] == ['workspace','create'])
        layout = json.loads(creation[creation.index('--layout')+1])
        self.assertEqual(layout['split'], 0.75)
        git, logs = layout['children'][1]['pane']['surfaces']
        self.assertEqual(git['name'], 'Git')
        self.assertTrue(git['command'].endswith('&& lazygit'))
        self.assertNotIn('{{', json.dumps(layout))
        self.assertNotIn('lazygit', logs['command'])

    def test_new_grouped_project_is_placed_after_anchor(self):
        self.project = self.root / 'Developer/product/example'
        self.project.mkdir(parents=True)
        result, calls = self.run_launcher({}, '--new')
        self.assertEqual(result.returncode, 0, result.stderr)
        reorder = next(c for c in calls if c[0] == 'reorder-workspace')
        self.assertEqual(reorder[-2:], ['--after', 'workspace:anchor'])

    def test_connection_failure_does_not_create_duplicate(self):
        result, calls = self.run_launcher({}, fail=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual([call[0] for call in calls], ["tree"])

    def test_agent_arguments_are_passed_literally(self):
        capture = self.root / 'agent-args.json'
        (self.root / 'codex').write_text(f'#!{sys.executable}\n' +
            'import json, sys\n' +
            f'open({str(capture)!r}, "w").write(json.dumps(sys.argv[1:]))\n')
        arguments = ['resume', '--last', 'session with spaces', '$(touch BAD); echo oops']
        command = '''codex resume --last "session with spaces" '$(touch BAD); echo oops' '''
        result, calls = self.run_launcher({}, '--new', '--agent', command)
        self.assertEqual(result.returncode, 0, result.stderr)
        creation = next(c for c in calls if c[:2] == ['workspace', 'create'])
        layout = json.loads(creation[creation.index('--layout') + 1])
        launch = layout['children'][0]['pane']['surfaces'][0]['command']
        executed = subprocess.run(['zsh', '-c', launch], env=self.env, capture_output=True)
        self.assertEqual(executed.returncode, 0, executed.stderr)
        self.assertEqual(json.loads(capture.read_text()), arguments)
        self.assertFalse((self.project / 'BAD').exists())


if __name__ == "__main__":
    unittest.main()
