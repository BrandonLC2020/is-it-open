import os
import json
import glob

def get_schema_summary():
    summary = []
    # Search for models.py in apps
    model_files = glob.glob("backend/apps/*/models.py")
    for file_path in model_files:
        app_name = file_path.split("/")[-2]
        summary.append(f"### App: {app_name}")
        with open(file_path, 'r') as f:
            for line in f:
                if line.startswith("class ") and "(models.Model)" in line:
                    model_name = line.split("(")[0].replace("class ", "").strip()
                    summary.append(f"- Model: {model_name}")
                elif " = models." in line:
                    field_name = line.split("=")[0].strip()
                    summary.append(f"  - {field_name}")
    return "
".join(summary)

context = f"""
## DB Schema Summary
{get_schema_summary()}
"""

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": context
    }
}))
