//
// Package.pp
//
// This file defines certain configuration variables that are to be
// written into the various make scripts.  It is processed by ppremake
// (along with the Sources.pp files in each of the various
// directories) to generate build scripts appropriate to each
// environment.
//
// This is the package-specific file, which should be at the top of
// every source hierarchy.  It generally gets the ball rolling, and is
// responsible for explicitly including all of the relevant Config.pp
// files.

// Check the version of ppremake in use.
#if $[< $[PPREMAKE_VERSION],1.11]
  #error You need at least ppremake version 1.11 to process this tree.
#endif

// Get the current version info for Panda.
#include $[THISDIRPREFIX]PandaVersion.pp
#define PANDA_MAJOR_VERSION $[word 1,$[PANDA_VERSION]]
#define PANDA_MINOR_VERSION $[word 2,$[PANDA_VERSION]]
#define PANDA_SEQUENCE_VERSION $[word 3,$[PANDA_VERSION]]
#defer PANDA_VERSION_STR $[PANDA_MAJOR_VERSION].$[PANDA_MINOR_VERSION].$[PANDA_SEQUENCE_VERSION]$[if $[not $[PANDA_OFFICIAL_VERSION]],c]
#defer PANDA_VERSION_SYMBOL panda_version_$[PANDA_MAJOR_VERSION]_$[PANDA_MINOR_VERSION]

// The panda version as a single number, with three digits reserved
// for each component.
#define PANDA_NUMERIC_VERSION $[+ $[* $[PANDA_MAJOR_VERSION],1000000],$[* $[PANDA_MINOR_VERSION],1000],$[PANDA_SEQUENCE_VERSION]]

// What is the name of this source tree?
#if $[eq $[PACKAGE],]
  #define PACKAGE dtool
#endif

// Where should we install DTOOL, specifically?
#if $[DTOOL_INSTALL]
  #define DTOOL_INSTALL $[unixfilename $[DTOOL_INSTALL]]
#elif $[CTPROJS]
  // If we are presently attached, use the environment variable.
  // We define two variables: one for ourselves, which burns in the
  // current value of the DTOOL environment variable (so that any
  // attempt to install in this tree will install correctly, no
  // matter whether we are attached to a different DTOOL later by
  // mistake), and one for other trees to use, which expands to a
  // ordinary reference to the DTOOL environment variable, so
  // they will read from the right tree no matter which DTOOL they're
  // attached to.
  #define DTOOL $[unixfilename $[DTOOL]]
  #define DTOOL_INSTALL $[DTOOL]/built
  #if $[eq $[DTOOL],]
    #error You seem to be attached to some trees, but not DTOOL!
  #endif
#else
  // Otherwise, if we are not attached, install in the standard place
  // (unless the user specifies otherwise).
  #defer DTOOL_INSTALL $[unixfilename $[INSTALL_DIR]]
#endif

// These variables tell ppremake how to interpret the contents of the
// PLATFORM variable, and help it to control the effects of functions
// like $[os] and $[isfullpath].

// True if we are specifically 32-bit Windows.
#define WIN32_PLATFORM $[or $[eq $[PLATFORM],Win32],$[eq $[PLATFORM],Cygwin]]

// True if we are 64-bit windows.
#define WIN64_PLATFORM $[or $[eq $[PLATFORM],Win64],$[eq $[PLATFORM],Cygwin64]]

// True if we are building on some flavor of Windows.
#define WINDOWS_PLATFORM $[or $[WIN32_PLATFORM],$[WIN64_PLATFORM]]

// True if we are building on some flavor of OS X.
#define OSX_PLATFORM $[eq $[PLATFORM],OSX]

// True if we are building on some flavor of Unix.
#define UNIX_PLATFORM $[and $[not $[WINDOWS_PLATFORM]],$[not $[OSX_PLATFORM]]]

// True if we are building on Android.
#define ANDROID_PLATFORM $[eq $[PLATFORM], Android]

#if $[WINDOWS_PLATFORM]
#define X86_PLATFORM $[WIN32_PLATFORM]
#define X64_PLATFORM $[WIN64_PLATFORM]
#else
#define X86_PLATFORM $[eq $[shell uname -m],x86]
#define X64_PLATFORM $[eq $[shell uname -m],x86_64]
#endif

// Pull in the package-level Config file.  This contains a lot of
// configuration variables that the user might want to fine-tune.
#include $[THISDIRPREFIX]Config.pp

// Also get the platform-specific config file.  This defines a few
// more variables that are more likely to be platform-dependent and
// are less likely to be directly modified by the user.
#include $[THISDIRPREFIX]Config.$[PLATFORM].pp

