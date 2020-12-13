#!/usr/bin/env python

# Downloads a prebuilt tree.

# acceptable forms:
#   ctdownload project [flavor]     - download prebuilt version of project

import sys

from ctdownload_base import *
import ctvspec
import ctutils

def usage():
    print("Usage: ctdownload project [flavor]", file=sys.stderr)

argc = len(sys.argv)
if argc < 2 or argc > 3:
    print("ERROR: ctdownload takes 1 or 2 arguments", file=sys.stderr)
    usage()
    sys.exit(1)

proj = sys.argv[1]
proj = proj.lower()

if proj == "-h":
    usage()
    sys.exit()

flav = "prebuilt"
if argc > 2:
    flav = sys.argv[2]
    if not "prebuilt" in flav:
        print("The specified flavor does not contain 'prebuilt'.",
              file=sys.stderr)
        sys.exit(1)

# Figure out where the project should go.
spec = ctvspec.resolve_spec(proj, flav)
if spec == "":
    print(f"Don't where where to put {flav} {proj}!  Update your vspec for "
          f"{proj} to specify where the {flav} tree should go.",
          file=sys.stderr)
    sys.exit(1)
root = ctvspec.compute_root(proj, flav, spec)
root = ctutils.to_os_specific(root)

download_proj(proj, flav, root)
