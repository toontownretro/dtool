//
// LocalSetup.pp
//
// This file contains further instructions to set up the DTOOL package
// when using ppremake.  In particular, it creates the dtool_config.h
// file based on the user's selected configure variables.  This script
// need not execute when BUILD_TYPE is "autoconf"; in this case, the
// dtool_config.h file will automatically be correctly generated by
// configure.
//

#output dtool_config.h notouch
#format straight
/* dtool_config.h.  Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. */

/* Define if we have Python installed.  */
$[cdefine HAVE_PYTHON]
/* Define if we have Python as a framework (Mac OS X).  */
$[cdefine PYTHON_FRAMEWORK]

/* Define if we have RAD game tools, Miles Sound System installed.  */
$[cdefine HAVE_RAD_MSS]

/* Define if we have FMOD installed. */
$[cdefine HAVE_FMOD]

/* Define if we have Freetype 2.0 or better available. */
$[cdefine HAVE_FREETYPE]

/* Define if we want to compile in a default font. */
$[cdefine COMPILE_IN_DEFAULT_FONT]

/* Define if we have Maya available. */
$[cdefine HAVE_MAYA]
$[cdefine MAYA_PRE_5_0]

/* Define if we have SoftImage available. */
$[cdefine HAVE_SOFTIMAGE]

/* Define if we have NSPR installed.  */
$[cdefine HAVE_NSPR]

/* Define if we have OpenSSL installed.  */
$[cdefine HAVE_SSL]
$[cdefine SSL_097]
$[cdefine REPORT_OPENSSL_ERRORS]

/* Define if we have libjpeg installed.  */
$[cdefine HAVE_JPEG]

/* Define if we have libpng installed.  */
$[cdefine HAVE_PNG]

/* Define if we have libtiff installed.  */
$[cdefine HAVE_TIFF]

/* Define if we have libfftw installed.  */
$[cdefine HAVE_FFTW]

/* Define if we have NURBS++ installed.  */
$[cdefine HAVE_NURBSPP]

/* Define if we have VRPN installed.  */
$[cdefine HAVE_VRPN]

/* Define if we have zlib installed.  */
$[cdefine HAVE_ZLIB]

/* Define if we have OpenGL installed and want to build for GL.  */
$[cdefine HAVE_GL]

/* Define if we have Mesa installed and want to build mesadisplay.  */
$[cdefine HAVE_MESA]
$[cdefine MESA_MGL]

/* Define if we want to build with SGI OpenGL extensions.  */
$[cdefine HAVE_SGIGL]

/* Define if we have GLX installed and want to build for GLX.  */
$[cdefine HAVE_GLX]

/* Define if we have Windows-GL installed and want to build for Wgl.  */
$[cdefine HAVE_WGL]

/* Define if we have DirectX installed and want to build for DX.  */
$[cdefine HAVE_DX]

/* Define if we have Chromium installed and want to use it.  */
$[cdefine HAVE_CHROMIUM]

/* Define if we want to compile the threading code.  */
$[cdefine HAVE_THREADS]

/* Define if we want to compile the net code.  */
$[cdefine HAVE_NET]

/* Define if we want to compile the audio code.  */
$[cdefine HAVE_AUDIO]

/* Define if we have bison and flex available. */
$[cdefine HAVE_BISON]

/* Define if we want to use PStats.  */
$[cdefine DO_PSTATS]

/* Define if we want to provide collision system recording and
   visualization tools. */
$[cdefine DO_COLLISION_RECORDING]

/* Define if we want to track callbacks from within the show code.  */
$[cdefine TRACK_IN_INTERPRETER]

/* Define if we want to enable track-memory-usage.  */
$[cdefine DO_MEMORY_USAGE]

/* Define if we want to compile in support for pipelining.  */
$[cdefine DO_PIPELINING]

/* Define if we want to keep Notify debug messages around, or undefine 
   to compile them out.  */
$[cdefine NOTIFY_DEBUG]

/* Define if we want to export template classes from the DLL.  Only
   makes sense to MSVC++. */
$[cdefine EXPORT_TEMPLATES]

/* Define if we are linking PANDAGL in with PANDA. */
$[cdefine LINK_IN_GL]

/* Define if we are linking PANDAPHYSICS in with PANDA. */
$[cdefine LINK_IN_PHYSICS]

/* Define if your processor stores words with the most significant
   byte first (like Motorola and SPARC, unlike Intel and VAX).  */
$[cdefine WORDS_BIGENDIAN]

/* Define if the C++ compiler uses namespaces.  */
$[cdefine HAVE_NAMESPACE]

/* Define if fstream::open() accepts a third parameter for umask. */
$[cdefine HAVE_OPEN_MASK]

/* Define if some header file defines wchar_t. */
$[cdefine HAVE_WCHAR_T]

/* Define if the <string> header file defines wstring. */
$[cdefine HAVE_WSTRING]

/* Define if the C++ compiler supports the typename keyword.  */
$[cdefine HAVE_TYPENAME]

/* Define if we can trust the compiler not to insert extra bytes in
   structs between base structs and derived structs. */
$[cdefine SIMPLE_STRUCT_POINTERS]

/* Define if we have Dinkumware STL installed.  */
$[cdefine HAVE_DINKUM]

