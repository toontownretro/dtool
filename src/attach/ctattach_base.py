import os
import re

import ctutils
import ctquery
import ctvspec

docnt = 0
attachqueue = []

newenv = {}
envpostpend = {}
envsep = {"CTPROJS": "+"}
envcmd = {}
envdo = {}

defflav = ""

# Force set a variable in the 'new' environment.
def attach_set(var, value):
    if var != "" and value != "":
        newenv[var] = [ctutils.to_os_specific(value, False)]

# Get a variable from the environment and split it out to unified format.
def spool_env(var):
    ret = []

    value = os.environ.get(var, "")
    if len(value) == 0:
        return ret

    sep = ctutils.get_env_sep(True)
    splitlist = value.split(sep)
    for i in range(len(splitlist)):
        split = splitlist[i]
        val = ctutils.to_os_specific(split, False)
        if re.search("\s", val) and not re.search("\"", val):
            val = "\"" + val + "\""
        ret.append(val)

    #value = value.replace("\\", "\\\\")
    return ret

# Write a script NOT to change the environment.
def attach_write_null_script(filename):
    outfile = open(filename, "w")

    if ctutils.shell_type == "bat":
        outfile.write("@echo off\n")

    outfile.write("echo No attachment actions performed\n")

    outfile.close()

    print(filename)

# Write a script to setup the environment.
def attach_write_script(filename):
    outfile = open(filename, "w")

    if ctutils.shell_type == "bat":
        outfile.write("@echo off\n")

    for item, vals in newenv.items():
        sep = ctutils.get_env_sep(False)
        if envsep.get(item):
            sep = envsep[item]

        outval = sep.join(vals)

        if ctutils.shell_type == "bash":
            outfile.write(f"{item}={outval}\n")
            if envcmd.get(item) != "set":
                outfile.write(f"export {item}\n")
        elif ctutils.shell_type == "bat":
            outfile.write(f"set {item}={outval}\n")

    for i in range(docnt):
        outfile.write(f"{envdo[i]}\n")

    outfile.close()

    print(filename)

# Modify a possibly existing variable to have a value in the 'new' environment.
def attach_mod(var, value, root, proj):
    if var == "CTPROJS":
        # As part of the system, this one is special
        if not newenv.get(var):
            newenv[var] = spool_env(var)

        proj_lower = proj.lower()

        curflav = ctquery.query_proj(proj_lower)
        if curflav != "":
            tmp = proj + ":" + curflav
            if tmp in newenv[var]:
                idx = newenv[var].index(tmp)
                newenv[var][idx] = value
            else:
                newenv[var].insert(0, value)
        else:
            newenv[var].insert(0, value)

    elif var != "" and value != "":
        value = ctutils.to_os_specific(value, False)
        if re.search("\s", value):
            value = "\"" + value + "\""

        dosimple = False
        if not newenv.get(var):
            # Not in our 'new' environment, add it.  May still be empty.
            newenv[var] = spool_env(var)
        if not value in newenv[var]:
            # If it's in there already, we're done before we started.
            root = ctutils.to_os_specific(root, False)
            if value.startswith(root):
                # New values contains root
                # damn, might need to do an in-place edit
                curroot = os.environ.get(proj, "")
                if curroot == "":
                    dosimple = True
                else:
                    test = value.replace(root, "")
                    test = curroot + test
                    if test in newenv[var]:
                        # There is it.  In-place edit
                        idx = newenv[var].index(test)
                        newenv[var][idx] = value
                    else:
                        dosimple = True
            else:
                # Don't have to sweat in-place edits
                dosimple = True

        if dosimple:
            if envpostpend.get(var):
                newenv[var].append(value)
            else:
                newenv[var].insert(0, value)

