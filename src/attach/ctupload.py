#!/usr/bin/env python3.9

# Uploads a prebuilt tree for others to use.

# acceptable forms:
#   ctupload project [flavor] [upflavor]   - zip up and upload project, with optional explicit flavor and upload flavor

import ftplib
import platform
import sys
import os
import zipfile
import tarfile
import getpass
import re
import shutil
import glob

import ctvspec
import ctquery
import ctutils

def usage():
    print("Usage: ctupload project [flavor] [upflavor]", file=sys.stderr)

tool = os.environ.get("DTOOL")
if not tool:
    print("DTOOL environment must be set to use CTtools", file=sys.stderr)
    sys.exit(1)

argc = len(sys.argv)
if argc < 2 or argc > 4:
    print("ERROR: ctupload takes 1, 2, or 3 arguments", file=sys.stderr)
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

up_flav = "prebuilt"
if argc == 3:
    # Got an explicit upload flavor.
    up_flav = sys.argv[3]
    if "prebuilt" not in up_flav:
        print("Upload flavor must contain 'prebuilt'.", file=sys.stderr)
        sys.exit(1)

# Figure out where that flavor is located.
spec = ctvspec.resolve_spec(proj, flav)
if spec == "":
    print(f"Failed to resolve flavor '{flav}' of project '{proj}'", file=sys.stderr)
    sys.exit(1)
root = ctvspec.compute_root(proj, flav, spec)
root = ctutils.to_os_specific(root)

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

cwd = os.getcwd()

is_model_tree = re.search("MODELS$", proj.upper()) is not None
# Need a better way to handle this.
python_trees = ["direct", "otp", "toontown"]
is_python_tree = proj.lower() in python_trees

# First, copy the project into a temporary location.  We need to do some
# preliminary clean up of the tree before packaging it up.
if not os.path.isdir("ctupload-tmp"):
    os.mkdir("ctupload-tmp")

tmpdir = os.path.join("ctupload-tmp", os.path.basename(root))
abs_tmpdir = os.path.abspath(tmpdir)
if os.path.isdir(tmpdir):
    shutil.rmtree(tmpdir, onerror=ctutils.remove_readonly)

# Figure out what to copy based on the tree type.  For models, we only need to
# copy the built folder.  For code trees, we need to copy the top-level .pp
# files and the built folder.  And for Python trees, we need to copy the
# top-level .pp files, the built folder, and the src folder.
copy_files = []
copy_folders = []
del_files = [os.path.join("**", "*.pyc"),
             os.path.join("**", "*.pyo")]
del_folders = [os.path.join("**", "__pycache__")]
if is_model_tree:
    copy_folders.append("built")
    # Delete the built/shadow_pal folder and all *.rgb textures, which are
    # intermediate build outputs.
    del_folders.append(os.path.join("built", "shadow_pal"))
    del_files.append(os.path.join("**", "maps", "*.rgb"))
else:
    copy_folders.append("built")
    # This folder contains the ppremake templates and only exists in DTOOL.
    copy_folders.append("pptempl")
    if is_python_tree:
        copy_files.append("__init__.py")
        copy_folders.append("src")
        # Delete these intermediate build outputs.
        del_files.append(os.path.join("src", "**", "*.vcxproj"))
        del_files.append(os.path.join("src", "**", "Makefile"))
        del_files.append(os.path.join("src", "**", "pp.dep"))
        del_folders.append(os.path.join("src", "**", "Opt?-*"))
        del_folders.append(os.path.join("src", "**", "x64"))
        del_folders.append(os.path.join("src", "**", "Win32"))
    copy_files.append("*.pp")
    # We don't want Sources.pp though, that's only needed when we are building
    # the tree.  The other .pp files, like Config.pp and Package.pp, are
    # included by dependent trees, so we keep those.
    del_files.append(os.path.join("**", "Sources.pp"))

    if proj.lower() == "wintools":
        # Append this wintools specific folder.
        copy_folders.append("panda")

