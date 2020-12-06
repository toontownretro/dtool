import glob
import os
import sys

import ctutils

# flavor -> spec data
ctvspecs = {}
# the current vspec project name
ctvspec_read = ""

# Read a .vspec file into a map.
def read_vspec(proj):
    global ctvspecs
    global ctvspec_read

    print("Reading vspec file for project", proj, file=sys.stderr)
    path = ctutils.ctvspec_path / ("%s.vspec" % proj)
    if path.exists():
        ctvspecs = {}
        specfile = open(str(path), 'r')
        speclines = specfile.readlines()
        for specline in speclines:
            specline = specline.rstrip("\n")
            partlist = specline.split("\#")
            part = partlist[0]
            if part != "":
                partlist = part.split(":")
                tag = partlist.pop(0)
                spec = ":".join(partlist)
                if validate_spec(spec):
                    ctvspecs[tag] = spec
        specfile.close()
        ctvspec_read = proj
    else:
        print("read_vspec: cannot locate '%s'" % str(path), file=sys.stderr)
        print("(did you forget to run the $WINTOOLS/cp_vspec script?)", file=sys.stderr)
        ctvspecs = {}
        ctvspec_read = ""

# Given a spec line, return its type.
def spec_type(spec):
    return spec.split(":")[0]

# Given a spec line, return its options, if any.
def spec_options(spec):
    speclist = spec.split(":")
    speclist.pop(0)
    return ":".join(speclist)

# Given the options part of a spec line, find a given option.
def spec_find_option(line, option):
    ret = ""
    options = line.split(":")
    for item in options:
        itemlist = item.split("=")
        if itemlist[0] == option:
            ret = itemlist[1]
    return ctutils.shell_eval(ret)

# Validate a spec line.
def validate_spec(spec):
    type = spec_type(spec)
    speclist = spec_options(spec).split(":")
    have_error = 0
    ret = 0

    if type == "ref":
        have_name = 0
        for item in speclist:
            itemlist = item.split("=")
            if itemlist[0] == "name":
                if have_name:
                    have_error = 1
                    print("multiple name options on 'ref'", file=sys.stderr)
                have_name = 1
            else:
                print("invalid option on 'ref' = " + item, file=sys.stderr)
                have_error = 1
        if not have_error:
            if have_name:
                ret = 1
    elif type == "root":
        have_path = False
        for item in speclist:
            itemlist = item.split("=")
            if itemlist[0] == "path":
                if have_path:
                    have_error = True
                    print("multiple path options on 'root'", file=sys.stderr)
                have_path = True
            else:
                print("invalid option on 'root' = " + item, file=sys.stderr)
                have_error = True
        if not have_error:
            if have_path:
                ret = 1
    elif type == "vroot":
        have_name = False
        for item in speclist:
            itemlist = item.split("=")
            if itemlist[0] == "name":
                if have_name:
                    have_error = True
                    print("multiple name options on 'vroot'", file=sys.stderr)
                have_name = True
            else:
                print("invalid option on 'vroot' = " + item, file=sys.stderr)
                have_error = True
        if not have_error:
            ret = 1
    elif type == "croot":
        have_path = False
        have_server = False
        for item in speclist:
            itemlist = item.split("=")
            if itemlist[0] == "path":
                if have_path:
                    have_error = True
                    print("multiple path options on 'croot'", file=sys.stderr)
                have_path = True
            elif itemlist[0] == "server":
                if have_server:
                    have_error = True
                    print("multiple server options on 'croot'", file=sys.stderr)
                have_server = True
            else:
                print("invalid option on 'croot' = " + item, file=sys.stderr)
                have_error = True
        if not have_error:
            if have_path and have_server:
                ret = 1
    else:
        print("unknown spec type '%s'" % speclist[0], file=sys.stderr)

    return ret

# Returns a list of all projects.
def list_all_projects():
    ret = []
    # Get all files ending in .vspec and build a list basenames for each file.
    path = ctutils.ctvspec_path / '*.vspec'
    dirfiles = glob.glob(str(path))
    for file in dirfiles:
        # The project is the basename of the file w/o the extension.
        ret.append(os.path.splitext(os.path.basename(file))[0])
    return ret

# Returns a list of all flavors of a project.
def list_all_flavors(proj):
    proj = proj.lower()

    if ctvspec_read != proj:
        read_vspec(proj)

    return list(ctvspecs.keys())

# Resolve a final spec line for a given flavor.
def resolve_spec(proj, flav):
    proj = proj.lower()

    if ctvspec_read != proj:
        read_vspec(proj)

    spec = ctvspecs.get(flav, "")
    ret = ""
    if spec != "":
        type = spec_type(spec)
        speclist = spec_options(spec).split(":")
        if type == "ref":
            optionlist = speclist[0].split("=")
            if optionlist[0] != "name":
                print("bad data attached to flavor " + flav + " of project " + proj, file=sys.stderr)
            else:
                tmp = ctutils.shell_eval(optionlist[1])
                ret = resolve_spec(proj, tmp)
        else:
            ret = spec

    if ret == "":
        print("unknown flavor " + flav + " of project " + proj, file=sys.stderr)

    return ret

# Resolve the final name for a given flavor.
def resolve_spec_name(proj, flav):
    proj = proj.lower()
    if ctvspec_read != proj:
        read_vspec(proj)

    spec = ctvspecs.get("flav", "")
    ret = flav
    if spec != "":
        type = spec_type(spec)
        speclist = spec_options(spec).split(":")
        if type == "ref":
            optionlist = speclist[0].split("=")
            if optionlist[0] != "name":
                print(f"bad data attached to flavor {flav} of project {proj}", file=sys.stderr)
            else:
                tmp = ctutils.shell_eval(optionlist[1])
                ret = resolve_spec_name(proj, tmp)

    if ret == "":
        print(f"unknown flavor {flav} of project {proj}", file=sys.stderr)

    return ret

def compute_root(proj, flav, spec):
    proj = proj.lower()

    if ctvspec_read != proj:
        read_vspec(proj)

    type = spec_type(spec)
    options = spec_options(spec)
    vname = resolve_spec_name(proj, flav)

    if type == "root":
        return ctutils.from_os_specific(spec_find_option(options, "path"))
    elif type == "vroot":
        name = spec_find_option(options, "name")
        if name != "":
            return f"/view/{name}/vobs/{proj}"
        else:
            return f"/view/{vname}/vobs/{proj}"
    elif type == "croot":
        return ctutils.from_os_specific(spec_find_option(options, "path"))
    else:
        print(f"unknown flavor type '{type}'", file=sys.stderr)
        return ""
