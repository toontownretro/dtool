//
// dtool/Config.pp
//
// This file defines certain configuration variables that are written
// into the various make scripts.  It is processed by ppremake (along
// with the Sources.pp files in each of the various directories) to
// generate build scripts appropriate to each environment.
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

//
// ppremake is capable of generating makefiles for Unix compilers such
// as gcc or SGI's MipsPRO compiler, as well as for Windows
// environments like Microsoft's Visual C++.  It can also,
// potentially, generate Microsoft Developer's Studio project files
// directly, although we haven't written the scripts to do this yet.
// In principle, it can be extended to generate suitable build script
// files for any number of different build environments.
//
// All of these build scripts can be tuned for a particular
// environment via this file.  This is the place for the user to
// specify which external packages are installed and where, or to
// enable or disable certain optional features.  However, it is
// suggested that rather than modify this file directly, you create a
// custom file in your home directory and there redefine whatever
// variables are appropriate, and set the environment variable
// PPREMAKE_CONFIG to refer to it.  In this way, you can easily get an
// updated source tree (including a new Config.pp) without risking
// accidentally losing your customizations.  This also avoids having
// to redefine the same variables in different packages (for instance,
// in dtool and in panda).
//
// The syntax in this file resembles some hybrid between C++
// preprocessor declarations and GNU make variables.  This is the same
// syntax used in the various ppremake system configure files; it's
// designed to be easy to use as a macro language to generate
// makefiles and their ilk.
//
// Some of the variables below are defined using the #define command,
// and others are defined using #defer.  The two are very similar in
// their purpose; the difference is that, if the variable definition
// includes references to other variables (e.g. $[varname]), then
// #define will evaluate all of the other variable references
// immediately and store the resulting expansion, while #defer will
// store only the variable references themselves, and expand them when
// the variable is later referenced.  It is very similar to the
// relationship between := and = in GNU Make.
// dtool/Config.pp

// In general, #defer is used in this file, to allow the user to
// redefine critical variables in his or her own Config.pp file.



// What kind of build scripts are we generating?  This selects a
// suitable template file from the ppremake system files.  The
// allowable choices, at present, are:
//
//  unix      - Generate makefiles suitable for most Unix platforms.
//  nmake     - Generate makefiles for Microsoft Visual C++, using
//              Microsoft's nmake utility.
//  gmsvc     - Generate makefiles similar to the above, using Microsoft
//              Visual C++, but uses the Cygwin-supplied GNU make
//              instead of Microsoft nmake.  This is potentially
//              faster if you have multiple CPU's, since it supports
//              distributed make.  It's a tiny bit slower if you're
//              not taking advantage of distributed make, because of
//              the overhead associated with Cygwin fork() calls.

#if $[or $[eq $[PLATFORM], Win32],$[eq $[PLATFORM], Win64]]
  #define BUILD_TYPE nmake
#elif $[or $[eq $[PLATFORM], Cygwin],$[eq $[PLATFORM], Cygwin64]]
  #define BUILD_TYPE gmsvc
#elif $[OSX_PLATFORM]
  #define BUILD_TYPE unix
#else
  #define BUILD_TYPE unix
#endif

// Determine a sensible default location to search for third-party packages
// on Unix.  On platforms like Windows, there is no standard location for
// third-party packages.
#if $[UNIX_PLATFORM]
#define DEFAULT_IPATH /usr/include
#define DEFAULT_LPATH /usr/lib/$[shell uname -m]-linux-gnu
#else
#define DEFAULT_IPATH
#define DEFAULT_LPATH
#endif

// What is the default install directory for all trees in the Panda
// suite?  The default value for this variable is provided by
// ppremake; on Unix machines it is the value of --prefix passed in to
// the configure script, and on Windows machines the default is
// hardcoded in config_msvc.h to C:\Panda3d.

// You may also override this for a particular tree by defining a
// variable name like DTOOL_INSTALL or PANDA_INSTALL.  (The
// INSTALL_DIR variable will have no effect if you are using the
// ctattach tools to control your attachment to the trees; but this
// will be the case only if you are a member of the VR Studio.)

// #define INSTALL_DIR /usr/local/panda

// If you intend to use Panda only as a Python module, you may find
// the following define useful (but you should put in the correct path
// to site-packages within your own installed Python).  This will
// install the Panda libraries into the standard Python search space
// so that they can be accessed as Python modules.  (Also see the
// PYTHON_IPATH variable, below.)

// If you don't do this, you can still use Panda as a Python module,
// but you must put /usr/local/panda/lib (or $INSTALL_DIR/lib) on
// your PYTHONPATH.

// #define INSTALL_LIB_DIR /usr/lib/python2.6/site-packages


// The character used to separate components of an OS-specific
// directory name depends on the platform (it is '/' on Unix, '\' on
// Windows).  That character selection is hardcoded into Panda and
// cannot be changed here.  (Note that an internal Panda filename
// always uses the forward slash, '/', to separate the components of a
// directory name.)

// There's a different character used to separate the complete
// directory names in a search path specification.  On Unix, the
// normal convention is ':', on Windows, it has to be ';', because the
// colon is already used to mark the drive letter.  This character is
// selectable here.  Most users won't want to change this.  If
// multiple characters are placed in this string, any one of them may
// be used as a separator character.
#define DEFAULT_PATHSEP $[if $[WINDOWS_PLATFORM],;,:]

// What level of compiler optimization/debug symbols should we build?
// The various optimize levels are defined as follows:
//
//   1 - No compiler optimizations, debug symbols, debug heap, lots of checks
//   2 - Full compiler optimizations, debug symbols, debug heap, lots of checks
//   3 - Full compiler optimizations, full debug symbols, fewer checks
//   4 - Full optimizations, no debug symbols, and asserts removed
//
#define OPTIMIZE 3

// On OSX, you may or may not want to compile universal binaries.

// Turning this option on allows your compiled version of Panda to run
// on any version of OSX (PPC or Intel-based), but it will also
// increase the compilation time, as well as the resulting binary
// size.  I believe you have to be building on an Intel-based platform
// to generate universal binaries using this technique.  This option
// has no effect on non-OSX platforms.
#define UNIVERSAL_BINARIES

// Panda uses prc files for runtime configuration.  There are many
// compiled-in options to customize the behavior of the prc config
// system; most users won't need to change any of them.  Feel free to
// skip over all of the PRC_* variables defined here.

// The default behavior is to search for files names *.prc in the
// directory specified by the PRC_DIR environment variable, and then
// to search along all of the directories named by the PRC_PATH
// environment variable.  Either of these variables might be
// undefined; if both of them are undefined, the default is to search
// in the directory named here by DEFAULT_PRC_DIR.

// By default, we specify the install/etc dir, which is where the
// system-provided PRC files get copied to.
#defer DEFAULT_PRC_DIR $[INSTALL_DIR]/etc

