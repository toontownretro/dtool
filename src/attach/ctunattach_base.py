from ctattach_base import *

import ctvspec
import ctutils

import os
import re
import sys

# List of variables to unset.
unset = []

# Remove a value from a variable.  If it is the only thing remaining in the
# variable, add it to the unset list.
def unattach_mod(variable, value):
    # If we didn't get any data, nothing really to do.
    if variable == "" or value == "":
        return

    # If the variable is already set to be unset, nothing really to do.
    if variable in unset:
        return

    # If the variable isn't in newenv, move it there, if it's empty mark it for
    # unsetting.
    if not variable in newenv:
        newenv[variable] = spool_env(variable)
        if len(newenv[variable]) == 0:
            unset.append(variable)
            del newenv[variable]
            return

    value = ctutils.to_os_specific(value, False)

    # If the value does not appear in the variable, nothing really to do.
    if not value in newenv[variable]:
        return

    # Now down to the real work.

    # If the variable is exactly the value, mark it for unsetting.
    if len(newenv[variable]) == 1 and newenv[variable][0] == value:
        unset.append(variable)
        del newenv[variable]
    elif value in newenv[variable]:
        newenv[variable].remove(value)
    else:
        print(f"ERROR: variable '{variable}' contains '{value}' "
              f"(in '{newenv[variable]}'), but I am too stupid to figure out "
               "how to remove it.", file=sys.stderr)

# Given the project and flavor, build the lists of variables to set/modify.
def unattach_compute(proj, flav):
    spec = ctvspec.resolve_spec(proj, flav)
    root = ctvspec.compute_root(proj, flav, spec)

    if spec != "":
        proj_up = proj.upper()

        # Since we don't have to worry about sub-attaches, it doesn't matter if
        # we scan the .init file first or not.  So we won't.

        item = root + "/built/bin"
        unattach_mod("PATH", item)

        item = root + "/built/lib"
        unattach_mod("PATH", item)
        unattach_mod("LD_LIBRARY_PATH", item)
        unattach_mod("DYLD_LIBRARY_PATH", item)
        unattach_mod("PYTHONPATH", item)

        item = root + "/built/include"
        unattach_mod("CT_INCLUDE_PATH", item)

        item = root + "/built/etc"
        unattach_mod("ETC_PATH", item)
        unattach_mod("PRC_PATH", item)

        item = proj_up + ":" + flav
        unattach_mod("CTPROJS", item)

        unset.append(proj_up)

        init = root + f"/built/etc/{proj}.init"
        init = ctutils.to_os_specific(init)

        if os.path.exists(init):
            initfile = open(str(init), 'r')
            initlines = initfile.readlines()
            for line in initlines:
                line = line.rstrip("\n")
                linesplit = line.split("#")
                kw = linesplit[0]

                if re.search("^MODABS", kw):
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    for loop in linesplit:
                        unattach_mod(linetmp, loop)
                elif re.search("^MODREL", kw):
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    for loop in linesplit:
                        unattach_mod(linetmp, root + "/" + loop)
                elif re.search("^SETABS", kw):
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    unset.append(linetmp)
                elif re.search("^SETREL", kw):
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    unset.append(linetmp)
                elif re.search("^SEP", kw):
                    linesplit = kw.split(" ")
                    envsep[linesplit[1]] = linesplit[2]
                elif re.search("^CMD", kw):
                    linesplit = kw.split(" ")
                    envcmd[linesplit[1]] = linesplit[2]
                elif re.search("^POSTPEND", kw):
                    linesplit = kw.split(" ")
                    envpostpend[linesplit[1]] = 1
                elif re.search("(^DOCSH)|(^DOSH)|(^DO)|(^ATTACH)", kw):
                    # DO and ATTACH commands mean nothing for unattach
                    pass
                else:
                    print(f"Unknown .init directive '{kw}'", file=sys.stderr)

            initfile.close()

    return spec

def unattach_write_script(filename):
    pass
