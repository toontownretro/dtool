import os
import stat
import ftplib
import re
import sys
import getpass
from pathlib import Path

hosts_prefix = "/hosts/"

shell_type = os.environ.get("SHELL", "")
if shell_type == "" and os.name == "nt":
    shell_type = "bat"
else:
    splitlist = shell_type.split("/")
    shell_type = splitlist[len(splitlist) - 1]

# This evaluates to True if we are running Python within a Cygwin terminal.
is_cygwin = (shell_type != "bat") and (os.name == "nt")
# Are we running inside Windows cmd?
is_cmd = (shell_type == "bat") and (os.name == "nt")

def posix_to_win32(path):
    if len(path) == 0:
        return path

    if path[0] != "/":
        # Don't start with slash, just flip the slashes.
        windows_pathname = path.replace("/", "\\")

    elif len(path) >= 2 and path[1].isalpha() and (len(path) == 2 or path[2] == "/"):
        # Begins with slash and a single letter, that must be the drive letter.

        remainder = path[2:]
        if len(remainder) == 0:
            remainder = "/"
        remainder = remainder.replace("/", "\\")
        windows_pathname = path[1].upper() + ":" + remainder

    elif len(path) > len(hosts_prefix) and path[0, len(hosts_prefix)] == hosts_prefix:
        windows_pathname = "\\" + path[len(hosts_prefix):].replace("/", "\\")

    else:
        # Starts with slash, but the first part is not a single letter.
        # Just prefix C:\.
        windows_pathname = "C:\\" + path[1:].replace("/", "\\")

    return windows_pathname

def win32_to_posix(path):
    if len(path) == 0:
        return path

    result = path.replace("\\", "/")

    if len(result) >= 3 and result[0].isalpha() and result[1] == ":" and result[2] == "/":
        result = result[0:1] + result[0].lower() + result[2:]
        result = "/" + result[1:]

        # If there's just a slash following the drive letter, trim it.
        if len(result) == 3:
            result = result[0:2]
        if is_cygwin:
            result = "/cygdrive" + result
    elif result[0:2] == "//":
        # If the initial prefix is a double slash, convert it to /hosts/
        result = hosts_prefix + result[2:]

    return result

def to_os_specific(path, cyg2win=True):
    if is_cmd or (is_cygwin and cyg2win):
        return posix_to_win32(path)
    else:
        return win32_to_posix(path)

def from_os_specific(path):
    if is_cmd or is_cygwin:
        return win32_to_posix(path)
    else:
        return path

# Determine the location of the where our .vspec files are stored.
ctvspec_path = os.environ.get("CTVSPEC_PATH")
if not ctvspec_path:
    # The environment did not tell us, pick a default.
    home = os.environ.get("HOME", None)
    if home:
        ctvspec_path = home + "/player/vspec"
    else:
        # Must be running under Windows CMD.
        ctvspec_path = os.path.expanduser("~/player/vspec")
ctvspec_path = Path(ctvspec_path)

ftp_address = "127.0.0.1"

ftp_username = None
def get_ftp_username():
    global ftp_username

    if not ftp_username:
        if "CTFTP_USERNAME" in os.environ:
            print("Using FTP username from CTFTP_USERNAME", file=sys.stderr)
            ftp_username = os.environ["CTFTP_USERNAME"]
        else:
            print("FTP Username: ", end="", file=sys.stderr)
            ftp_username = input()

    return ftp_username

ftp_password = None
def get_ftp_password():
    global ftp_password

    if not ftp_password:
        if "CTFTP_PASSWORD" in os.environ:
            print("Using FTP password from CTFTP_PASSWORD", file=sys.stderr)
            ftp_password = os.environ["CTFTP_PASSWORD"]
        else:
            ftp_password = getpass.getpass("FTP Password: ")

    return ftp_password

def ftp_connect():
    usr = get_ftp_username()
    pwd = get_ftp_password()
    try:
        ftp = ftplib.FTP(ftp_address, usr, pwd)
        ftp.cwd("player")
        return ftp
    except Exception as e:
        print(f"Failed to connect to FTP server at {ftp_address} ({e})", file=sys.stderr)
        return None

def remove_readonly(func, path, excinfo):
    os.chmod(path, stat.S_IWRITE)
    func(path)

# Returns the environment path separator.  This returns ";" on Windows and ":"
# on anything else.
def get_env_sep(cyg2win=True):
    if is_cmd or (is_cygwin and cyg2win):
        return ";"
    else:
        return ":"

# Expands the environment variable references in the given string.
def shell_eval(data):
    return os.path.expandvars(data)