// You can specify the names of the environment variables that are
// used to specify the search location(s) for prc files at runtime.
// These are space-separated lists of environment variable names.
// Specify empty string for either one of these to disable the
// feature.  For instance, redefining PRC_DIR_ENVVARS here to
// PANDA_PRC_DIR would cause the environment variable $PANDA_PRC_DIR
// to be consulted at startup instead of the default value of
// $PRC_DIR.
#define PRC_DIR_ENVVARS PRC_DIR
#define PRC_PATH_ENVVARS PRC_PATH

// You can specify the name of the file(s) to search for in the above
// paths to be considered a config file.  This should be a
// space-separated list of filename patterns.  This is *.prc by
// default; normally there's no reason to change this.
#define PRC_PATTERNS *.prc

// You can optionally encrypt your prc file(s) to help protect them
// from curious eyes.  You have to specify the encryption key, which
// gets hard-coded into the executable.  (This feature provides mere
// obfuscation, not real security, since the encryption key can
// potentially be extracted by a hacker.)  This requires building with
// OpenSSL (see below).
#define PRC_ENCRYPTED_PATTERNS *.prc.pe
#define PRC_ENCRYPTION_KEY ""

// One unusual feature of config is the ability to execute one or more
// of the files it discovers as if it were a program, and then treat
// the output of this program as a prc file.  If you want to use this
// feature, define this variable to the filename pattern or patterns
// for such executable-style config programs (e.g. *prc.exe).  This
// can be the same as the above if you like this sort of ambiguity; in
// that case, config will execute the file if it appears to be
// executable; otherwise, it will simply read it.
#define PRC_EXECUTABLE_PATTERNS

// If you do use the above feature, you'll need another environment
// variable that specifies additional arguments to pass to the
// executable programs.  The default definition, given here, makes
// that variable be $PRC_EXECUTABLE_ARGS.  Sorry, the same arguments
// must be supplied to all executables in a given runtime session.
#define PRC_EXECUTABLE_ARGS_ENVVAR PRC_EXECUTABLE_ARGS

// You can implement signed prc files, if you require this advanced
// feature.  This allows certain config variables to be set only by a
// prc file that has been provided by a trusted source.  To do this,
// first install and compile Dtool with OpenSSL (below) and run the
// program make-prc-key, and then specify here the output filename
// generated by that program, and then recompile Dtool (ppremake; make
// install).
#define PRC_PUBLIC_KEYS_FILENAME

// By default, the signed-prc feature, above, is enabled only for a
// release build (OPTIMIZE = 4).  In a normal development environment
// (OPTIMIZE < 4), any prc file can set any config variable, whether
// or not it is signed.  Set this variable true (nonempty) or false
// (empty) to explicitly enable or disable this feature.
#defer PRC_RESPECT_TRUST_LEVEL $[= $[OPTIMIZE],4]

// If trust level is in effect, this specifies the default trust level
// for any legacy (Dconfig) config variables (that is, variables
// created using the config.GetBool(), etc. interface, rather than the
// newer ConfigVariableBool interface).
#defer PRC_DCONFIG_TRUST_LEVEL 0

// If trust level is in effect, you may globally increment the
// (mis)trust level of all variables by the specified amount.
// Incrementing this value by 1 will cause all variables to require at
// least a level 1 signature.
#define PRC_INC_TRUST_LEVEL 0

// Similarly, the descriptions are normally saved only in a
// development build, not in a release build.  Set this value true to
// explicitly save them anyway.
#defer PRC_SAVE_DESCRIPTIONS $[< $[OPTIMIZE],4]

// This is the end of the PRC variable customization section.  The
// remaining variables are of general interest to everyone.


// NOTE: In the following, to indicate "yes" to a yes/no question,
// define the variable to be a nonempty string.  To indicate "no",
// define the variable to be an empty string.

// Many of the HAVE_* variables are defined in terms of expressions
// based on the paths and library names, etc., defined above.  These
// are defined using the "defer" command, so that they are not
// evaluated right away, giving the user an opportunity to redefine
// the variables they depend on, or to redefine the HAVE_* variables
// themselves (you can explicitly define a HAVE_* variable to some
// nonempty string to force the package to be marked as installed).


// Do you want to generate a Python-callable interrogate interface?
// This is only necessary if you plan to make calls into Panda from a
// program written in Python.  This is done only if HAVE_PYTHON,
// below, is also true.
#define INTERROGATE_PYTHON_INTERFACE 1

// Define this true to use the new interrogate feature to generate
// Python-native objects directly, rather than requiring a separate
// FFI step.  This loads and runs much more quickly than the original
// mechanism.  Define this false (that is, empty) to use the original
// interfaces.
#define PYTHON_NATIVE 1

// Do you want to generate a C-callable interrogate interface?  This
// generates an interface similar to the Python interface above, with
// a C calling convention.  It should be useful for most other kinds
// of scripting language; the VR Studio used to use this to make calls
// into Panda from Squeak.  This is not presently used by any VR
// Studio code.
#define INTERROGATE_C_INTERFACE

// Do you even want to build interrogate at all?  This is the program
// that reads our C++ source files and generates one of the above
// interfaces.  If you won't be building the interfaces, you don't
// need the program.
#defer HAVE_INTERROGATE $[or $[INTERROGATE_PYTHON_INTERFACE],$[INTERROGATE_C_INTERFACE]]

// What additional options should be passed to interrogate when
// generating either of the above two interfaces?  Generally, you
// probably don't want to mess with this.
#define INTERROGATE_OPTIONS -fnames -string -refcount -assert

// What's the name of the interrogate binary to run?  The default
// specified is the one that is built as part of DTOOL.  If you have a
// prebuilt binary standing by (for instance, one built opt4), specify
// its name instead.
#define INTERROGATE interrogate
#define INTERROGATE_MODULE interrogate_module

// What is the name of the C# compiler binary?
#define CSHARP csc

// This defines the include path to the Eigen linear algebra library.
// If this is provided, Panda will use this library as the fundamental
// implementation of its own linmath library; otherwise, it will use
// its own internal implementation.  The primary advantage of using
// Eigen is SSE2 support, which is only activated if LINMATH_ALIGN
// is also enabled.  (However, activating LINMATH_ALIGN does
// constrain most objects in Panda to 16-byte alignment, which could
// impact memory usage on very-low-memory platforms.)  Currently
// experimental.
#define EIGEN_IPATH $[DEFAULT_IPATH]/eigen3
#defer EIGEN_CFLAGS $[if $[X86_PLATFORM],$[if $[WINDOWS_PLATFORM],/arch:SSE2,-msse2]]
#defer HAVE_EIGEN $[isdir $[EIGEN_IPATH]/Eigen]
#define LINMATH_ALIGN 1

