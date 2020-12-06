#!/usr/bin/env python3.8

# Uploads a prebuilt tree for others to use.

# acceptable forms:
#   ctupload project         - zip up and upload project

import ftplib
import platform
import sys
import os
import zipfile
import tarfile

import ctvspec
import ctquery

def usage():
    print("Usage: ctupload project [flavor]", file=sys.stderr)

tool = os.environ.get("DTOOL")
if not tool:
    print("DTOOL environment must be set to use CTtools", file=sys.stderr)
    sys.exit(1)

argc = len(sys.argv)
if argc < 2 or argc > 3:
    print("ERROR: ctupload takes either 1 or 2 arguments", file=sys.stderr)
    usage()
    sys.exit(1)

proj = sys.argv[1]
if proj == "-h":
    usage()
    sys.exit()

if argc == 2:
    # Didn't get a flavor.  If we're attached to the project, use the currently
    # attached flavor.  If we're not attached, use the CTDEFAULT_FLAV
    # environment variable.
    flav = ctquery.query_proj(proj)
    if flav == "":
        flav = os.environ.get("CTDEFAULT_FLAV", "")
        if flav == "":
            print(f"Flavor of {proj} to upload could not be determined.  "
                  f"Either explicitly specify a flavor, attach to {proj} "
                   "with the desired flavor, or set the 'CTDEFAULT_FLAV' "
                   "environment variable.", file=sys.stderr)
            sys.exit(1)
else:
    # We got an explicit flavor.
    flav = sys.argv[2]

# Figure out where that flavor is located.
spec = ctvspec.resolve_spec(proj, flav)
if spec == "":
    print(f"Failed to resolve flavor '{flav}' of project '{proj}'", file=sys.stderr)
    sys.exit(1)
root = ctvspec.compute_root(proj, flav, spec)

# Make sure the root actually exists.
if not os.path.isdir(root):
    print(f"{root} does not exist!", file=sys.stderr)
    sys.exit(1)

built_dir = os.path.join(root, "built")
# Make sure that the project is built.
if not os.path.isdir(built_dir):
    print(f"{proj} is not built! ({built_dir} does not exist)", file=sys.stderr)
    sys.exit(1)

# Okay, we're ready to upload the project.

# First, compress it into a archive file.

archive_name = f"{proj}-{platform.system()}"

if os.name == "nt":
    # Write a ZIP file on Windows.
    archive_path = archive_name + ".zip"
    archive_file = zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_LZMA)
    # Throw the whole thing in there.
    archive_file.write(root)
    archive_file.close()
else:
    # Write a tarball on Posix systems.
    archive_path = archive_name + ".tar.gz"
    archive_file = tarfile.open(archive_path, "w:gz")
    # Throw the whole thing in there.
    archive_file.add(root)
    archive_file.close()

print(f"Wrote {os.path.abspath(archive_path)}")

# Get the username and password to log into the FTP server from the user.
username = input("FTP Username: ")
password = input("FTP Password: ")

# Now log into the FTP server and upload the file.
ftp = ftplib.FTP("127.0.0.1:21")
print(ftp.login(username, password))
ftp.cwd("player")

with open(archive_path, 'rb') as archive_file:
    print(f"Uploading to {ftp.pwd()}/{archive_path}...")
    ftp.storbinary(f"STOR {archive_path}", archive_file)
    print("Done.")

os.remove(archive_path)