// If the environment variable PPREMAKE_CONFIG is set, it points to a
// user-customized Config.pp file, for instance in the user's home
// directory.  This file might redefine any of the variables defined
// above.
#if $[ne $[PPREMAKE_CONFIG],]
  #define PPREMAKE_CONFIG $[unixfilename $[PPREMAKE_CONFIG]]
  #print Reading $[PPREMAKE_CONFIG] (referred to by PPREMAKE_CONFIG)
  #include $[PPREMAKE_CONFIG]

#elif $[wildcard $[unixfilename $[INSTALL_DIR]]/Config.pp]
  // If the PPREMAKE_CONFIG variable is not, but there exists a
  // Config.pp in the compiled-in INSTALL_DIR, use that one by default.
  #define PPREMAKE_CONFIG $[unixfilename $[INSTALL_DIR]]/Config.pp
  #print Reading $[PPREMAKE_CONFIG] (referred to by INSTALL_DIR, because PPREMAKE_CONFIG is empty)
  #include $[PPREMAKE_CONFIG]

#else
  // Otherwise, just carry on without it.
  #print Environment variable PPREMAKE_CONFIG not set; using defaults.
#endif

#include $[THISDIRPREFIX]pptempl/PostConfig.pp

// Now evaluate all of our deferred variable definitions from
// Config.pp.
#set EIGEN_IPATH $[unixfilename $[EIGEN_IPATH]]
#set HAVE_EIGEN $[HAVE_EIGEN]

#set PYTHON_IPATH $[unixfilename $[PYTHON_IPATH]]
#set PYTHON_LPATH $[unixfilename $[PYTHON_LPATH]]
#set PYTHON_FPATH $[unixfilename $[PYTHON_FPATH]]
#set PYTHON_FRAMEWORK $[unixfilename $[PYTHON_FRAMEWORK]]
#set HAVE_PYTHON $[HAVE_PYTHON]

#set NATIVE_NET_IPATH $[unixfilename $[NATIVE_NET_IPATH]]
#set NATIVE_NET_LPATH $[unixfilename $[NATIVE_NET_LPATH]]
#set NATIVE_NET_LIBS $[NATIVE_NET_LIBS]
#set WANT_NATIVE_NET $[WANT_NATIVE_NET]

#set HAVE_NET $[HAVE_NET]

#set OPENSSL_IPATH $[unixfilename $[OPENSSL_IPATH]]
#set OPENSSL_LPATH $[unixfilename $[OPENSSL_LPATH]]
#set OPENSSL_LIBS $[OPENSSL_LIBS]
#set HAVE_OPENSSL $[HAVE_OPENSSL]

#set JPEG_IPATH $[unixfilename $[JPEG_IPATH]]
#set JPEG_LPATH $[unixfilename $[JPEG_LPATH]]
#set JPEG_LIBS $[JPEG_LIBS]
#set HAVE_JPEG $[HAVE_JPEG]

#set PNG_IPATH $[unixfilename $[PNG_IPATH]]
#set PNG_LPATH $[unixfilename $[PNG_LPATH]]
#set PNG_LIBS $[PNG_LIBS]
#set HAVE_PNG $[HAVE_PNG]

#set TIFF_IPATH $[unixfilename $[TIFF_IPATH]]
#set TIFF_LPATH $[unixfilename $[TIFF_LPATH]]
#set TIFF_LIBS $[TIFF_LIBS]
#set HAVE_TIFF $[HAVE_TIFF]

#set FFTW_IPATH $[unixfilename $[FFTW_IPATH]]
#set FFTW_LPATH $[unixfilename $[FFTW_LPATH]]
#set FFTW_LIBS $[FFTW_LIBS]
#set HAVE_FFTW $[HAVE_FFTW]

#set SQUISH_IPATH $[unixfilename $[SQUISH_IPATH]]
#set SQUISH_LPATH $[unixfilename $[SQUISH_LPATH]]
#set SQUISH_LIBS $[SQUISH_LIBS]
#set HAVE_SQUISH $[HAVE_SQUISH]

#set VRPN_IPATH $[unixfilename $[VRPN_IPATH]]
#set VRPN_LPATH $[unixfilename $[VRPN_LPATH]]
#set VRPN_LIBS $[VRPN_LIBS]
#set HAVE_VRPN $[HAVE_VRPN]