// Is Python installed, and should Python interfaces be generated?  If
// Python is installed, which directory is it in?
#define PYTHON_IPATH $[DEFAULT_IPATH]/python3.8
#define PYTHON_LPATH $[DEFAULT_LPATH]
#define PYTHON_FPATH
#define PYTHON_COMMAND python
#defer PYTHON_DEBUG_COMMAND $[PYTHON_COMMAND]$[if $[WINDOWS_PLATFORM],_d]
#define PYTHON_FRAMEWORK
#defer HAVE_PYTHON $[or $[PYTHON_FRAMEWORK],$[isdir $[PYTHON_IPATH]]]

// By default, we'll assume the user only wants to run with Debug
// python if he has to--that is, on Windows when building a debug build.
#defer USE_DEBUG_PYTHON $[and $[< $[OPTIMIZE],3],$[WINDOWS_PLATFORM]]

// Normally, Python source files are copied into the INSTALL_LIB_DIR
// defined above, along with the compiled C++ library objects, when
// you make install.  If you prefer not to copy these Python source
// files, but would rather run them directly out of the source
// directory (presumably so you can develop them and make changes
// without having to reinstall), comment out this definition and put
// your source directory on your PYTHONPATH.
#define INSTALL_PYTHON_SOURCE 1

// Do you want to compile in support for tracking memory usage?  This
// enables you to define the variable "track-memory-usage" at runtime
// to help track memory leaks, and also report total memory usage on
// PStats.  There is some small overhead for having this ability
// available, even if it is unused.
#defer DO_MEMORY_USAGE $[<= $[OPTIMIZE], 3]

// This option compiles in support for simulating network delay via
// the min-lag and max-lag prc variables.  It adds a tiny bit of
// overhead even when it is not activated, so it is typically enabled
// only in a development build.
#defer SIMULATE_NETWORK_DELAY $[<= $[OPTIMIZE], 3]

// This option compiles in support for immediate-mode OpenGL
// rendering.  Since this is normally useful only for researching
// buggy drivers, and since there is a tiny bit of per-primitive
// overhead to have this option available even if it is unused, it is
// by default enabled only in a development build.  This has no effect
// on DirectX rendering.
#defer SUPPORT_IMMEDIATE_MODE $[<= $[OPTIMIZE], 3]

// This option compiles in support for legacy fixed-function OpenGL
// rendering.  You may want to turn this off if your application is
// completely shader-based.  Note that turning this off compiles out
// fixed-function support completely.  Alternatively, you can disable
// fixed-function support at runtime by setting gl-version 3 2 in your
// Config.prc.
#define SUPPORT_FIXED_FUNCTION 1

// These are two optional alternative memory-allocation schemes
// available within Panda.  You can experiment with either of them to
// see if they give better performance than the system malloc(), but
// at the time of this writing, it doesn't appear that they do.
#define USE_MEMORY_DLMALLOC
#define USE_MEMORY_PTMALLOC2

// Set this true if you prefer to use the system malloc library even
// if 16-byte alignment must be performed on top of it, wasting up to
// 30% of memory usage.  If you do not set this, and 16-byte alignment
// is required and not provided by the system malloc library, then an
// alternative malloc system (above) will be used instead.
#define MEMORY_HOOK_DO_ALIGN

// Panda contains some experimental code to compile for IPhone.  This
// requires the Apple IPhone SDK, which is currently only available
// for OS X platforms.  Set this to either "iPhoneSimulator" or
// "iPhoneOS".  Note that this is still *experimental* and incomplete!
// Don't enable this unless you know what you're doing!
#define BUILD_IPHONE

// Panda contains some experimental code to compile for Android.  This
// requires the Google Android NDK.
// Besides BUILD_ANDROID, you'll also have to set ANDROID_NDK_HOME
// to the location of the Android NDK directory.  ANDROID_NDK_HOME may
// not contain any spaces.
// Furthermore, ANDROID_ABI can be set to armeabi, armeabi-v7a, x86,
// or mips, depending on which architecture should be targeted.
#define ANDROID_NDK_HOME
#define ANDROID_ABI armeabi
#define ANDROID_STL gnustl_shared
#define ANDROID_NDK_PLATFORM android-9
#define ANDROID_ARCH arm
#defer ANDROID_TOOLCHAIN $[if $[eq $[ANDROID_ARCH],arm],arm-linux-androideabi]

// Do you want to use one of the alternative malloc implementations?
// This is almost always a good idea on Windows, where the standard
// malloc implementation appears to be pretty poor, but probably
// doesn't matter much on Linux (which is likely to implement
// ptmalloc2 anyway).  We always define this by default on Windows; on
// Linux, we define it by default only when DO_MEMORY_USAGE is enabled
// (since in that case, we'll be paying the overhead for the extra
// call anyway) or when HAVE_THREADS is not defined (since the
// non-thread-safe dlmalloc is a tiny bit faster than the system
// library).

// In hindsight, let's not enable this at all.  It just causes
// problems.
//#defer ALTERNATIVE_MALLOC $[or $[WINDOWS_PLATFORM],$[DO_MEMORY_USAGE],$[not $[HAVE_THREADS]]]
#define ALTERNATIVE_MALLOC

// Define this true to use the DELETED_CHAIN macros, which support
// fast re-use of existing allocated blocks, minimizing the low-level
// calls to malloc() and free() for frequently-created and -deleted
// objects.  There's usually no reason to set this false, unless you
// suspect a bug in Panda's memory management code.
#define USE_DELETED_CHAIN 1

// Define this if you are building on Windows 7 or better, and you
// want your Panda build to run only on Windows 7 or better, and you
// need to use the Windows touchinput interfaces.
#define HAVE_WIN_TOUCHINPUT

// Define this true to build the low-level native network
// implementation.  Normally this should be set true.
#define WANT_NATIVE_NET 1
#define NATIVE_NET_IPATH
#define NATIVE_NET_LPATH
#define NATIVE_NET_LIBS $[if $[WINDOWS_PLATFORM],wsock32.lib]

// Do you want to build the high-level network interface?  This layers
// on top of the low-level native_net interface, specified above.
// Normally, if you build NATIVE_NET, you will also build NET.
#defer HAVE_NET $[WANT_NATIVE_NET]

// Do you want to build the egg loader?  Usually there's no reason to
// avoid building this, unless you really want to make a low-footprint
// build (such as, for instance, for the iPhone).
#define HAVE_EGG 1

// Is a third-party STL library installed, and where?  This is only
// necessary if the default include and link lines that come with the
// compiler don't provide adequate STL support.  At least some form of
// STL is absolutely required in order to build Panda.
#define STL_IPATH
#define STL_LPATH
#define STL_CFLAGS
#define STL_LIBS

// Does your STL library provide hashed associative containers like
// hash_map and hash_set?  Define this true if you have a nonstandard
// STL library that provides these, like Visual Studio .NET's.  (These
// hashtable containers are not part of the C++ standard yet, but the
// Dinkum STL library that VC7 ships with includes a preliminary
// implementation that Panda can optionally use.)  For now, we assume
// you have this by default only on a Windows platform.
#define HAVE_STL_HASH 1

