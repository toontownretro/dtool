import os
from pathlib import Path

# Determine the location of the where our .vspec files are stored.
ctvspec_path = os.environ.get("CTVSPEC_PATH")
if not ctvspec_path:
    # The environment did not tell us, pick a default.
    ctvspec_path = os.path.expanduser("~/player/vspec")
ctvspec_path = Path(ctvspec_path)

# Returns the environment path separator.  This returns ";" on Windows and ":"
# on anything else.
def get_env_sep():
    if os.name == 'nt':
        return ";"
    else:
        return ":"

# Expands the environment variable references in the given string.
def shell_eval(data):
    return os.path.expandvars(data)