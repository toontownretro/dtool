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
from pathlib import Path

import ctvspec
import ctquery
import ctutils

def usage():
    print("Usage: ctattach -def project flavor  -or-")
    print("       ctattach project [flavor]     -or-")
    print("       ctattach project -            -or-")
    print("       ctattach - [flavor]")
    sys.exit(0)

docnt = 0
attachqueue = []

# Modify a possibly existing variable to have a value in the 'new' environment.
def attach_mod(var, value, root, proj):
    if var == "CTPROJS":
        # As part of the system, this one is special
        pass

# Given the project and flavor, build the lists of variables to set/modify.
def attach_compute(proj, flav, anydef):
    done = 0
    root = ""
    prevflav = ctquery.query_proj(proj)
    if anydef and (prevflav != ""):
        # Want some form of default attachment, and are already attached.
        # Short circuit.
        done = 1

    #
    # Choose real flavor and find/validate root.
    #
    while not done:
        spec = ctvspec.resolve_spec(proj, flav)

        if spec != "":
            root = Path(ctvspec.compute_root(proj, flav, spec))
            if root.exists():
                break
        else:
            print(f"could not resolve '{flav}'")
            break

        if anydef:
            if flav == "install":
                # Oh my! Are we ever in trouble.
                # Want some sort of default, but couldn't get to what we wanted
                print("ctattach to install failed")
                spec = ""
                break
            elif flav == "release":
                flav = "install"
            elif flav == "ship":
                flav = "release"
            else:
                flav = "install"
        else:
            spec = ""
            print(f"resolved '{flav}' but '{root}' does not exist")
            break

    #
    # start real work
    #
    if spec != "":
        proj_up = proj.upper()

        # We scan the .init file first because if there are needed sub-attaches
        # they must happen before the rest of our work.
        init = root / f"built/etc/{proj}.init"

        localmod = {}
        localset = {}
        localsep = {}
        localcmd = {}
        localdo = {}
        localpost = {}
        localdocnt = 0

        if init.exists():
            print(f"scanning {proj}.init")
            initfile = open(str(init), 'r')
            initlines = initfile.readlines()
            for line in initlines:
                line = line.rstrip("\n")
                linesplit = line.split("\#")
                kw = linesplit[0].upper()
                if kw == "MODABS":
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    if not localmod.get(linetmp):
                        localmod[linetmp] = " ".join(linesplit)
                    else:
                        localmod[linetmp] = localmod[linetmp] + " " + " ".join(linesplit)
                elif kw == "MODREL":
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    for loop in linesplit:
                        looptmp = root / ctutils.shell_eval(loop)
                        if looptmp.exists():
                            if not localmod.get(linetmp):
                                localmod[linetmp] = looptmp
                            else:
                                localmod[linetmp] = localcmd[linetmp] + " " + looptmp
                elif kw == "SETABS":
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    if not localset.get(linetmp):
                        localset[linetmp] = " ".join(linesplit)
                    else:
                        localset[linetmp] = localset[linetmp] + " " + " ".join(linesplit)
                elif kw == "SETREL":
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    for loop in linesplit:
                        looptmp = root / ctutils.shell_eval(loop)
                        if looptmp.exists():
                            if not localset.get(linetmp):
                                localset[linetmp] = looptmp
                            else:
                                localset[linetmp] = localset[linetmp] + " " + looptmp
                elif kw == "SEP":
                    linesplit = kw.split(" ")
                    localset[linesplit[1]] = linesplit[2]
                elif kw == "CMD":
                    linesplit = kw.split(" ")
                    localcmd[linesplit[1]] = linesplit[2]
                elif kw == "DOCSH":
                    if 0:
                        linesplit = kw.split(" ")
                        linesplit.pop(0)
                        localdo[localdocnt] = " ".join(linesplit)
                        localdocnt += 1
                elif kw == "DOSH":
                    if 1:
                        linesplit = kw.split(" ")
                        linesplit.pop(0)
                        localdo[localdocnt] = " ".join(linesplit)
                        localdocnt += 1
                elif kw == "DO":
                    linesplit = kw.split(" ")
                    linesplit.pop(0)
                    localdo[localdocnt] = " ".join(linesplit)
                    localdocnt += 1
                elif kw == "POSTPEND":
                    linesplit = kw.split(" ")
                    linesplit.pop(0)
                    localpost[linesplit[1]] = 1
                elif kw == "ATTACH":
                    linesplit = kw.split(" ")
                    linesplit.pop(0)
                    for loop in linesplit:
                        attachqueue.append(loop)
                elif kw != "":
                    print(f"Unknown .init directive '{kw}'")

            initfile.close()

        # now handle sub-attaches
        while len(attachqueue):
            item = attachqueue.pop(0)
            print(f"attaching to {item}")
            attach_compute(item, defflav, 1)

        # now we will do our extensions, then apply the mods from the .init
        # file, if any
        type = ctvspec.spec_type(spec)

        # For now, we will not check whether the various /bin, /lib,
        # /inc directories exist before adding them to the paths.  This
        # helps when attaching to unitialized trees that do not have
        # these directories yet (but will shortly).

        # However, we *will* filter out any trees whose name ends in
        # "MODELS".  These don't have subdirectories that we care about
        # in the normal sense.

        if not proj.endswith("MODELS"):
            item = str(root / "built/bin")
            attach_mod("PATH", item, root, proj)

            item = str(root / "built/lib")
            attach_mod("PATH", item, root, proj)
            attach_mod("LD_LIBRARY_PATH", item, root, proj)
            attach_mod("DYLD_LIBRARY_PATH", item, root, proj)

            item = str(root / "built/include")
            attach_mod("CT_INCLUDE_PATH", item, root, proj)

            item = str(root / "build/etc")
            attach_mod("ETC_PATH", item, root, proj)

        attach_mod("CTPROJS", proj + ":" + flav, root, proj)
        attach_set(proj, root)


