#!/usr/bin/env python

# Unattaches your environment from the given project.

# acceptable forms:
#   ctunattach project      - unattach from the given project

import sys

def usage():
    print("Usage: ctunattach project(s)", file=sys.stderr)