// Is OpenSSL installed, and where?
#define OPENSSL_IPATH $[DEFAULT_IPATH]
#define OPENSSL_LPATH $[DEFAULT_LPATH]
#if $[WINDOWS_PLATFORM]
#define OPENSSL_LIBS libssl.lib libcrypto.lib
#else
#define OPENSSL_LIBS ssl crypto
#endif
#defer HAVE_OPENSSL $[libtest $[OPENSSL_LPATH],$[OPENSSL_LIBS]]

// Define this true to include the OpenSSL code to report verbose
// error messages when they occur.
#defer REPORT_OPENSSL_ERRORS $[< $[OPTIMIZE], 4]

// Is libjpeg installed, and where?
#define JPEG_IPATH $[DEFAULT_IPATH]
#define JPEG_LPATH $[DEFAULT_LPATH]
#define JPEG_LIBS $[if $[WINDOWS_PLATFORM],jpeg-static.lib,jpeg]
#defer HAVE_JPEG $[libtest $[JPEG_LPATH],$[JPEG_LIBS]]

// Some versions of libjpeg did not provide jpegint.h.  Redefine this
// to empty if you lack this header file.
#define PHAVE_JPEGINT_H 1

// Do you want to compile video-for-linux?  If you have an older Linux
// system with incompatible headers, define this to empty string.
#defer HAVE_VIDEO4LINUX $[IS_LINUX]

// Is libpng installed, and where?
#define PNG_IPATH $[DEFAULT_IPATH]/libpng16
#define PNG_LPATH $[DEFAULT_LPATH]
#define PNG_LIBS $[if $[WINDOWS_PLATFORM], libpng16_static.lib, png]
#defer HAVE_PNG $[libtest $[PNG_LPATH],$[PNG_LIBS]]

// Is libtiff installed, and where?
#define TIFF_IPATH $[DEFAULT_IPATH]
#define TIFF_LPATH $[DEFAULT_LPATH]
#define TIFF_LIBS tiff
#defer HAVE_TIFF $[libtest $[TIFF_LPATH],$[TIFF_LIBS]]

// These image file formats don't require the assistance of a
// third-party library to read and write, so there's normally no
// reason to disable them in the build, unless you are looking to
// reduce the memory footprint.
#define HAVE_SGI_RGB 1
#define HAVE_TGA 1
#define HAVE_IMG 1
#define HAVE_SOFTIMAGE_PIC 1
#define HAVE_BMP 1
#define HAVE_PNM 1

// Is libfftw installed, and where?
#define FFTW_IPATH $[DEFAULT_IPATH]
#define FFTW_LPATH $[DEFAULT_LPATH]
#define FFTW_LIBS rfftw fftw
#defer HAVE_FFTW $[libtest $[FFTW_LPATH],$[FFTW_LIBS]]
// This is because darwinport's version of the fftw lib is called
// drfftw instead of rfftw.
#defer PHAVE_DRFFTW_H $[libtest $[FFTW_LPATH],drfftw]

// Is libsquish installed, and where?
#define SQUISH_IPATH $[DEFAULT_IPATH]
#define SQUISH_LPATH $[DEFAULT_LPATH]
#define SQUISH_LIBS $[if $[WINDOWS_PLATFORM], squish.lib, squish]
#defer HAVE_SQUISH $[libtest $[SQUISH_LPATH],$[SQUISH_LIBS]]

// Is VRPN installed, and where?
#define VRPN_IPATH $[DEFAULT_IPATH]
#define VRPN_LPATH $[DEFAULT_LPATH]
#define VRPN_LIBS $[if $[WINDOWS_PLATFORM], quat.lib vrpn.lib, quat vrpn]
#defer HAVE_VRPN $[libtest $[VRPN_LPATH],$[VRPN_LIBS]]

// Is ZLIB installed, and where?
#define ZLIB_IPATH $[DEFAULT_IPATH]
#define ZLIB_LPATH $[DEFAULT_LPATH]
#define ZLIB_LIBS $[if $[WINDOWS_PLATFORM], zlibstatic.lib, z]
#defer HAVE_ZLIB $[libtest $[ZLIB_LPATH],$[ZLIB_LIBS]]

// Is OpenGL installed, and where?
#defer GL_IPATH $[DEFAULT_IPATH]
#defer GL_LPATH $[DEFAULT_LPATH]
#defer GL_LIBS
#if $[WINDOWS_PLATFORM]
  #define GL_LIBS opengl32.lib
#elif $[OSX_PLATFORM]
  #defer GL_FRAMEWORK OpenGL
#else
  #defer GL_LIBS GL
#endif
#defer HAVE_GL $[libtest $[GL_LPATH],$[GL_LIBS]]

// If you are having trouble linking in OpenGL extension functions at
// runtime for some reason, you can set this variable.  This defines
// the minimum runtime version of OpenGL that Panda will require.
// Setting it to a higher version will compile in hard references to
// the extension functions provided by that OpenGL version and below,
// which may reduce runtime portability to other systems, but it will
// avoid issues with getting extension function pointers.  It also, of
// course, requires you to install the OpenGL header files and
// compile-time libraries appropriate to the version you want to
// compile against.

// The variable is the major, minor version of OpenGL, separated by a
// space (instead of a dot).  Thus, "1 1" means OpenGL version 1.1.
#define MIN_GL_VERSION 1 1

// Do you want to build tinydisplay, a light and fast software
// renderer built into Panda, based on TinyGL?  This isn't as
// full-featured as Mesa, but it is many times faster, and in fact
// competes favorably with hardware-accelerated integrated graphics
// cards for raw speed (though the hardware-accelerated output looks
// better).
#define HAVE_TINYDISPLAY 1

// Is OpenGL ES 1.x installed, and where? This is a minimal subset of
// OpenGL for mobile devices.
#define GLES_IPATH $[DEFAULT_IPATH]
#define GLES_LPATH $[DEFAULT_LPATH]
#define GLES_LIBS GLES_cm
#defer HAVE_GLES $[libtest $[GLES_LPATH],$[GLES_LIBS]]

// OpenGL ES 2.x is a version of OpenGL ES but without fixed-function
// pipeline - everything is programmable there.
#define GLES2_IPATH $[DEFAULT_IPATH]
#define GLES2_LPATH $[DEFAULT_LPATH]
#define GLES2_LIBS GLESv2
#defer HAVE_GLES2 $[libtest $[GLES2_LPATH],$[GLES2_LIBS]]

// EGL is like GLX, but for OpenGL ES.
#defer EGL_IPATH $[DEFAULT_IPATH]
#defer EGL_LPATH $[DEFAULT_LPATH]
#defer EGL_LIBS EGL
#defer HAVE_EGL $[libtest $[EGL_LPATH],$[EGL_LIBS]]

