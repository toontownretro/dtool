//
// Config.Win64.pp
//
// This file defines some custom config variables for the Windows
// platform, using MS VC++.  It makes some initial guesses about
// compiler features, etc.
//

// *******************************************************************
// NOTE: you should not attempt to copy this file verbatim as your own
// personal Config.pp file.  Instead, you should start with an empty
// Config.pp file, and add lines to it when you wish to override
// settings given in here.  In the normal ppremake system, this file
// will always be read first, and then your personal Config.pp file
// will be read later, which gives you a chance to override the
// default settings found in this file.  However, if you start by
// copying the entire file, it will be difficult to tell which
// settings you have customized, and it will be difficult to upgrade
// to a subsequent version of Panda.
// *******************************************************************

#include $[THISDIRPREFIX]Config.Win32.pp
