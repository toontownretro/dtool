#!/usr/bin/env python

# Prints a list of all attached projects and flavors.

# acceptable forms:
#   ctshowprojs                  - show all attached projects

import os

projs_env = os.environ.get("CTPROJS")

if not projs_env:
    print("Not attached to any projects.")
else:
    print("Current project attachments:")
    projs = projs_env.split("+")
    for proj in projs:
        proj_name, flavor = proj.split(":")
        print(format(proj_name, '12'), format(flavor, '12'))
