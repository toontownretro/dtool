
#define BUILD_DIRECTORY $[WINDOWS_PLATFORM]

#define install_scripts_dir $[DTOOL_INSTALL]/lib

// On Windows all of the Python modules from all packages are installed into a
// single directory, typically $DTOOL/built/lib/panda3d.
#define INSTALL_SCRIPTS panda3d/__init__.py
