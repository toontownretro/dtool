import ftplib
import platform
import zipfile
import tarfile
import shutil
import os
import sys
import re

import ctutils

def get_proj_archive_name(proj, flav):
    proj = proj.lower()
    flav = flav.lower()

    if re.search("MODELS$", proj.upper()):
        # Model trees are platform independent.
        return f"{proj}-{flav}"
    else:
        return f"{proj}-{flav}-{platform.system()}-{platform.architecture()[0]}"

def query_my_proj_version(proj, flav, root):
    proj = proj.lower()

    # Get my version.
    ver_filename = os.path.join(root, f"{proj}.ver")
    if not os.path.isfile(ver_filename):
        print(f"Project {proj} ({flav}) does not have a .ver file.  It's "
               "probably not a prebuilt tree.", file=sys.stderr)
        return 0

    ver_file = open(ver_filename, 'r')
    my_version_str = ver_file.readline()
    ver_file.close()
    my_version_str = my_version_str.replace("\n", "")
    my_version_str = my_version_str.replace("\r", "")
    if not my_version_str.isalnum():
        print(f"{proj}-{flav}.ver contains invalid version string.", file=sys.stderr)
        return 0

    return int(my_version_str)

def query_ftp_proj_version(proj, flav):
    # Get the server's version.
    ftp = ctutils.ftp_connect()
    if not ftp:
        print(f"Failed to check for updates to {proj}-{flav}", file=sys.stderr)
        return 0

    server_version = 0
    def read_ver_line(line):
        nonlocal server_version
        if len(line) > 0 and not line.isspace():
            server_version = int(line)

    try:
        ftp.retrlines(f"RETR {get_proj_archive_name(proj, flav)}.ver", read_ver_line)
    except Exception as e:
        print(f"Failed to get server version for {proj}-{flav}", file=sys.stderr)
        return 0

    ftp.close()

    return server_version

# Checks to see if the given project is out of date with respect to the
# prebuilt tree on the FTP server.
def update_check(proj, flav, root):
    my_version = query_my_proj_version(proj, flav, root)
    server_version = query_ftp_proj_version(proj, flav)
    return [my_version != server_version, my_version, server_version]

# Downloads the given prebuilt project and flavor and installs it into the
# directory specified by root.
def download_proj(proj, flav, root):
    ftp = ctutils.ftp_connect()
    if not ftp:
        print(f"Couldn't download project {proj} ({flav}).", file=sys.stderr)
        return False

    print(f"Prebuilt {proj} will be extracted to {root}", file=sys.stderr)

    if not os.path.isdir(root):
        os.makedirs(root)

    cwd = os.getcwd()
    os.chdir(root)

    # Clean all existing stuff in the project folder.
    file_list = os.listdir(root)
    for file in file_list:
        if os.path.isfile(file):
            os.remove(file)
        elif os.path.isdir(file):
            shutil.rmtree(file, onerror=ctutils.remove_readonly)

    archive_name = get_proj_archive_name(proj, flav)

    is_model_tree = re.search("MODELS$", proj.upper()) is not None
    if is_model_tree:
        archive_type = "zip"
    else:
        archive_type = "zip" if os.name == "nt" else "tar"

    if archive_type == "zip":
        archive_filename = archive_name + ".zip"
    elif archive_type == "tar":
        archive_filename = archive_name + ".tar.gz"

    print(f"Downloading {archive_filename} into {os.path.abspath(archive_filename)}...", file=sys.stderr)

    archive_file = open(archive_filename, "wb")
    def get_archive_block(block):
        archive_file.write(block)

    try:
        ftp.retrbinary(f"RETR {archive_filename}", get_archive_block)
        archive_file.close()
    except Exception as e:
        print(f"Failed to download {archive_filename}! ({e})", file=sys.stderr)
        archive_file.close()
        os.remove(archive_filename)
        return False

    print(f"Extracting {archive_filename}...", file=sys.stderr)
    if archive_type == "zip":
        zip_file = zipfile.ZipFile(archive_filename, "r", zipfile.ZIP_LZMA)
        zip_file.extractall()
        zip_file.close()
    elif archive_type == "tar":
        tar_file = tarfile.open(archive_filename, "r:gz")
        tar_file.extractall()
        tar_file.close()

    print("Done.", file=sys.stderr)

    os.remove(archive_filename)

    # Now download the version file so we can know when to update.
    print(f"Downloading {archive_name}.ver into {proj}.ver", file=sys.stderr)
    ver_file = open(f"{proj}.ver", "w")
    def get_ver_line(line):
        ver_file.write(line)
    try:
        ftp.retrlines(f"RETR {archive_name}.ver", get_ver_line)
        ver_file.close()
    except Exception as e:
        print(f"Failed to download {archive_name}.ver! ({e})", file=sys.stderr)
        # Write 0 so we always need an update.
        ver_file.write("0")
        ver_file.close()
        os.remove(ver_file)

    print("Done.", file=sys.stderr)

    os.chdir(cwd)

    return True

# Checks if the given project is out of date with respect to the prebuilt tree
# on the FTP server.  If it is out of date, asks the user if they would like to
# update.  If they say yes, downloads the project.
def update_check_and_ask_download(proj, flav, root):
    needs_update, my_version, server_version = update_check(proj, flav, root)
    if needs_update and server_version != 0:
        print(f"Project {proj} ({flav}) is out of date.  Local version is "
              f"{my_version}, latest version is {server_version}.", file=sys.stderr)
        ans = ""
        while ans not in ["y", "n"]:
            print("Would you like to update? [y/n]: ", end="", file=sys.stderr)
            ans = input().lower()
        if ans == "y":
            download_proj(proj, flav, root)
    else:
        print(f"{proj} ({flav}) up to date.", file=sys.stderr)