tool = os.environ.get("DTOOL")
if not tool:
    raise StandardError("DTOOL environment must be set to use CTtools")

argc = len(sys.argv)

if argc <= 1:
    usage()

idx = 1
proj = ""
flav = ""
noflav = 0
defflav = ""
spread = 0
anydef = 0

#
# parse arguments
#

if sys.argv[idx] == "-def":
    if argc < (idx + 2):
        usage()
    defflav = sys.argv[idx + 2]
    spread = 1
    idx += 1
else:
    environ_defflav = os.environ.get("CTDEFAULT_FLAV")
    if environ_defflav:
        defflav = environ_defflav

proj = sys.argv[idx]

if defflav == "":
    defflav = "default"

if argc > idx:
    flav = sys.argv[idx + 1]
else:
    if proj != "-":
        flav = defflav
        noflav = 1

if (noflav == 1) or (flav == "default"):
    anydef = 1

#
# act on the arguments we got
#

if (proj == "-") or (flav == "-"):
    if argc == 2:
        # List projects that can be attached to
        print("Projects that can be attached to:")
        projects = ctvspec.list_all_projects()
        for project in projects:
            print("   " + project)
    elif proj == "-":
        # List projects that have a given flavor
        print("Projects that have a '%s' flavor:" % flav)
        projects = ctvspec.list_all_projects()
        for project in projects:
            tmp = ctvspec.resolve_spec(project, flav)
            if tmp:
                print("   " + project)
    else:
        # List flavors of a given project
        print("Flavors of project '%s':" % proj)
        flavlist = ctvspec.list_all_flavors(proj)
        for item in flavlist:
            print("   " + item)
else:
    # Output a real attachment.
    curflav = ctquery.query_proj(proj)
    if (curflav == "") or (noflav == 0):
        spec = attach_compute(proj, flav, anydef)