// The SDL library is useful only for tinydisplay, and is not even
// required for that, as tinydisplay is also supported natively on
// each supported platform.
#define SDL_IPATH $[DEFAULT_IPATH]
#define SDL_LPATH $[DEFAULT_LPATH]
#define SDL_LIBS
#defer HAVE_SDL $[libtest $[SDL_LPATH],$[SDL_LIBS]]

// X11 may need to be linked against for tinydisplay, but probably
// only on a Linux platform.
#define X11_IPATH $[DEFAULT_IPATH]
#define X11_LPATH $[DEFAULT_LPATH]
#define X11_LIBS X11
#defer HAVE_X11 $[and $[UNIX_PLATFORM],$[libtest $[X11_LPATH],$[X11_LIBS]]]

// How about GLX?
#define GLX_IPATH $[DEFAULT_IPATH]
#define GLX_LPATH $[DEFAULT_LPATH]
#defer HAVE_GLX $[and $[HAVE_GL],$[HAVE_X11]]

// glXGetProcAddress() is the function used to query OpenGL extensions
// under X.  However, this function is itself an extension function,
// leading to a chicken-and-egg problem.  One approach is to compile
// in a hard reference to the function, another is to pull the
// function address from the dynamic runtime.  Each has its share of
// problems.  Panda's default behavior is to pull it from the dynamic
// runtime; define this to compile in a reference to the function.
// This is only relevant from platforms using OpenGL under X (for
// instance, Linux).
#define LINK_IN_GLXGETPROCADDRESS

// Should we try to build the WGL interface?
#defer HAVE_WGL $[and $[HAVE_GL],$[WINDOWS_PLATFORM]]

// These interfaces are for OSX only.
#define HAVE_COCOA
#define HAVE_CARBON

// Is DirectX9 available, and should we try to build with it?
#define DX9_IPATH
#define DX9_LPATH
#define DX9_LIBS d3d9.lib d3dx9.lib dxerr9.lib
#defer HAVE_DX9 $[libtest $[DX9_LPATH],$[DX9_LIBS]]

// Set this nonempty to use <dxerr.h> instead of <dxerr9.h>.  The
// choice between the two is largely based on which version of the
// DirectX SDK(s) you might have installed.  The generic library is
// the default for 64-bit windows.
#defer USE_GENERIC_DXERR_LIBRARY $[WIN64_PLATFORM]

// Do we have at least OpenCV 2.3?
#define OPENCV_VER_23 1

// Is OpenCV installed, and where?
#define OPENCV_IPATH $[DEFAULT_IPATH]
#define OPENCV_LPATH $[DEFAULT_LPATH]
#defer OPENCV_LIBS $[if $[OPENCV_VER_23], opencv_highgui opencv_core, cv highgui cxcore]
#defer HAVE_OPENCV $[libtest $[OPENCV_LPATH],$[OPENCV_LIBS]]

// Is FFMPEG installed, and where?
#define FFMPEG_IPATH $[DEFAULT_IPATH]
#define FFMPEG_LPATH $[DEFAULT_LPATH]
#define FFMPEG_LIBS $[if $[WINDOWS_PLATFORM],avcodec.lib avformat.lib avutil.lib swscale.lib swresample.lib,avcodec avformat avutil swscale swresample]
#defer HAVE_FFMPEG $[libtest $[FFMPEG_LPATH],$[FFMPEG_LIBS]]
// Define this if you compiled ffmpeg with libswscale enabled.
#define HAVE_SWSCALE 1
#define HAVE_SWRESAMPLE 1

// Is ODE installed, and where?
#define ODE_IPATH $[DEFAULT_IPATH]
#define ODE_LPATH $[DEFAULT_LPATH]
#define ODE_LIBS $[if $[WINDOWS_PLATFORM],ode_single.lib,ode]
#define ODE_CFLAGS
#defer HAVE_ODE $[libtest $[ODE_LPATH],$[ODE_LIBS]]

#define HAVE_ACTIVEX $[WINDOWS_PLATFORM]

// Do you want to build the DirectD tools for starting Panda clients
// remotely?  This only affects the direct tree.  Enabling this may
// cause libdirect.dll to fail to load on Win98 clients.
#define HAVE_DIRECTD

// If your system supports the Posix threads interface
// (pthread_create(), etc.), define this true.
#define HAVE_POSIX_THREADS $[and $[isfile /usr/include/pthread.h],$[not $[WINDOWS_PLATFORM]]]

// Do you want to build in support for threading (multiprocessing)?
// Building in support for threading will enable Panda to take
// advantage of multiple CPU's if you have them (and if the OS
// supports kernel threads running on different CPU's), but it will
// slightly slow down Panda for the single CPU case, so this is not
// enabled by default.
#define HAVE_THREADS 1
#define THREADS_LIBS $[if $[not $[WINDOWS_PLATFORM]],pthread]

// If you have enabled threading support with HAVE_THREADS, the
// default is to use OS-provided threading constructs, which usually
// allows for full multiprogramming support (i.e. the program can take
// advantage of multiple CPU's).  On the other hand, compiling in this
// full OS-provided support can impose some substantial runtime
// overhead, making the application run slower on a single-CPU
// machine.  To avoid this overhead, but still gain some of the basic
// functionality of threads (such as support for asynchronous model
// loads), define SIMPLE_THREADS true in addition to HAVE_THREADS.
// This will compile in a homespun cooperative threading
// implementation that runs strictly on one CPU, adding very little
// overhead over plain single-threaded code.
#define SIMPLE_THREADS

// If this is defined true, then OS threading constructs will be used
// (if available) to perform context switches in the SIMPLE_THREADS
// model, instead of strictly user-space calls like setjmp/longjmp.  A
// mutex is used to ensure that only one thread runs at a time, so the
// normal SIMPLE_THREADS optimizations still apply, and the normal
// SIMPLE_THREADS scheduler is used to switch between threads (instead
// of the OS scheduler).  This may be more portable and more reliable,
// but it is a weird hybrid between user-space threads and os-provided
// threads.  This has meaning only if SIMPLE_THREADS is also defined.
#define OS_SIMPLE_THREADS 1

// Whether threading is defined or not, you might want to validate the
// thread and synchronization operations.  With threading enabled,
// defining this will also enable deadlock detection and logging.
// Without threading enabled, defining this will simply verify that a
// mutex is not recursively locked.  There is, of course, additional
// run-time overhead for these tests.
#defer DEBUG_THREADS $[<= $[OPTIMIZE], 2]