#set ZLIB_IPATH $[unixfilename $[ZLIB_IPATH]]
#set ZLIB_LPATH $[unixfilename $[ZLIB_LPATH]]
#set ZLIB_LIBS $[ZLIB_LIBS]
#set HAVE_ZLIB $[HAVE_ZLIB]

#set GL_IPATH $[unixfilename $[GL_IPATH]]
#set GL_LPATH $[unixfilename $[GL_LPATH]]
#set GL_LIBS $[GL_LIBS]
#set HAVE_GL $[HAVE_GL]

#set GLES_IPATH $[unixfilename $[GLES_IPATH]]
#set GLES_LPATH $[unixfilename $[GLES_LPATH]]
#set GLES_LIBS $[GLES_LIBS]
#set HAVE_GLES $[HAVE_GLES]

#set GLES2_IPATH $[unixfilename $[GLES2_IPATH]]
#set GLES2_LPATH $[unixfilename $[GLES2_LPATH]]
#set GLES2_LIBS $[GLES2_LIBS]
#set HAVE_GLES2 $[HAVE_GLES2]

#set GLX_IPATH $[unixfilename $[GLX_IPATH]]
#set GLX_LPATH $[unixfilename $[GLX_LPATH]]
#set HAVE_GLX $[HAVE_GLX]

#set EGL_IPATH $[unixfilename $[EGL_IPATH]]
#set EGL_LPATH $[unixfilename $[EGL_LPATH]]
#set EGL_LIBS $[unixfilename $[EGL_LIBS]]
#set HAVE_EGL $[HAVE_EGL]

#set HAVE_WGL $[HAVE_WGL]

#set HAVE_COCOA $[HAVE_COCOA]
#set HAVE_CARBON $[HAVE_CARBON]

#set DX9_IPATH $[unixfilename $[DX9_IPATH]]
#set DX9_LPATH $[unixfilename $[DX9_LPATH]]
#set DX9_LIBS $[DX9_LIBS]
#set HAVE_DX9 $[HAVE_DX9]

#set OPENCV_IPATH $[unixfilename $[OPENCV_IPATH]]
#set OPENCV_LPATH $[unixfilename $[OPENCV_LPATH]]
#set OPENCV_LIBS $[OPENCV_LIBS]
#set HAVE_OPENCV $[HAVE_OPENCV]

#set FFMPEG_IPATH $[unixfilename $[FFMPEG_IPATH]]
#set FFMPEG_LPATH $[unixfilename $[FFMPEG_LPATH]]
#set FFMPEG_LIBS $[FFMPEG_LIBS]
#set HAVE_FFMPEG $[HAVE_FFMPEG]

#set ODE_IPATH $[unixfilename $[ODE_IPATH]]
#set ODE_LPATH $[unixfilename $[ODE_LPATH]]
#set ODE_LIBS $[ODE_LIBS]
#set HAVE_ODE $[HAVE_ODE]

#set HAVE_THREADS $[HAVE_THREADS]
#set DEBUG_THREADS $[DEBUG_THREADS]
#set MUTEX_SPINLOCK $[MUTEX_SPINLOCK]

#set DO_PSTATS $[DO_PSTATS]

#set RAD_MSS_IPATH $[unixfilename $[RAD_MSS_IPATH]]
#set RAD_MSS_LPATH $[unixfilename $[RAD_MSS_LPATH]]
#set RAD_MSS_LIBS $[RAD_MSS_LIBS]
#set HAVE_RAD_MSS $[HAVE_RAD_MSS]

#set FMOD_IPATH $[unixfilename $[FMOD_IPATH]]
#set FMOD_LPATH $[unixfilename $[FMOD_LPATH]]
#set FMOD_LIBS $[FMOD_LIBS]
#set HAVE_FMOD $[HAVE_FMOD]

#set FMOD_STUDIO_IPATH $[unixfilename $[FMOD_STUDIO_IPATH]]
#set FMOD_STUDIO_LPATH $[unixfilename $[FMOD_STUDIO_LPATH]]
#set FMOD_STUDIO_LIBS $[FMOD_STUDIO_LIBS]
#set HAVE_FMOD_STUDIO $[HAVE_FMOD_STUDIO]

#set STEAM_AUDIO_IPATH $[unixfilename $[STEAM_AUDIO_IPATH]]
#set STEAM_AUDIO_LPATH $[unixfilename $[STEAM_AUDIO_LPATH]]
#set STEAM_AUDIO_LIBS $[STEAM_AUDIO_LIBS]
#set HAVE_STEAM_AUDIO $[HAVE_STEAM_AUDIO]

