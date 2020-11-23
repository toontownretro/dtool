import os

# Return the attached flavor of given project (or empty string).
def query_proj(proj):
    projs = os.environ.get("CTPROJS", "")
    projlist = projs.split("+")
    ret = ""
    for pair in projlist:
        pairlist = pair.split(":")
        pairlist[0] = pairlist[0].lower()
        if pairlist[0] == proj:
            ret = pairlist[1]
    return ret

# Return all projects attached with a given flavor.
def query_flav(flav):
    projs = os.environ.get("CTPROJS", "")
    projlist = projs.split("+")

    ret = []
    for pair in projlist:
        pairlist = pair.split(":")
        if pairlist[1] == flav:
            ret.append(pairlist[0].lower())

    return ret