/* Define if we have a gettimeofday() function. */
$[cdefine HAVE_GETTIMEOFDAY]

/* Define if gettimeofday() takes only one parameter. */
$[cdefine GETTIMEOFDAY_ONE_PARAM]

/* Define if you have the getopt function.  */
$[cdefine HAVE_GETOPT]

/* Define if you have the getopt_long_only function.  */
$[cdefine HAVE_GETOPT_LONG_ONLY]

/* Define if getopt appears in getopt.h.  */
$[cdefine HAVE_GETOPT_H]

/* Define if you have ioctl(TIOCGWINSZ) to determine terminal width. */
$[cdefine IOCTL_TERMINAL_WIDTH]

/* Do the system headers define a "streamsize" typedef? */
$[cdefine HAVE_STREAMSIZE]

/* Do the system headers define key ios typedefs like ios::openmode
   and ios::fmtflags? */
$[cdefine HAVE_IOS_TYPEDEFS]

/* Define if the C++ iostream library defines ios::binary.  */
$[cdefine HAVE_IOS_BINARY]

/* Can we safely call getenv() at static init time? */
$[cdefine STATIC_INIT_GETENV]

/* Can we read the file /proc/self/environ to determine our
   environment variables at static init time? */
$[cdefine HAVE_PROC_SELF_ENVIRON]

/* Do we have a global pair of argc/argv variables that we can read at
   static init time?  Should we prototype them?  What are they called? */
$[cdefine HAVE_GLOBAL_ARGV]
$[cdefine PROTOTYPE_GLOBAL_ARGV]
$[cdefine GLOBAL_ARGV]
$[cdefine GLOBAL_ARGC]

/* Can we read the file /proc/self/cmdline to determine our
   command-line arguments at static init time? */
$[cdefine HAVE_PROC_SELF_CMDLINE]

/* Define if you have the <io.h> header file.  */
$[cdefine HAVE_IO_H]

/* Define if you have the <iostream> header file.  */
$[cdefine HAVE_IOSTREAM]

/* Define if you have the <malloc.h> header file.  */
$[cdefine HAVE_MALLOC_H]

/* Define if you have the <alloca.h> header file.  */
$[cdefine HAVE_ALLOCA_H]

/* Define if you have the <locale.h> header file.  */
$[cdefine HAVE_LOCALE_H]

/* Define if you have the <minmax.h> header file.  */
$[cdefine HAVE_MINMAX_H]

/* Define if you have the <sstream> header file.  */
$[cdefine HAVE_SSTREAM]

/* Define if you have the <new> header file.  */
$[cdefine HAVE_NEW]

/* Define if you have the <sys/types.h> header file.  */
$[cdefine HAVE_SYS_TYPES_H]

/* Define if you have the <sys/time.h> header file.  */
$[cdefine HAVE_SYS_TIME_H]

/* Define if you have the <unistd.h> header file.  */
$[cdefine HAVE_UNISTD_H]

/* Define if you have the <utime.h> header file.  */
$[cdefine HAVE_UTIME_H]

/* Define if you have the <glob.h> header file.  */
$[cdefine HAVE_GLOB_H]

/* Define if you have the <dirent.h> header file.  */
$[cdefine HAVE_DIRENT_H]

/* Do we have <sys/soundcard.h> (and presumably a Linux-style audio
   interface)? */
$[cdefine HAVE_SYS_SOUNDCARD_H]

/* Do we have RTTI (and <typeinfo>)? */
$[cdefine HAVE_RTTI]

/* Must global operator new and delete functions throw exceptions? */
$[cdefine GLOBAL_OPERATOR_NEW_EXCEPTIONS]

/* What style STL allocator should we declare? */
#define OLD_STYLE_ALLOCATOR
#define GNU_STYLE_ALLOCATOR
#define VC6_STYLE_ALLOCATOR
#define MODERN_STYLE_ALLOCATOR
#define NO_STYLE_ALLOCATOR
#if $[eq $[OPTIMIZE], 4]
  // In optimize level 4, we never try to use custom allocators.
  #set NO_STYLE_ALLOCATOR 1
#elif $[eq $[STL_ALLOCATOR], OLD]
  // "OLD": Irix 6.2-era STL.
  #set OLD_STYLE_ALLOCATOR 1
#elif $[eq $[STL_ALLOCATOR], GNU]
  // "GNU": gcc 2.95-era.
  #set GNU_STYLE_ALLOCATOR 1
#elif $[eq $[STL_ALLOCATOR], VC6]
  // "VC6": Microsoft Visual C++ 6.
  #set VC6_STYLE_ALLOCATOR 1
#elif $[eq $[STL_ALLOCATOR], MODERN]
  // "MODERN": Have we finally come to a standard?
  #set MODERN_STYLE_ALLOCATOR 1
#else
  // Anything else is "unknown".  We won't try to define allocators at
  // all.
  #set NO_STYLE_ALLOCATOR 1
#endif
$[cdefine OLD_STYLE_ALLOCATOR]
$[cdefine GNU_STYLE_ALLOCATOR]
$[cdefine VC6_STYLE_ALLOCATOR]
$[cdefine MODERN_STYLE_ALLOCATOR]
$[cdefine NO_STYLE_ALLOCATOR]

#end dtool_config.h
