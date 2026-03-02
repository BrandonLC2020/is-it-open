import os
import json
import glob

def get_api_routes():
    routes = []
    # Search for api.py in apps
    api_files = glob.glob("backend/apps/*/api.py")
    for file_path in api_files:
        app_name = file_path.split("/")[-2]
        routes.append(f"### App: {app_name}")
        with open(file_path, 'r') as f:
            for line in f:
                # Look for @router.get, @router.post, etc.
                if "@router." in line and "(" in line:
                    route_info = line.strip()
                    routes.append(f"- Route: {route_info}")
                elif "def " in line and routes and routes[-1].startswith("- Route:"):
                    func_name = line.split("(")[0].replace("def ", "").strip()
                    routes.append(f"  - Function: {func_name}")
    return "
".join(routes)

context = f"""
## API Routes
{get_api_routes()}
"""

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": context
    }
}))
