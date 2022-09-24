//
// Config.Win32.pp
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

// What additional flags should we pass to interrogate?
#define SYSTEM_IGATE_FLAGS $[if $[WIN64_PLATFORM], -D_X64 -DWIN64_VC -DWIN64 -D_WIN64, -D_X86_ -DWIN32 -DWIN32_VC] -D__int64 -D"_declspec(param)=" -D"__declspec(param)=" -D_near  -D_far -D__near  -D__far -D_WIN32 -D__stdcall -Dvolatile -Dmutable

// Additional flags to pass to the Tau instrumentor.
#define TAU_INSTRUMENTOR_FLAGS -DTAU_USE_C_API -DPROFILING_ON -DWIN32_VC -D_WIN32 -D__cdecl= -D__stdcall= -D__fastcall= -D__i386 -D_MSC_VER=1310 -D_W64=  -D_INTEGRAL_MAX_BITS=64 --exceptions --late_tiebreaker --no_class_name_injection --no_warnings --restrict --microsoft --new_for_init

// Is the platform big-endian (like an SGI workstation) or
// little-endian (like a PC)?  Define this to the empty string to
// indicate little-endian, or nonempty to indicate big-endian.
#define WORDS_BIGENDIAN

// Does the C++ compiler support namespaces?
#define HAVE_NAMESPACE 1

// Does the C++ compiler support ios::binary?
#define HAVE_IOS_BINARY 1

// How about the typename keyword?
#define HAVE_TYPENAME 1

// Will the compiler avoid inserting extra bytes in structs between a
// base struct and its derived structs?  It is safe to define this
// false if you don't know, but if you know that you can get away with
// this you may gain a tiny performance gain by defining this true.
// If you define this true incorrectly, you will get lots of
// assertion failures on execution.
#define SIMPLE_STRUCT_POINTERS 1

// Does gettimeofday() take only one parameter?
#define GETTIMEOFDAY_ONE_PARAM

// Do we have getopt() and/or getopt_long_only() built into the
// system?
#define HAVE_GETOPT
#define HAVE_GETOPT_LONG_ONLY

// Are the above getopt() functions defined in getopt.h, or somewhere else?
#define PHAVE_GETOPT_H

// Can we determine the terminal width by making an ioctl(TIOCGWINSZ) call?
#define IOCTL_TERMINAL_WIDTH

// Do the system headers define a "streamsize" typedef?  How about the
// ios::binary enumerated value?  And other ios typedef symbols like
// ios::openmode and ios::fmtflags?
#define HAVE_STREAMSIZE 1
#define HAVE_IOS_BINARY 1
#define HAVE_IOS_TYPEDEFS 1

// Can we safely call getenv() at static init time?
#define STATIC_INIT_GETENV 1

// Can we read the file /proc/self/* to determine our
// environment variables at static init time?
#define HAVE_PROC_SELF_EXE
#define HAVE_PROC_SELF_MAPS
#define HAVE_PROC_SELF_ENVIRON
#define HAVE_PROC_SELF_CMDLINE

// Do we have a global pair of argc/argv variables that we can read at
// static init time?  Should we prototype them?  What are they called?
#define HAVE_GLOBAL_ARGV 1
#define PROTOTYPE_GLOBAL_ARGV
#define GLOBAL_ARGV __argv
#define GLOBAL_ARGC __argc

// Should we include <iostream> or <iostream.h>?  Define PHAVE_IOSTREAM
// to nonempty if we should use <iostream>, or empty if we should use
// <iostream.h>.
#define PHAVE_IOSTREAM 1

// Do we have a true stringstream class defined in <sstream>?
#define PHAVE_SSTREAM 1

// Does fstream::open() require a third parameter, specifying the
// umask?
#define HAVE_OPEN_MASK

// Do we have the lockf() function available?
#define PHAVE_LOCKF 1

// Do the compiler or system libraries define wchar_t for you?
#define HAVE_WCHAR_T 1

// Does <string> define the typedef wstring?  Most do, but for some
// reason, versions of gcc before 3.0 didn't do this.
#define HAVE_WSTRING 1

// Do we have <new>?
#define PHAVE_NEW 1

// Do we have <io.h>?
#define PHAVE_IO_H 1

// Do we have <malloc.h>?
#define PHAVE_MALLOC_H 1

// Do we have <alloca.h>?
#define PHAVE_ALLOCA_H

// Do we have <locale.h>?
#define PHAVE_LOCALE_H

// Do we have <string.h>?
#define PHAVE_STRING_H 1

// Do we have <stdlib.h>?
#define PHAVE_STDLIB_H

// Do we have <limits.h>?
#define PHAVE_LIMITS_H

