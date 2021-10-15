/**
 * @file dtool.cxx
 * @author drose
 * @date 2000-05-15
 */

// This is a dummy file whose sole purpose is to give the compiler something
// to compile when making libdtool.so in NO_DEFER mode, which generates an
// empty library that itself links with all the other shared libraries that
// make up libdtool.

// This is the one file in this directory which is actually compiled.  It
// exists just so we can have some symbols and make the compiler happy.

#if defined(_WIN32) && !defined(CPPPARSER) && !defined(LINK_ALL_STATIC)
__declspec(dllexport)
#endif
int dtool;