// Do you want to compile in support for pipelining?  This adds code
// to maintain a different copy of the scene graph for each thread in
// the render pipeline, so that app, cull, and draw may each safely
// run in a separate thread, allowing maximum parallelization of CPU
// processing for the frame.  Enabling this option does not *require*
// you to use separate threads for rendering, but makes it possible.
// However, compiling this option in does add some additional runtime
// overhead even if it is not used.  By default, we enable pipelining
// whenever threads are enabled, assuming that if you have threads,
// you also want to use pipelining.  We also enable it at OPTIMIZE
// level 1, since that enables additional runtime checks.
#defer DO_PIPELINING $[or $[<= $[OPTIMIZE], 1],$[HAVE_THREADS]]

// Define this true to implement mutexes and condition variables via
// user-space spinlocks, instead of via OS-provided constructs.  This
// is almost never a good idea, except possibly in very specialized
// cases when you are building Panda for a particular application, on
// a particular platform, and you are sure you won't have more threads
// than CPU's.  Even then, OS-based locking is probably better.
#define MUTEX_SPINLOCK

// Define this to use the PandaFileStream interface for pifstream,
// pofstream, and pfstream.  This is a customized file buffer that may
// have slightly better newline handling, but its primary benefit is
// that it supports SIMPLE_THREADS better by blocking just the active
// "thread" when I/O is delayed, instead of blocking the entire
// process.  Normally, there's no reason to turn this off, unless you
// suspect a bug in Panda.
#define USE_PANDAFILESTREAM 1

// Do you want to build the PStats interface, for graphical run-time
// performance statistics?  This requires NET to be available.  By
// default, we don't build PStats when OPTIMIZE = 4, although this is
// possible.
#defer DO_PSTATS $[or $[and $[HAVE_NET],$[< $[OPTIMIZE], 4]], $[DO_PSTATS]]

// Do you want to type-check downcasts?  This is a good idea during
// development, but does impose some run-time overhead.
#defer DO_DCAST $[< $[OPTIMIZE], 3]

// Do you want to build the debugging tools for recording and
// visualizing intersection tests by the collision system?  Enabling
// this increases runtime collision overhead just a tiny bit.
#defer DO_COLLISION_RECORDING $[< $[OPTIMIZE], 4]

// Do you want to include the "debug" and "spam" Notify messages?
// Normally, these are stripped out when we build with OPTIMIZE = 4, but
// sometimes it's useful to keep them around.  Redefine this in your
// own Config.pp to achieve that.
#defer NOTIFY_DEBUG $[< $[OPTIMIZE], 4]

// Do you want to build the audio interface?
#define HAVE_AUDIO 1

// The Tau profiler provides a multiplatform, thread-aware profiler.
// To use it, define USE_TAU to 1, and set TAU_MAKEFILE to the
// filename that contains the Tau-provided Makefile for your platform.
// Then rebuild the code with ppremake; make install.  Alternatively,
// instead of setting TAU_MAKEFILE, you can also define TAU_ROOT and
// PDT_ROOT, to point to the root directory of the tau and pdtoolkit
// installations, respectively; then the individual Tau components
// will be invoked directly.  This is especially useful on Windows,
// where there is no Tau Makefile.
#define TAU_MAKEFILE
#define TAU_ROOT
#define PDT_ROOT
#define TAU_OPTS -optKeepFiles -optRevert
#define TAU_CFLAGS
#define USE_TAU

// Info for the RAD game tools, Miles Sound System
// note this may be overwritten in wintools Config.pp
#define RAD_MSS_IPATH $[DEFAULT_IPATH]
#define RAD_MSS_LPATH $[DEFAULT_LPATH]
#define RAD_MSS_LIBS Mss32
#defer HAVE_RAD_MSS $[libtest $[RAD_MSS_LPATH],$[RAD_MSS_LIBS]]

// Info for the FMOD audio engine
#define FMOD_IPATH $[DEFAULT_IPATH]
#define FMOD_LPATH $[DEFAULT_LPATH]
#define FMOD_LIBS fmod
#defer HAVE_FMOD $[libtest $[FMOD_LPATH],$[FMOD_LIBS]]

// Info for the OpenAL audio engine
#define OPENAL_IPATH $[DEFAULT_IPATH]
#define OPENAL_LPATH $[DEFAULT_LPATH]
#if $[OSX_PLATFORM]
  #define OPENAL_LIBS
  #define OPENAL_FRAMEWORK OpenAL
#elif $[WINDOWS_PLATFORM]
  #define OPENAL_LIBS OpenAL32.lib
  #define OPENAL_FRAMEWORK
#else
  #define OPENAL_LIBS openal
  #define OPENAL_FRAMEWORK
#endif
#defer HAVE_OPENAL $[or $[OPENAL_FRAMEWORK],$[libtest $[OPENAL_LPATH],$[OPENAL_LIBS]]]

// Is gtk+-2 installed?  This is needed to build the pstats program on
// Unix (or non-Windows) platforms.  It is also used to provide
// support for XEmbed for the web plugin system, which is necessary to
// support Chromium on Linux.
#define PKG_CONFIG $[if $[not $[WINDOWS_PLATFORM]], pkg-config]
#define HAVE_GTK

// Do we have Freetype 2.0 (or better)?  If available, this package is
// used to generate dynamic in-the-world text from font files.

// On Unix, freetype comes with the freetype-config executable, which
// tells us where to look for the various files.  On Windows, we need to
// supply this information explicitly.
#defer FREETYPE_CONFIG $[if $[not $[WINDOWS_PLATFORM]],freetype-config]
#defer HAVE_FREETYPE $[or $[libtest $[FREETYPE_LPATH],$[FREETYPE_LIBS]],$[bintest $[FREETYPE_CONFIG]]]

#define FREETYPE_CFLAGS
#define FREETYPE_IPATH $[DEFAULT_IPATH]/freetype2
#define FREETYPE_LPATH $[DEFAULT_LPATH]
#define FREETYPE_LIBS $[if $[WINDOWS_PLATFORM],freetype.lib,freetype]

// Define this true to compile in a default font, so every TextNode
// will always have a font available without requiring the user to
// specify one.  Define it empty not to do this, saving a few
// kilobytes on the generated library.  Sorry, you can't pick a
// particular font to be the default; it's hardcoded in the source
// (although you can use the text-default-font prc variable to specify
// a particular font file to load as the default, overriding the
// compiled-in font).
#define COMPILE_IN_DEFAULT_FONT 1

// Define this true to compile a special version of Panda to use a
// "double" floating-precision type for most internal values, such as
// positions and transforms, instead of the standard single-precision
// "float" type.  This does not affect the default numeric type of
// vertices, which is controlled by the runtime config variable
// vertices-float64.
#define STDFLOAT_DOUBLE

// Is Maya installed?  This matters only to programs in PANDATOOL.

// Also, as of Maya 5.0 it seems the Maya library will not compile
// properly with optimize level 4 set (we get link errors with ostream).