// Do we have <minmax.h>?
#define PHAVE_MINMAX_H 1

// Do we have <sys/types.h>?
#define PHAVE_SYS_TYPES_H 1
#define PHAVE_SYS_TIME_H

// Do we have <unistd.h>?
#define PHAVE_UNISTD_H

// Do we have <utime.h>?
#define PHAVE_UTIME_H

// Do we have <dirent.h>?
#define PHAVE_DIRENT_H

// Do we have <sys/soundcard.h> (and presumably a Linux-style audio
// interface)?
#define PHAVE_SYS_SOUNDCARD_H

// Do we have <ucontext.h> (and therefore makecontext() / swapcontext())?
#define PHAVE_UCONTEXT_H

// Do we have RTTI (and <typeinfo>)?
#define HAVE_RTTI 1

// Do we have <stdint.h>?
#define PHAVE_STDINT_H

// can Intel C++ build this directory successfully (if not, change CC to msvc)
#define NOT_INTEL_BUILDABLE false

// The dynamic library file extension (usually .so .dll or .dylib):
#define DYNAMIC_LIB_EXT .dll
#define STATIC_LIB_EXT .lib
#define PROG_EXT .exe
#define BUNDLE_EXT

// The Python module file extension
#define PYTHON_MODULE_EXT .pyd

// Use AVX instructions on Win64, SSE2 on Win32
#define ARCH_FLAGS $[if $[WIN64_PLATFORM], /arch:AVX, /arch:SSE2]

// How to install files and programs.  On Windows, this just copies the file.
#defer INSTALL $[COPY_CMD $[local], $[dest]]
#defer INSTALL_PROG $[INSTALL]

// What define variables should be passed to the compilers for each
// value of OPTIMIZE?  We separate this so we can pass these same
// options to interrogate, guaranteeing that the correct interfaces
// are generated.  Do not include -D here; that will be supplied
// automatically.
#defer CDEFINES_OPT1 $[EXTRA_CDEFS]
#defer CDEFINES_OPT2 $[EXTRA_CDEFS]
#defer CDEFINES_OPT3 $[EXTRA_CDEFS]
#defer CDEFINES_OPT4 $[EXTRA_CDEFS]

#define CFLAGS_SHARED /D_USE_MATH_DEFINES

#define DO_CROSSOBJ_OPT 1

// Should debugging information for object files be embedded into the
// object file or outputted to a separate .pdb file?  This is forced
// to true when using Clang.
#define EMBED_OBJECT_DEBUG_INFO

#defer DEBUGFLAGS $[if $[ne $[LINK_FORCE_STATIC_RELEASE_C_RUNTIME],],/MTd, /MDd] $[BROWSEINFO_FLAG] $[DEBUGINFOFLAGS] $[DEBUGPDBFLAGS]
#defer RELEASEFLAGS $[if $[ne $[LINK_FORCE_STATIC_RELEASE_C_RUNTIME],],/MT, /MD]

// What additional flags should be passed for each value of OPTIMIZE
// (above)?  We separate out the compiler-optimization flags, above,
// so we can compile certain files that give optimizers trouble (like
// the output of lex and yacc) without them, but with all the other
// relevant flags.
#defer CFLAGS_OPT1 $[CDEFINES_OPT1:%=/D%] $[COMMONFLAGS] $[DEBUGFLAGS] $[OPT1FLAGS] $[DEBUGPDBFLAGS]
#defer CFLAGS_OPT2 $[CDEFINES_OPT2:%=/D%] $[COMMONFLAGS] $[DEBUGFLAGS] $[if $[no_opt],$[OPT1FLAGS],$[OPTFLAGS]] $[DEBUGPDBFLAGS]
#defer CFLAGS_OPT3 $[CDEFINES_OPT3:%=/D%] $[COMMONFLAGS] $[RELEASEFLAGS] $[if $[no_opt],$[OPT1FLAGS],$[OPTFLAGS]] $[DEBUGPDBFLAGS]
#defer CFLAGS_OPT4 $[CDEFINES_OPT4:%=/D%] $[COMMONFLAGS] $[RELEASEFLAGS] $[if $[no_opt],$[OPT1FLAGS],$[OPTFLAGS] $[OPT4FLAGS]]

// What flags should be passed to the linker for each value of optimize?
#defer LFLAGS_OPT1 $[LINKER_FLAGS] $[LFLAGS_OPT1]
#defer LFLAGS_OPT2 $[LINKER_FLAGS] $[LFLAGS_OPT2]
#defer LFLAGS_OPT3 $[LINKER_FLAGS] $[LFLAGS_OPT3]
#defer LFLAGS_OPT4 $[LINKER_FLAGS] $[LFLAGS_OPT4]

