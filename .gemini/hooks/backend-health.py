import subprocess
import json
import sys

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT).decode('utf-8')
    except Exception as e:
        return f"Error running {cmd}: {str(e)}"

# check docker ps
docker_ps = run_cmd("docker compose ps")
# check migrations (if container is up)
migrations = run_cmd("docker compose exec backend python manage.py showmigrations 2>/dev/null || echo 'Backend container not running or migrations check failed'")
# check tests collection
tests = run_cmd("docker compose exec backend pytest --collect-only 2>/dev/null || echo 'Tests collection failed'")

context = f"""
## Backend Health
### Docker Status
{docker_ps}

### Migrations
{migrations}

### Tests (Collected)
{tests}
"""

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": context
    }
}))