#define MAYA_LOCATION /usr/autodesk/maya
#defer MAYA_LIBS $[if $[WINDOWS_PLATFORM],Foundation.lib OpenMaya.lib OpenMayaAnim.lib OpenMayaUI.lib,Foundation OpenMaya OpenMayaAnim OpenMayaUI]
// Optionally define this to the value of LM_LICENSE_FILE that should
// be set before invoking Maya.
#define MAYA_LICENSE_FILE
#defer HAVE_MAYA $[and $[<= $[OPTIMIZE], 3],$[isdir $[MAYA_LOCATION]/include/maya]]
// Define this if your version of Maya is earlier than 5.0 (e.g. Maya 4.5).
#define MAYA_PRE_5_0

#define MAYA2EGG maya2egg

// Is FCollada installed? This is for the daeegg converter.
#define FCOLLADA_IPATH $[DEFAULT_IPATH]
#define FCOLLADA_LPATH $[DEFAULT_LPATH]
#define FCOLLADA_LIBS FCollada
#defer HAVE_FCOLLADA $[libtest $[FCOLLADA_LPATH],$[FCOLLADA_LIBS]]

// The Assimp library loads various model formats.
#define ASSIMP_IPATH $[DEFAULT_IPATH]
#define ASSIMP_LPATH $[DEFAULT_LPATH]
#define ASSIMP_LIBS assimp
#define HAVE_ASSIMP $[libtest $[ASSIMP_LPATH],$[ASSIMP_LIBS]]

// Also for the ARToolKit library, for augmented reality
#define ARTOOLKIT_IPATH $[DEFAULT_IPATH]
#define ARTOOLKIT_LPATH $[DEFAULT_LPATH]
#define ARTOOLKIT_LIBS $[if $[WINDOWS_PLATFORM],libAR.lib,AR]
#defer HAVE_ARTOOLKIT $[libtest $[ARTOOLKIT_LPATH],$[ARTOOLKIT_LIBS]]

// libRocket is a GUI library
#define ROCKET_IPATH $[DEFAULT_IPATH]
#define ROCKET_LPATH $[DEFAULT_LPATH]
#define ROCKET_LIBS RocketCore RocketDebugger boost_python
#defer HAVE_ROCKET $[libtest $[ROCKET_LPATH],$[ROCKET_LIBS]]
#defer HAVE_ROCKET_DEBUGGER $[< $[OPTIMIZE],4]
// Unset this if you built libRocket without Python bindings
#defer HAVE_ROCKET_PYTHON $[and $[HAVE_ROCKET],$[HAVE_PYTHON]]

// Bullet is a physics engine
#define BULLET_IPATH $[DEFAULT_IPATH]/bullet
#define BULLET_LPATH $[DEFAULT_LPATH]
#if $[WINDOWS_PLATFORM]
#define BULLET_LIBS BulletSoftBody.lib BulletDynamics.lib BulletCollision.lib LinearMath.lib
#else
#define BULLET_LIBS BulletSoftBody BulletDynamics BulletCollision LinearMath
#endif
#defer HAVE_BULLET $[libtest $[BULLET_LPATH],$[BULLET_LIBS]]

// libvorbisfile is used for reading Ogg Vorbis audio files (.ogg).
#define VORBIS_IPATH $[DEFAULT_IPATH]
#define VORBIS_LPATH $[DEFAULT_LPATH]
#define VORBIS_LIBS $[if $[WINDOWS_PLATFORM],ogg.lib vorbis.lib vorbisfile.lib,ogg vorbis vorbisfile]
#defer HAVE_VORBIS $[libtest $[VORBIS_LPATH],$[VORBIS_LIBS]]

// libopusfile is used for reading Opus audio files (.opus).
#define OPUS_IPATH $[DEFAULT_IPATH] $[DEFAULT_IPATH]/opus
#define OPUS_LPATH $[DEFAULT_LPATH]
#define OPUS_LIBS $[if $[WINDOWS_PLATFORM], ogg.lib opus.lib opusfile.lib, ogg opus opusfile]
#defer HAVE_OPUS $[libtest $[OPUS_LPATH],$[OPUS_LIBS]]

// Is HarfBuzz installed?
#define HARFBUZZ_IPATH $[DEFAULT_IPATH]/harfbuzz
#define HARFBUZZ_LPATH $[DEFAULT_LPATH]
#define HARFBUZZ_LIBS $[if $[WINDOWS_PLATFORM], harfbuzz.lib, harfbuzz]
#defer HAVE_HARFBUZZ $[libtest $[HARFBUZZ_LPATH], $[HARFBUZZ_LIBS]]

// Is OpenEXR installed?
#define OPENEXR_IPATH $[DEFAULT_IPATH]/OpenEXR
#define OPENEXR_LPATH $[DEFAULT_LPATH]
#if $[WINDOWS_PLATFORM]
#define OPENEXR_LIBS IlmImf.lib Half.lib Imath.lib Iex.lib IlmThread.lib
#else
#define OPENEXR_LIBS IlmImf Imath Half Iex IlmThread
#endif
#defer HAVE_OPENEXR $[libtest $[OPENEXR_LPATH],$[OPENEXR_LIBS]]

// Is Valve's Game/SteamNetworkingSockets installed?
#define VALVE_STEAMNET_IPATH $[DEFAULT_IPATH]
#define VALVE_STEAMNET_LPATH $[DEFAULT_LPATH]
#define VALVE_STEAMNET_LIBS $[if $[WINDOWS_PLATFORM], GameNetworkingSockets.lib, GameNetworkingSockets]
#defer VALVE_STEAMNET_CFLAGS $[if $[or $[UNIX_PLATFORM],$[OSX_PLATFORM]], -DPOSIX]
#defer HAVE_VALVE_STEAMNET $[libtest $[VALVE_STEAMNET_LPATH], $[VALVE_STEAMNET_LIBS]]

// Is GLslang installed, and where?
#define GLSLANG_IPATH $[DEFAULT_IPATH]
#define GLSLANG_LPATH $[DEFAULT_LPATH]
#define GLSLANG_LIBS \
  $[if $[WINDOWS_PLATFORM], \
    glslang.lib HLSL.lib OGLCompiler.lib OSDependent.lib SPIRV.lib, \
    glslang HLSL OGLCompiler OSDependent SPIRV]
#defer HAVE_GLSLANG $[libtest $[GLSLANG_LPATH], $[GLSLANG_LIBS]]

// Is spirv-tools installed, and where?
#define SPIRV_TOOLS_IPATH $[DEFAULT_IPATH]
#define SPIRV_TOOLS_LPATH $[DEFAULT_LPATH]
#define SPIRV_TOOLS_LIBS \
  $[if $[WINDOWS_PLATFORM], \
    SPIRV-Tools.lib SPIRV-Tools-opt.lib, \
    SPIRV-Tools SPIRV-Tools-opt]
#defer HAVE_SPIRV_TOOLS $[libtest $[SPIRV_TOOLS_LPATH], $[SPIRV_TOOLS_LIBS]]

