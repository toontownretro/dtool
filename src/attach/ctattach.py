#!/usr/bin/env python

# Attaches your environment to the given project.

# acceptable forms:
#   ctattach                     - give usage message
#   ctattach project             - attach to the personal flavor of the project
#   ctattach project flavor      - attach to a specific flavor of the project
#   ctattach -                   - list projects that can be attached to
#   ctattach project -           - list flavors of a given project
#   ctattach - flavor            - list projects with a certain flavor
#   ctattach -def project flavor - attach to project, setting CTDEFAULT_FLAV
#                                  to flavor for the scope of this attach

import sys
import os
import tempfile
from pathlib import Path

import ctvspec
import ctquery
import ctutils
from ctattach_base import *
import ctattach_base

tmpname = str(Path(tempfile.gettempdir()) / f"script.{os.getpid()}.{ctutils.shell_type}")

def usage():
    print("Usage: ctattach -def project flavor  -or-", file=sys.stderr)
    print("       ctattach project [flavor]     -or-", file=sys.stderr)
    print("       ctattach project -            -or-", file=sys.stderr)
    print("       ctattach - [flavor]", file=sys.stderr)
    attach_write_null_script(tmpname)
    sys.exit()

tool = os.environ.get("DTOOL")
if not tool:
    print("DTOOL environment must be set to use CTtools", file=sys.stderr)
    attach_write_null_script(tmpname)
    sys.exit()

argc = len(sys.argv)

if argc <= 1:
    usage()

idx = 1
proj = ""
flav = ""
noflav = 0
spread = 0
anydef = 0

#
# parse arguments
#

if sys.argv[idx] == "-def":
    if argc < (idx + 2):
        usage()
    ctattach_base.defflav = sys.argv[idx + 2]
    spread = 1
    idx += 1
else:
    environ_defflav = os.environ.get("CTDEFAULT_FLAV")
    if environ_defflav:
        ctattach_base.defflav = environ_defflav

proj = sys.argv[idx]

if ctattach_base.defflav == "":
    ctattach_base.defflav = "default"

if argc > idx + 1:
    flav = sys.argv[idx + 1]
else:
    if proj != "-":
        flav = ctattach_base.defflav
        noflav = 1

if (noflav == 1) or (flav == "default"):
    anydef = 1

#
# act on the arguments we got
#

if (proj == "-") or (flav == "-"):
    if argc == 2:
        # List projects that can be attached to
        print("Projects that can be attached to:", file=sys.stderr)
        projects = ctvspec.list_all_projects()
        for project in projects:
            print("   " + project)
    elif proj == "-":
        # List projects that have a given flavor
        print("Projects that have a '%s' flavor:" % flav, file=sys.stderr)
        projects = ctvspec.list_all_projects()
        for project in projects:
            tmp = ctvspec.resolve_spec(project, flav)
            if tmp:
                print("   " + project)
    else:
        # List flavors of a given project
        print("Flavors of project '%s':" % proj, file=sys.stderr)
        flavlist = ctvspec.list_all_flavors(proj)
        for item in flavlist:
            print("   " + item, file=sys.stderr)
    attach_write_null_script(tmpname)
else:
    # Output a real attachment.
    curflav = ctquery.query_proj(proj)
    if (curflav == "") or (noflav == 0):
        spec = attach_compute(proj, flav, anydef)
        if spec == "":
            attach_write_null_script(tmpname)
        else:
            attach_write_script(tmpname)
    else:
        attach_write_null_script(tmpname)