#set OPENAL_IPATH $[unixfilename $[OPENAL_IPATH]]
#set OPENAL_LPATH $[unixfilename $[OPENAL_LPATH]]
#set OPENAL_LIBS $[OPENAL_LIBS]
#set OPENAL_FRAMEWORK $[unixfilename $[OPENAL_FRAMEWORK]]
#set HAVE_OPENAL $[HAVE_OPENAL]

#set MIMALLOC_IPATH $[unixfilename $[MIMALLOC_IPATH]]
#set MIMALLOC_LPATH $[unixfilename $[MIMALLOC_LPATH]]
#set MIMALLOC_LIBS $[MIMALLOC_LIBS]
#set HAVE_MIMALLOC $[HAVE_MIMALLOC]

#set PKG_CONFIG $[PKG_CONFIG]
#set HAVE_GTK $[HAVE_GTK]

#set HAVE_FREETYPE $[HAVE_FREETYPE]
#set FREETYPE_CFLAGS $[FREETYPE_CFLAGS]
#set FREETYPE_IPATH $[unixfilename $[FREETYPE_IPATH]]
#set FREETYPE_LPATH $[unixfilename $[FREETYPE_LPATH]]
#set FREETYPE_LIBS $[FREETYPE_LIBS]

#set MAYA_LOCATION $[unixfilename $[MAYA_LOCATION]]
#set HAVE_MAYA $[HAVE_MAYA]

#set SOFTIMAGE_LOCATION $[unixfilename $[SOFTIMAGE_LOCATION]]
#set HAVE_SOFTIMAGE $[HAVE_SOFTIMAGE]

#set FCOLLADA_IPATH $[unixfilename $[FCOLLADA_IPATH]]
#set FCOLLADA_LPATH $[unixfilename $[FCOLLADA_LPATH]]
#set FCOLLADA_LIBS $[FCOLLADA_LIBS]
#set HAVE_FCOLLADA $[HAVE_FCOLLADA]

#set ASSIMP_IPATH $[unixfilename $[ASSIMP_IPATH]]
#set ASSIMP_LPATH $[unixfilename $[ASSIMP_LPATH]]
#set ASSIMP_LIBS $[ASSIMP_LIBS]
#set HAVE_ASSIMP $[HAVE_ASSIMP]

#set ARTOOLKIT_IPATH $[unixfilename $[ARTOOLKIT_IPATH]]
#set ARTOOLKIT_LPATH $[unixfilename $[ARTOOLKIT_LPATH]]
#set ARTOOLKIT_LIBS $[ARTOOLKIT_LIBS]
#set HAVE_ARTOOLKIT $[HAVE_ARTOOLKIT]

#set ROCKET_IPATH $[unixfilename $[ROCKET_IPATH]]
#set ROCKET_LPATH $[unixfilename $[ROCKET_LPATH]]
#set ROCKET_LIBS $[ROCKET_LIBS]
#set HAVE_ROCKET $[HAVE_ROCKET]
#set HAVE_ROCKET_PYTHON $[HAVE_ROCKET_PYTHON]

#set BULLET_IPATH $[unixfilename $[BULLET_IPATH]]
#set BULLET_LPATH $[unixfilename $[BULLET_LPATH]]
#set BULLET_LIBS $[BULLET_LIBS]
#set HAVE_BULLET $[HAVE_BULLET]

#set PHYSX_IPATH $[unixfilename $[PHYSX_IPATH]]
#set PHYSX_LPATH $[unixfilename $[PHYSX_LPATH]]
#set PHYSX_LIBS $[PHYSX_LIBS]
#set HAVE_PHYSX $[HAVE_PHYSX]

#set VORBIS_IPATH $[unixfilename $[VORBIS_IPATH]]
#set VORBIS_LPATH $[unixfilename $[VORBIS_LPATH]]
#set VORBIS_LIBS $[VORBIS_LIBS]
#set HAVE_VORBIS $[HAVE_VORBIS]

#set OPUS_IPATH $[unixfilename $[OPUS_IPATH]]
#set OPUS_LPATH $[unixfilename $[OPUS_LPATH]]
#set OPUS_LIBS $[OPUS_LIBS]
#set HAVE_OPUS $[HAVE_OPUS]

#set HARFBUZZ_IPATH $[unixfilename $[HARFBUZZ_IPATH]]
#set HARFBUZZ_LPATH $[unixfilename $[HARFBUZZ_LPATH]]
#set HARFBUZZ_LIBS $[HARFBUZZ_LIBS]
#set HAVE_HARFBUZZ $[HAVE_HARFBUZZ]

