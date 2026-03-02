import subprocess
import json
import os

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT).decode('utf-8')
    except Exception as e:
        return f"Error: {str(e)}"

flutter_v = run_cmd("flutter --version | head -n 3")
pubspec_path = "frontend/pubspec.yaml"
dependencies = "pubspec.yaml not found"
if os.path.exists(pubspec_path):
    with open(pubspec_path, 'r') as f:
        # Just extract dependencies section
        lines = f.readlines()
        capture = False
        deps_list = []
        for line in lines:
            if line.startswith("dependencies:"):
                capture = True
                continue
            if capture and line.startswith("  "):
                deps_list.append(line.strip())
            elif capture and line.strip() != "" and not line.startswith("  "):
                break
        dependencies = "
".join(deps_list)

context = f"""
## Flutter Environment
### Flutter Version
{flutter_v}

### Flutter Dependencies
{dependencies}
"""

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": context
    }
}))