# Given the project and flavor, build the lists of variables to set/modify.
def attach_compute(proj, flav, anydef):
    global attachqueue

    done = 0
    root = ""
    spec = ""
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
            root = ctvspec.compute_root(proj, flav, spec)
            if os.path.exists(ctutils.to_os_specific(root)):
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
        init = root + f"/built/etc/{proj}.init"
        init = ctutils.to_os_specific(init)

        localmod = {}
        localset = {}
        localsep = {}
        localcmd = {}
        localdo = {}
        localpost = {}
        localdocnt = 0

        if os.path.exists(init):
            #print(f"scanning {proj}.init")
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
                    if not localmod.get(linetmp):
                        localmod[linetmp] = "*".join(linesplit)
                    else:
                        localmod[linetmp] = localmod[linetmp] + "*" + "*".join(linesplit)
                elif re.search("^MODREL", kw):
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    for loop in linesplit:
                        looptmp = root + "/" + ctutils.shell_eval(loop)
                        if os.path.exists(ctutils.to_os_specific(looptmp)):
                            if not localmod.get(linetmp):
                                localmod[linetmp] = looptmp
                            else:
                                localmod[linetmp] = localcmd[linetmp] + "*" + looptmp
                elif re.search("^SETABS", kw):
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    if not localset.get(linetmp):
                        localset[linetmp] = " ".join(linesplit)
                    else:
                        localset[linetmp] += " ".join(linesplit)
                elif re.search("^SETREL", kw):
                    linesplit = kw.split(" ")
                    linetmp = linesplit[1]
                    linesplit.pop(0)
                    linesplit.pop(0)
                    for loop in linesplit:
                        looptmp = root + "/" + ctutils.shell_eval(loop)
                        if os.path.exists(ctutils.to_os_specific(looptmp)):
                            if not localset.get(linetmp):
                                localset[linetmp] = looptmp
                            else:
                                localset[linetmp] += looptmp
                elif re.search("^SEP", kw):
                    linesplit = kw.split(" ")
                    localsep[linesplit[1]] = linesplit[2]
                elif re.search("^CMD", kw):
                    linesplit = kw.split(" ")
                    localcmd[linesplit[1]] = linesplit[2]
                elif re.search("^DOCSH", kw):
                    if ctutils.shell_type == "csh":
                        linesplit = kw.split(" ")
                        linesplit.pop(0)
                        localdo[localdocnt] = " ".join(linesplit)
                        localdocnt += 1
                elif re.search("^DOSH", kw):
                    if ctutils.shell_type == "sh":
                        linesplit = kw.split(" ")
                        linesplit.pop(0)
                        localdo[localdocnt] = " ".join(linesplit)
                        localdocnt += 1
                elif re.search("^DOBAT", kw):
                    if ctutils.shell_type == "bat":
                        linesplit = kw.split(" ")
                        linesplit.pop(0)
                        localdo[localdocnt] = " ".join(linesplit)
                        localdocnt += 1
                elif re.search("^DO", kw):
                    linesplit = kw.split(" ")
                    linesplit.pop(0)
                    localdo[localdocnt] = linesplit
                    localdocnt += 1
                elif re.search("^POSTPEND", kw):
                    linesplit = kw.split(" ")
                    linesplit.pop(0)
                    localpost[linesplit[1]] = 1
                elif re.search("^ATTACH", kw):
                    linesplit = kw.split(" ")
                    linesplit.pop(0)
                    attachqueue += linesplit
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

        if not re.search("MODELS$", proj_up):
            item = root + "/built/bin"

            attach_mod("PATH", item, root, proj_up)

            item = root + "/built/lib"
            attach_mod("PATH", item, root, proj_up)
            attach_mod("LD_LIBRARY_PATH", item, root, proj_up)
            attach_mod("DYLD_LIBRARY_PATH", item, root, proj_up)
            attach_mod("PYTHONPATH", item, root, proj_up)

            item = root + "/built/include"
            attach_mod("CT_INCLUDE_PATH", item, root, proj_up)

            item = root + "/built/etc"
            attach_mod("ETC_PATH", item, root, proj_up)

        attach_mod("CTPROJS", proj_up + ":" + flav, root, proj_up)
        attach_set(proj_up, root)

        # Run thru the stuff saved up from the .init file
        envsep.update(localsep)
        envpostpend.update(localpost)
        for k, v in localmod.items():
            for thing in v:
                attach_mod(k, thing, root, proj)
        for k, v in localset.items():
            attach_set(k, v)
        envcmd.update(localcmd)
        global docnt
        for i in range(localdocnt):
            envdo[docnt] = localdo[i]
            docnt += 1

    return spec