#set OPENEXR_IPATH $[unixfilename $[OPENEXR_IPATH]]
#set OPENEXR_LPATH $[unixfilename $[OPENEXR_LPATH]]
#set OPENEXR_LIBS $[OPENEXR_LIBS]
#set HAVE_OPENEXR $[HAVE_OPENEXR]

#set VALVE_STEAMNET_IPATH $[unixfilename $[VALVE_STEAMNET_IPATH]]
#set VALVE_STEAMNET_LPATH $[unixfilename $[VALVE_STEAMNET_LPATH]]
#set VALVE_STEAMNET_LIBS $[VALVE_STEAMNET_LIBS]
#set HAVE_VALVE_STEAMNET $[HAVE_VALVE_STEAMNET]

#set GLSLANG_IPATH $[unixfilename $[GLSLANG_IPATH]]
#set GLSLANG_LPATH $[unixfilename $[GLSLANG_LPATH]]
#set GLSLANG_LIBS $[GLSLANG_LIBS]
#set HAVE_GLSLANG $[HAVE_GLSLANG]

#set SPIRV_TOOLS_IPATH $[unixfilename $[SPIRV_TOOLS_IPATH]]
#set SPIRV_TOOLS_LPATH $[unixfilename $[SPIRV_TOOLS_LPATH]]
#set SPIRV_TOOLS_LIBS $[SPIRV_TOOLS_LIBS]
#set HAVE_SPIRV_TOOLS $[HAVE_SPIRV_TOOLS]

#set SPIRV_CROSS_IPATH $[unixfilename $[SPIRV_CROSS_IPATH]]
#set SPIRV_CROSS_LPATH $[unixfilename $[SPIRV_CROSS_LPATH]]
#set SPIRV_CROSS_LIBS $[SPIRV_CROSS_LIBS]
#set HAVE_SPIRV_CROSS $[HAVE_SPIRV_CROSS]

#set EMBREE_IPATH $[unixfilename $[EMBREE_IPATH]]
#set EMBREE_LPATH $[unixfilename $[EMBREE_LPATH]]
#set EMBREE_LIBS $[EMBREE_LIBS]
#set HAVE_EMBREE $[HAVE_EMBREE]

#set OIDN_IPATH $[unixfilename $[OIDN_IPATH]]
#set OIDN_LPATH $[unixfilename $[OIDN_LPATH]]
#set OIDN_LIBS $[OIDN_LIBS]
#set HAVE_OIDN $[HAVE_OIDN]

#set TBB_IPATH $[unixfilename $[TBB_IPATH]]
#set TBB_LPATH $[unixfilename $[TBB_LPATH]]
#set TBB_LIBS $[TBB_LIBS]
#set HAVE_TBB $[HAVE_TBB]

#set SLEEF_IPATH $[unixfilename $[SLEEF_IPATH]]
#set SLEEF_LPATH $[unixfilename $[SLEEF_LPATH]]
#set SLEEF_LIBS $[SLEEF_LIBS]
#set HAVE_SLEEF $[HAVE_SLEEF]

// Now infer a few more variables based on what was defined.
#if $[and $[HAVE_GTK],$[PKG_CONFIG]]
  #define cflags $[shell $[PKG_CONFIG] gtk+-3.0 --cflags]
  #define libs $[shell $[PKG_CONFIG] gtk+-3.0 --libs]

  #define GTK_CFLAGS $[filter-out -I%,$[cflags]]
  #define GTK_IPATH $[unique $[patsubst -I%,%,$[filter -I%,$[cflags]]]]
  #define GTK_LPATH $[unique $[patsubst -L%,%,$[filter -L%,$[libs]]]]
  #define GTK_LIBS $[patsubst -l%,%,$[filter -l%,$[libs]]]
#endif

#if $[and $[HAVE_FREETYPE],$[PKG_CONFIG]]
  #define cflags $[shell $[PKG_CONFIG] freetype2 --cflags]
  #define libs $[shell $[PKG_CONFIG] freetype2 --libs]

  #define FREETYPE_CFLAGS $[filter-out -I%,$[cflags]]
  #define FREETYPE_IPATH $[unique $[patsubst -I%,%,$[filter -I%,$[cflags]]]]
  #define FREETYPE_LPATH $[unique $[patsubst -L%,%,$[filter -L%,$[libs]]]]
  #define FREETYPE_LIBS $[patsubst -l%,%,$[filter -l%,$[libs]]]
#endif

// Finally, include the system configure file.
#include $[THISDIRPREFIX]pptempl/System.pp
