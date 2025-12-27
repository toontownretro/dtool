// This file is included after including all of $DTOOL/Config.pp and
// the user's personal Config.pp file.  It makes decisions necessary
// following the user's Config settings.

// Force disable RTTI on release builds.
#if $[>= $[OPTIMIZE],4]
  #define HAVE_RTTI
#endif

// Force disable for now.
#define HAVE_RTTI

#if $[and $[OSX_PLATFORM],$[BUILD_IPHONE]]
  //#define IPH_PLATFORM iPhoneSimulator
  #define IPH_PLATFORM $[BUILD_IPHONE]
  #define IPH_VERSION 2.0

  #if $[eq $[IPH_PLATFORM], iPhoneOS]
    #define ARCH_FLAGS -arch armv6 -mcpu=arm1176jzf-s
    #define osflags -fpascal-strings -fasm-blocks -miphoneos-version-min=2.0
    #define DEBUGFLAGS -gdwarf-2
    //#define DEBUGFLAGS
  #elif $[eq $[IPH_PLATFORM], iPhoneSimulator]
    #define ARCH_FLAGS -arch i386
    #define osflags -fpascal-strings -fasm-blocks -mmacosx-version-min=10.5
    #define DEBUGFLAGS -gdwarf-2
  #else
    #error Inappropriate value for BUILD_IPHONE.
  #endif

  #define dev /Developer/Platforms/$[IPH_PLATFORM].platform/Developer
  #define env env MACOSX_DEPLOYMENT_TARGET=10.5 PATH="$[dev]/usr/bin:/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  #define CC $[env] $[dev]/usr/bin/gcc-4.0
  #define CXX $[env] $[dev]/usr/bin/g++-4.0
  #define OSX_CDEFS __IPHONE_OS_VERSION_MIN_REQUIRED=20000
  #define OSX_CFLAGS -isysroot $[dev]/SDKs/$[IPH_PLATFORM]$[IPH_VERSION].sdk $[osflags]

  #defer ODIR_SUFFIX -$[IPH_PLATFORM]
#endif

#if $[eq $[PLATFORM], Android]

// These are the flags also used by Android's own ndk-build.
#if $[eq $[ANDROID_ARCH],arm]
#define target_cflags\
 -fpic\
 -ffunction-sections\
 -funwind-tables\
 -fstack-protector\
 -D__ARM_ARCH_5__ -D__ARM_ARCH_5T__\
 -D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__

#elif $[eq $[ANDROID_ARCH],mips]
#define target_cflags\
 -fpic\
 -fno-strict-aliasing\
 -finline-functions\
 -ffunction-sections\
 -funwind-tables\
 -fmessage-length=0\
 -fno-inline-functions-called-once\
 -fgcse-after-reload\
 -frerun-cse-after-loop\
 -frename-registers

#elif $[eq $[ANDROID_ABI],x86]
#define target_cflags\
 -ffunction-sections\
 -funwind-tables\
 -fstack-protector
#endif

#if $[eq $[ANDROID_ABI],armeabi-v7a]
#define target_cflags $[target_cflags]\
 -march=armv7-a \
 -mfloat-abi=softfp \
 -mfpu=vfpv3-d16

#define target_ldflags $[target_ldflags]\
 -march=armv7-a \
 -Wl,--fix-cortex-a8

#elif $[eq $[ANDROID_ABI],armeabi]
#define target_cflags $[target_cflags]\
 -march=armv5te \
 -mtune=xscale \
 -msoft-float
#endif

#define ANDROID_CFLAGS $[target_cflags] $[ANDROID_CFLAGS]
#define ANDROID_LDFLAGS $[target_ldflags] $[ANDROID_LDFLAGS]

#endif

#if $[WINDOWS_PLATFORM]

#define C++FLAGS_GEN $[C++FLAGS_GEN] $[WARNING_LEVEL_FLAG]

#if $[eq $[USE_COMPILER], Clang]
  // Add some extra flags to shut Clang up a bit.
  #define C++FLAGS_GEN $[C++FLAGS_GEN] \
    -Wno-microsoft-template -Wno-inconsistent-missing-override \
    -Wno-reorder-ctor -Wno-enum-compare-switch \
    -Wno-microsoft -Wno-register -Wno-deprecated-builtins \
    -Wno-nan-infinity-disabled

  #define EMBED_OBJECT_DEBUG_INFO 1

  #if $[eq $[COMPILER],]
    #define COMPILER clang-cl.exe
  #endif
  #if $[eq $[LINKER],]
    #define LINKER lld-link.exe
  #endif
  #if $[eq $[LIBBER],]
    #define LIBBER llvm-lib.exe
  #endif

  // /MP is not supported on clang.
  #define COMMONFLAGS $[filter-out /MP, $[COMMONFLAGS]]

  // Needed for MSBuild.
  #if $[eq $[COMPILER_PATH],]
    #define COMPILER_PATH $[unixshortname C:\Program Files\LLVM\bin]
  #endif
  #if $[eq $[LINKER_PATH],]
    #define LINKER_PATH $[unixshortname C:\Program Files\LLVM\bin]
  #endif
  #if $[eq $[LIBBER_PATH],]
    #define LIBBER_PATH $[unixshortname C:\Program Files\LLVM\bin]
  #endif

  #if $[DO_CROSSOBJ_OPT]
    #define FAST_OPTFLAGS $[FAST_OPTFLAGS] -flto=thin
  #endif

#else // MSVC compiler.
  #define COMPILER cl.exe
  #define LINKER link.exe
  #define LIBBER lib.exe

  #if $[DO_CROSSOBJ_OPT]
    #define EMBED_OBJECT_DEBUG_INFO 1
    #define FAST_OPTFLAGS $[FAST_OPTFLAGS] /GL
    #define LINKER_FLAGS $[LINKER_FLAGS] /LTGC
  #endif

#endif

#if $[HAVE_RTTI]
  #define C++FLAGS_GEN $[C++FLAGS_GEN] /GR
#endif

#if $[WIN64_PLATFORM]
  #define C++FLAGS_GEN $[C++FLAGS_GEN] /DWIN64_VC /DWIN64=1
#endif

#endif // WINDOWS_PLATFORM

#if $[UNIX_PLATFORM]

#if $[not $[HAVE_RTTI]]
  #define C++FLAGS_GEN $[C++FLAGS_GEN] -fno-rtti
#else
  #define C++FLAGS_GEN $[C++FLAGS_GEN] -frtti
#endif

#if $[DO_CROSSOBJ_OPT]
  #define C++FLAGS_GEN $[C++FLAGS_GEN] -flto -fwhole-program
#endif

#if $[and $[HAVE_EIGEN],$[eq $[USE_COMPILER],GCC]]
  // Works around double-matrix invert bug.
  #define C++FLAGS_GEN $[C++FLAGS_GEN] -fno-unsafe-math-optimizations
#endif

#endif // UNIX_PLATFORM