for folder_name in copy_folders:
    from_path = os.path.join(root, folder_name)
    to_path = os.path.join(abs_tmpdir, folder_name)
    if os.path.isdir(from_path):
        print("cp", from_path, to_path, file=sys.stderr)
        shutil.copytree(from_path, to_path)

for file_name in copy_files:
    files = glob.glob(os.path.join(root, file_name), recursive=True)
    for file in files:
        rel = os.path.relpath(file, root)
        to_path = os.path.join(abs_tmpdir, rel)
        print("cp", file, to_path, file=sys.stderr)
        shutil.copyfile(file, to_path)

for file_name in del_files:
    files = glob.glob(os.path.join(abs_tmpdir, file_name), recursive=True)
    for file in files:
        print("rm", file, file=sys.stderr)
        os.remove(file)

for folder_name in del_folders:
    folders = glob.glob(os.path.join(abs_tmpdir, folder_name), recursive=True)
    for folder in folders:
        print("rm -rf", folder, file=sys.stderr)
        shutil.rmtree(folder, onerror=ctutils.remove_readonly)

os.chdir(abs_tmpdir)

if is_model_tree:
    archive_name = f"{proj}-{up_flav}"
    archive_type = "zip"
else:
    archive_name = f"{proj}-{up_flav}-{platform.system()}-{platform.architecture()[0]}"
    # For code trees, write a ZIP on Windows or a Tarball on Posix.
    archive_type = "zip" if os.name == "nt" else "tar"

if archive_type == "zip":
    archive_path = archive_name + ".zip"
else:
    archive_path = archive_name + ".tar.gz"

# If an existing archive is in the current directory, delete it so it doesn't
# get packed into the new archive.
if os.path.isfile(archive_path):
    os.remove(archive_path)

# Collect all the files we are adding into the archive.
archive_files = []
for root, dirs, files in os.walk(abs_tmpdir):
    for file in files:
        archive_files.append(os.path.join(os.path.relpath(root, abs_tmpdir), file))

if archive_type == "zip":
    archive_path = archive_name + ".zip"
    print(f"Compressing {abs_tmpdir} into {archive_path}", file=sys.stderr)
    archive_file = zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_LZMA)
    for file in archive_files:
        archive_file.write(file)
    archive_file.close()
elif archive_type == "tar":
    archive_path = archive_name + ".tar.gz"
    print(f"Compressing {abs_tmpdir} into {archive_path}", file=sys.stderr)
    archive_file = tarfile.open(archive_path, "w:gz")
    for file in archive_files:
        archive_file.add(file)
    archive_file.close()
else:
    print("Unknown archive type", archive_type, file=sys.stderr)

print(f"Wrote {os.path.abspath(archive_path)}", file=sys.stderr)

ftp = ctutils.ftp_connect()
if not ftp:
    sys.exit(1)

curr_version = 0
def get_ver_line(line):
    global curr_version
    if len(line) > 0 and not line.isspace():
        curr_version = int(line)

# Retrieve the current tree version.  If we can, increment the version and
# store it back on the server.  Otherwise, store a version 1 for the tree.
try:
    ftp.retrlines(f"RETR {archive_name}.ver", callback=get_ver_line)
    print("Current version is", curr_version, file=sys.stderr)
except:
    print(f"Don't have an existing version for {proj}", file=sys.stderr)

# Now store our new version back on the server.
new_version = curr_version + 1
print("Writing version", new_version, file=sys.stderr)
ver_file = open(f"{archive_name}.ver", "w")
ver_file.write(str(new_version))
ver_file.close()

with open(f"{archive_name}.ver", "rb") as ver_file:
    print(f"Uploading to {ftp.pwd()}/{archive_name}.ver...", file=sys.stderr)
    ftp.storlines(f"STOR {archive_name}.ver", ver_file)
    print("Done.", file=sys.stderr)

with open(archive_path, 'rb') as archive_file:
    print(f"Uploading to {ftp.pwd()}/{archive_path}...", file=sys.stderr)
    ftp.storbinary(f"STOR {archive_path}", archive_file)
    print("Done.", file=sys.stderr)

os.chdir(cwd)
shutil.rmtree("ctupload-tmp", onerror=ctutils.remove_readonly)