// Is spirv-cross installed, and where?
#define SPIRV_CROSS_IPATH $[DEFAULT_IPATH]
#define SPIRV_CROSS_LPATH $[DEFAULT_LPATH]
#define SPIRV_CROSS_LIBS $[if $[WINDOWS_PLATFORM], spirv-cross-core.lib spirv-cross-glsl.lib, spirv-cross-core spirv-cross-glsl]
#defer HAVE_SPIRV_CROSS $[libtest $[SPIRV_CROSS_LPATH], $[SPIRV_CROSS_LIBS]]

// Is Intel Embree installed, and where?
#define EMBREE_IPATH $[DEFAULT_IPATH]
#define EMBREE_LPATH $[DEFAULT_LPATH]
#define EMBREE_LIBS $[if $[WINDOWS_PLATFORM], embree3.lib tbb.lib, embree3 tbb]
#defer HAVE_EMBREE $[libtest $[EMBREE_LPATH], $[EMBREE_LIBS]]

// Define this to explicitly indicate the given platform string within
// the resulting Panda runtime.  Normally it is best to leave this
// undefined, in which case Panda will determine the best value
// automatically.
#define DTOOL_PLATFORM

// Define this to generate static libraries and executables, rather than
// dynamic libraries.
//#define LINK_ALL_STATIC yes

// The panda source tree is made up of a bunch of component libraries
// (e.g. express, downloader, pgraph, egg) which are ultimately
// combined into a smaller group of meta libraries or metalibs
// (e.g. libpandaexpress, libpanda, libpandaegg).  Depending on your
// build configuration, these component libraries might have their own
// existence, or they might disappear completely and be contained
// entirely within their metalibs.  The former is more convenient for
// rapid development, while the latter might be more convenient for
// distribution.

// Define this variable to compile and link each component as a
// separate library so that the resulting metalibs are small and there
// are many separate component libraries; leave it undefined to link
// component object files directly into their containing metalibs so
// that the resulting metalib files are large and component libraries
// don't actually exist.  The Windows has traditionally been built
// with this cleared (because of the original Win32 STL requirements),
// while the Unix build has traditionally been built with it set.
// Changing this from the traditional platform-specific setting is not
// 100% supported yet.
#define BUILD_COMPONENTS $[not $[WINDOWS_PLATFORM]]

// We need this linker flag when building component libraries and stub
// metalibraries on Unix, so that the static initialization functions
// are called in the metalibraries when imported via a Python module.
// I don't know if this is the best place for this, but seems to work.
#define NO_LINK_WHAT_YOU_USE -Wl,--no-as-needed
#defer LFLAGS $[if $[and $[not $[WINDOWS_PLATFORM]], $[BUILD_COMPONENTS]], $[NO_LINK_WHAT_YOU_USE]]

// Define this variable to generate a composite source file for each
// library, and compile that instead of the individual source files.
// This increases build speed, but uses more memory.
#define USE_SINGLE_COMPOSITE_SOURCEFILE 1

// Define this to export the templates from the DLL.  This is only
// meaningful if LINK_ALL_STATIC is not defined, and we are building
// on Windows.  Some Windows compilers may not support this syntax.
#defer EXPORT_TEMPLATES yes

// Define this to generate .bat files when a Sources.pp makes a
// script; leave it clear to generate Unix-style sh scripts.
#defer MAKE_BAT_SCRIPTS $[or $[eq $[PLATFORM],Win32],$[eq $[PLATFORM],Win64]]

// Define USE_COMPILER to switch the particular compiler that should
// be used.  A handful of tokens are recognized, depending on BUILD_TYPE.
// This may also be further customized within Global.$[BUILD_TYPE].pp.

// If BUILD_TYPE is "unix", this may be one of:
//    GCC    (gcc/g++)
//    MIPS   (Irix MIPSPro compiler)
//
// If BUILD_TYPE is "msvc" or "gmsvc", this may be one of:
//    MSVC     (Microsoft Visual C++ 6.0)
//    MSVC7    (Microsoft Visual C++ 7.0)
//    MSVC14.2 (Microsoft Visual C++ 14.2)
//    BOUNDS   (BoundsChecker)
//    INTEL    (Intel C/C++ compiler)

#if $[WINDOWS_PLATFORM]
  #if $[eq $[USE_COMPILER],]
    #define USE_COMPILER MSVC14.2x64
  #endif
#elif $[eq $[PLATFORM], Irix]
  #define USE_COMPILER MIPS
#elif $[eq $[PLATFORM], Linux]
  #define USE_COMPILER GCC
#elif $[OSX_PLATFORM]
  #define USE_COMPILER GCC
#elif $[eq $[PLATFORM], FreeBSD]
  #define USE_COMPILER GCC
#endif

// Permission masks to install data and executable files,
// respectively.  This is only meaningful for Unix systems.
#define INSTALL_UMASK_DATA 644
#define INSTALL_UMASK_PROG 755

// How to invoke bison and flex.  Panda takes advantage of some
// bison/flex features, and therefore specifically requires bison and
// flex, not some other versions of yacc and lex.  However, you only
// need to have these programs if you need to make changes to the
// bison or flex sources (see the next point, below).
#defer BISON bison
#defer FLEX flex

// You may not even have bison and flex installed.  If you don't, no
// sweat; Panda ships with the pre-generated output of these programs,
// so you don't need them unless you want to make changes to the
// grammars themselves (files named *.yxx or *.lxx).
#defer HAVE_BISON $[bintest $[BISON]]

// How to invoke sed.  A handful of make rules use this.  Since some
// platforms (specifically, non-Unix platforms like Windows) don't
// have any kind of sed, ppremake performs some limited sed-like
// functions.  The default is to use ppremake in this capacity.  In
// this variable, $[source] is the name of the file to read, $[target]
// is the name of the file to generate, and $[script] is the one-line
// sed script to run.
#defer SED ppremake -s "$[script]" <$[source] >$[target]

// What directory name (within each source directory) should the .o
// (or .obj) files be written to?  This can be any name, and it can be
// used to differentiate different builds within the same tree.
// However, don't define this to be '.', or you will be very sad the
// next time you run 'make clean'.
//#defer ODIR Opt$[OPTIMIZE]-$[PLATFORM]$[USE_COMPILER]
// ODIR_SUFFIX is optional, usually empty
#defer ODIR Opt$[OPTIMIZE]-$[PLATFORM]$[ODIR_SUFFIX]


// What is the normal extension of a compiled object file?
#if $[WINDOWS_PLATFORM]
  #define OBJ .obj
#else
  #define OBJ .o
#endif


//////////////////////////////////////////////////////////////////////
// There are also some additional variables that control specific
// compiler/platform features or characteristics, defined in the
// platform specific file Config.platform.pp.  Be sure to inspect
// these variables for correctness too.
//////////////////////////////////////////////////////////////////////
