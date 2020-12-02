# On Windows, this file is found in the Python module installation folder
# (typically $DTOOL/built/lib/panda3d), and serves to add the appropriate paths
# to the Python DLL search path to pick up DLL dependencies of our Python
# modules.

def _fixup_dlls():
    try:
        path = __path__[0]
    except (NameError, IndexError):
        return # Not a package, or not on filesystem

    import sys
    if sys.version_info <= (3, 7):
        # We don't have to deal with this on Python 3.7 and earlier.
        return

    import os

    ctprojs = os.environ.get("CTPROJS")
    if ctprojs:
        # If we're presently attached, append the built/lib and built/bin
        # directories of each project we're attached to to the Python DLL
        # search path.
        proj_list = ctprojs.split("+")
        for proj_flavor in proj_list:
            proj, _ = proj_flavor.split(":")
            proj_path = os.environ.get(proj)
            if not proj_path:
                raise StandardError(f"CTPROJS indicates you are attached to {proj}, but I could not find {proj} in your environment!")
            else:
                # Add <proj>/built/lib and <proj>/built/bin onto the Python DLL
                # search path.
                lib_dir = os.path.join(proj_path, "built", "lib")
                if os.path.isdir(lib_dir):
                    print("Adding", lib_dir, "to DLL search path")
                    os.add_dll_directory(lib_dir)
                bin_dir = os.path.join(proj_path, "built", "bin")
                if os.path.isdir(bin_dir):
                    print("Adding", bin_dir, "to DLL search path")
                    os.add_dll_directory(bin_dir)
    else:
        # If we're not attached to anything, assume our lib dir is one
        # directory back from here, and our bin dir is two directories back and
        # in the bin directory.
        lib_dir = os.path.abspath(os.path.join(path, ".."))
        if os.path.isdir(lib_dir):
            os.add_dll_directory(lib_dir)
        bin_dir = os.path.abspath(os.path.join(path, "..", "..", "bin"))
        if os.path.isdir(bin_dir):
            os.add_dll_directory(bin_dir)

_fixup_dlls()
del _fixup_dlls