#define COMMONFLAGS /Zc:forScope /bigobj /Gd /fp:fast /MP

#define SMALL_OPTFLAGS /O1
#define FAST_OPTFLAGS /Ox

#defer OPTFLAGS $[if $[OPT_MINSIZE],$[SMALL_OPTFLAGS],$[FAST_OPTFLAGS]]

#define OPT1FLAGS /RTCs /GS

#define WARNING_LEVEL_FLAG /W3

// Note: Clang does not support /Zi, so /Z7 must be used instead.  /Zi causes
// a full rebuild every time on Clang.  Furthermore, we can't use /Zi with /GL.

#defer HAVE_DEBUG_INFORMATION $[< $[OPTIMIZE], 4]

#defer DEBUGPDBFLAGS $[if $[HAVE_DEBUG_INFORMATION], $[if $[EMBED_OBJECT_DEBUG_INFO], /Z7, /Zi /Fd"$[osfilename $[patsubst %.obj,%.pdb, $[target]]]"]]

// Linker flags shared between lib.exe and link.exe
#define LINKER_FLAGS $[if $[WIN64_PLATFORM], /MACHINE:X64, /MACHINE:X86]
#defer LINKER_FLAGS_DYNAMIC $[if $[HAVE_DEBUG_INFORMATION], /DEBUG] /fixed:no /incremental:no /stack:4194304
#define LINKER_FLAGS_STATIC

#define C++FLAGS_GEN /DWIN32_VC /DWIN32=1 /D_HAS_STD_BYTE=0 \
                     /std:c++17 /D_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS \
                     /D_ENABLE_EXTENDED_ALIGNED_STORAGE /D_HAS_EXCEPTIONS=0

// How to compile a C or C++ file into a .obj file.  $[target] is the
// name of the .obj file, $[source] is the name of the source file,
// $[ipath] is a space-separated list of directories to search for
// include files, and $[flags] is a list of additional flags to pass
// to the compiler.
#defer COMPILE_C $[COMPILER] $[patsubst -D%,/D%,$[CFLAGS_GEN] $[ARCH_FLAGS]] /c /Fo"$[osfilename $[target]]" \
                 $[patsubst %,-I$[osfilename %],$[ipath]] $[patsubst -D%,/D%,$[flags]] "$[osfilename $[source]]"
#defer COMPILE_C++ $[COMPILER] $[patsubst -D%,/D%,$[C++FLAGS_GEN] $[ARCH_FLAGS]] /c /Fo"$[osfilename $[target]]" \
                   $[patsubst %,-I$[osfilename %],$[ipath]] $[patsubst -D%,/D%,$[flags]] "$[osfilename $[source]]"

// How to generate a static C or C++ library.  $[target] is the
// name of the library to generate, and $[sources] is the list of .obj
// files that will go into the library.
#defer STATIC_LIB_C $[LIBBER] $[LINKER_FLAGS_STATIC] $[flags] /OUT:"$[osfilename $[target]]" $[osfilename $[sources]]
#defer STATIC_LIB_C++ $[STATIC_LIB_C]

// How to generate a shared C or C++ library.  $[source] and $[target]
// as above, and $[libs] is a space-separated list of dependent
// libraries, and $[lpath] is a space-separated list of directories in
// which those libraries can be found.
#defer SHARED_LIB_C $[LINKER] /DLL $[LINKER_FLAGS_DYNAMIC] $[flags] /OUT:"$[osfilename $[target]]" $[osfilename $[sources]] $[patsubst %,/LIBPATH:"$[osfilename %]",$[lpath] $[EXTRA_LIBPATH] $[tau_lpath]] $[patsubst %.lib,%.lib,%,lib%.lib,$[libs]] $[tau_libs]
#defer SHARED_LIB_C++ $[SHARED_LIB_C]

// How to generate a C or C++ executable from a collection of .obj
// files.  $[target] is the name of the binary to generate, and
// $[sources] is the list of .obj files.  $[libs] is a space-separated
// list of dependent libraries, and $[lpath] is a space-separated list
// of directories in which those libraries can be found.
#defer LINK_BIN_C $[LINKER] $[LINKER_FLAGS_DYNAMIC] $[flags] $[osfilename $[sources]] $[patsubst %,/LIBPATH:"$[osfilename %]",$[lpath] $[EXTRA_LIBPATH] $[tau_lpath]] $[patsubst %.lib,%.lib,%,lib%.lib,$[libs]] $[tau_libs] /OUT:"$[osfilename $[target]]"
#defer LINK_BIN_C++ $[LINK_BIN_C]

#define build_pdbs 1

#define MSBUILD_PLATFORM_TOOLSET v142
