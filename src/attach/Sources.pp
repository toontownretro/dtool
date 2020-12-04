// This directory defines the ctattach tools, which are completely
// undocumented and are only intended for use by the VR Studio as a
// convenient way to manage development by multiple people within the
// various Panda source trees.  These tools are not recommended for
// use by the rest of the world; it's probably not worth the headache
// of learning how to set them up.

// Therefore, we only install the stuff in this directory if the
// builder is already using the ctattach tools.  Otherwise, it's safe
// to assume s/he doesn't need the ctattach tools.

#define BUILD_DIRECTORY $[CTPROJS]
#if $[CTPROJS]
  #define INSTALL_SCRIPTS \
    cta.bat ctattach_base.py ctattach.py ctquery.py ctshowprojs.bat \
    ctunattach_base.py ctunattach.py ctutils.py ctvspec.py

  #define INSTALL_CONFIG \
    dtool.bat dtool.init
#endif
