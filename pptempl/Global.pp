//
// Global.pp
//
// This file is read in before any of the individual Sources.pp files
// are read.  It defines a few global variables that are useful to all
// different kinds of build_types.
//

// We start off by defining a number of map variables.  These are
// special variables that can be used to look up a particular named
// scope according to a key (that is, according to the value of some
// variable defined within the scope).

// A named scope is defined using the #begin name .. #end name
// sequence.  In general, we use these sequences in the various
// Sources.pp files to define the various targets to build.  Each
// named scope carries around its set of variable declarations.  The
// named scopes are associated with the dirname of the directory in
// which the Sources.pp file was found.


// The first map variable lets us look up a particular library target
// by its target name.  The syntax here indicates that we are
// declaring a map variable called "all_libs" whose key is the
// variable $[TARGET] as defined in each instance of a named scope
// called "static_lib_target," "lib_target," and so on in every
// Sources.pp file.  (The */ refers to all the Sources.pp files.  We
// could also identify a particular file by its directory name, or
// omit the slash to refer to our own Sources.pp file.)

// After defining this map variable, we can look up other variables
// that are defined for the corresponding target.  For instances,
// $[all_libs $[SOURCES],dconfig] will return the value of the SOURCES
// variable as set for the dconfig library (that is, the expression
// $[SOURCES] is evaluated within the named scope whose key is
// "dconfig"--whose variable $[TARGET] was defined to be "dconfig").
#map all_libs TARGET(*/interface_target */static_lib_target */dynamic_lib_target */ss_lib_target */lib_target */noinst_lib_target */test_lib_target */metalib_target */python_module_target */python_target)

// This map variable allows us to look up global variables that might
// be defined in a particular Sources.pp, e.g. in the "toplevel" file.
#map dir_type DIR_TYPE(*/)

#map libs TARGET(*/interface_target */lib_target */static_lib_target */dynamic_lib_target */ss_lib_target */noinst_lib_target */test_lib_target */metalib_target */python_module_target */python_target)

// This lets us identify which metalib, if any, is including each
// named library.  That is, $[module $[TARGET],name] will return
// the name of the metalib that includes library name.
#map module COMPONENT_LIBS(*/metalib_target)

// This lets us identify which Python module, if any, is including each
// named library.  This is, $[python_module $[TARGET],name] will return
// the name of the Python module that includes library name.
#map python_module IGATE_LIBS(*/python_module_target)

// This lets us look up components of a particular metalib.
#map components TARGET(*/lib_target */noinst_lib_target */test_lib_target)

// And this lets us look up source directories by dirname.
#map dirnames DIRNAME(*/)

// Define some various compile flags, derived from the variables set
// in Config.pp.
#set INTERROGATE_PYTHON_INTERFACE $[and $[HAVE_PYTHON],$[INTERROGATE_PYTHON_INTERFACE]]
#define run_interrogate $[HAVE_INTERROGATE]

#define stl_ipath $[wildcard $[STL_IPATH]]
#define stl_lpath $[wildcard $[STL_LPATH]]
#define stl_cflags $[STL_CFLAGS]
#define stl_libs $[STL_LIBS]

#define eigen_ipath $[wildcard $[EIGEN_IPATH]]
#define eigen_cflags $[EIGEN_CFLAGS]

#if $[HAVE_PYTHON]
  #define python_ipath $[wildcard $[PYTHON_IPATH]]
  #define python_lpath $[wildcard $[PYTHON_LPATH]]
  #define python_fpath $[wildcard $[PYTHON_FPATH]]
  #define python_cflags $[PYTHON_CFLAGS]
  #define python_lflags $[PYTHON_LFLAGS]
  #define python_libs $[PYTHON_LIBS]
  #define python_framework $[PYTHON_FRAMEWORK]
#endif

#if $[USE_TAU]
  #define tau_ipath $[wildcard $[TAU_IPATH]]
#endif

#if $[HAVE_THREADS]
  #define threads_ipath $[wildcard $[THREADS_IPATH]]
  #define threads_lpath $[wildcard $[THREADS_LPATH]]
  #define threads_cflags $[THREADS_CFLAGS]
  #define threads_libs $[THREADS_LIBS]
  #define threads_framework $[THREADS_FRAMEWORK]
#endif

#if $[HAVE_OPENSSL]
  #define openssl_ipath $[wildcard $[OPENSSL_IPATH]]
  #define openssl_lpath $[wildcard $[OPENSSL_LPATH]]
  #define openssl_cflags $[OPENSSL_CFLAGS]
  #define openssl_libs $[OPENSSL_LIBS]
#endif

#if $[HAVE_ZLIB]
  #define zlib_ipath $[wildcard $[ZLIB_IPATH]]
  #define zlib_lpath $[wildcard $[ZLIB_LPATH]]
  #define zlib_cflags $[ZLIB_CFLAGS]
  #define zlib_libs $[ZLIB_LIBS]
#endif

#if $[HAVE_GL]
  #define gl_ipath $[wildcard $[GL_IPATH]]
  #define gl_lpath $[wildcard $[GL_LPATH]]
  #define gl_cflags $[GL_CFLAGS]
  #define gl_libs $[GL_LIBS]
  #define gl_framework $[GL_FRAMEWORK]
#endif

#if $[HAVE_GLES]
  #define gles_ipath $[wildcard $[GLES_IPATH]]
  #define gles_lpath $[wildcard $[GLES_LPATH]]
  #define gles_cflags $[GLES_CFLAGS]
  #define gles_libs $[GLES_LIBS]
#endif

#if $[HAVE_GLES2]
  #define gles2_ipath $[wildcard $[GLES2_IPATH]]
  #define gles2_lpath $[wildcard $[GLES2_LPATH]]
  #define gles2_cflags $[GLES2_CFLAGS]
  #define gles2_libs $[GLES2_LIBS]
#endif

#if $[HAVE_SDL]
  #define sdl_ipath $[wildcard $[SDL_IPATH]]
  #define sdl_lpath $[wildcard $[SDL_LPATH]]
  #define sdl_cflags $[SDL_CFLAGS]
  #define sdl_libs $[SDL_LIBS]
  #define sdl_framework $[SDL_FRAMEWORK]
#endif

#if $[HAVE_X11]
  #define x11_ipath $[wildcard $[X11_IPATH]]
  #define x11_lpath $[wildcard $[X11_LPATH]]
  #define x11_cflags $[X11_CFLAGS]
  #define x11_libs $[X11_LIBS]
  #define x11_framework $[X11_FRAMEWORK]
#endif

#if $[HAVE_GLX]
  #define glx_ipath $[wildcard $[GLX_IPATH]]
  #define glx_lpath $[wildcard $[GLX_LPATH]]
  #define glx_cflags $[GLX_CFLAGS]
  #define glx_libs $[GLX_LIBS]
#endif

#if $[HAVE_EGL]
  #define egl_ipath $[wildcard $[EGL_IPATH]]
  #define egl_lpath $[wildcard $[EGL_LPATH]]
  #define egl_cflags $[EGL_CFLAGS]
  #define egl_libs $[EGL_LIBS]
#endif

#if $[HAVE_DX9]
  #define dx9_ipath $[wildcard $[DX9_IPATH]]
  #define dx9_lpath $[wildcard $[DX9_LPATH]]
  #define dx9_cflags $[DX9_CFLAGS]
  #define dx9_libs $[DX9_LIBS]
#endif

#if $[HAVE_OPENCV]
  #define opencv_ipath $[wildcard $[OPENCV_IPATH]]
  #define opencv_lpath $[wildcard $[OPENCV_LPATH]]
  #define opencv_cflags $[OPENCV_CFLAGS]
  #define opencv_libs $[OPENCV_LIBS]
  #define opencv_framework $[OPENCV_FRAMEWORK]
#endif

#if $[HAVE_FFMPEG]
  #define ffmpeg_ipath $[wildcard $[FFMPEG_IPATH]]
  #define ffmpeg_lpath $[wildcard $[FFMPEG_LPATH]]
  #define ffmpeg_cflags $[FFMPEG_CFLAGS]
  #define ffmpeg_libs $[FFMPEG_LIBS]
#endif

#if $[HAVE_ODE]
  #define ode_ipath $[wildcard $[ODE_IPATH]]
  #define ode_lpath $[wildcard $[ODE_LPATH]]
  #define ode_cflags $[ODE_CFLAGS]
  #define ode_libs $[ODE_LIBS]
#endif

#if $[HAVE_JPEG]
  #define jpeg_ipath $[wildcard $[JPEG_IPATH]]
  #define jpeg_lpath $[wildcard $[JPEG_LPATH]]
  #define jpeg_cflags $[JPEG_CFLAGS]
  #define jpeg_libs $[JPEG_LIBS]
#endif

#if $[HAVE_PNG]
  #define png_ipath $[wildcard $[PNG_IPATH]]
  #define png_lpath $[wildcard $[PNG_LPATH]]
  #define png_cflags $[PNG_CFLAGS]
  #define png_libs $[PNG_LIBS]
#endif

#if $[HAVE_TIFF]
  #define tiff_ipath $[wildcard $[TIFF_IPATH]]
  #define tiff_lpath $[wildcard $[TIFF_LPATH]]
  #define tiff_cflags $[TIFF_CFLAGS]
  #define tiff_libs $[TIFF_LIBS]
#endif

#if $[HAVE_FFTW]
  #define fftw_ipath $[wildcard $[FFTW_IPATH]]
  #define fftw_lpath $[wildcard $[FFTW_LPATH]]
  #define fftw_cflags $[FFTW_CFLAGS]
  #define fftw_libs $[FFTW_LIBS]
#endif

#if $[HAVE_SQUISH]
  #define squish_ipath $[wildcard $[SQUISH_IPATH]]
  #define squish_lpath $[wildcard $[SQUISH_LPATH]]
  #define squish_cflags $[SQUISH_CFLAGS]
  #define squish_libs $[SQUISH_LIBS]
#endif

#if $[HAVE_VRPN]
  #define vrpn_ipath $[wildcard $[VRPN_IPATH]]
  #define vrpn_lpath $[wildcard $[VRPN_LPATH]]
  #define vrpn_cflags $[VRPN_CFLAGS]
  #define vrpn_libs $[VRPN_LIBS]
#endif

#if $[HAVE_GTK]
  #define gtk_ipath $[wildcard $[GTK_IPATH]]
  #define gtk_lpath $[wildcard $[GTK_LPATH]]
  #define gtk_cflags $[GTK_CFLAGS]
  #define gtk_libs $[GTK_LIBS]
#endif

#if $[HAVE_FREETYPE]
  #define freetype_ipath $[wildcard $[FREETYPE_IPATH]]
  #define freetype_lpath $[wildcard $[FREETYPE_LPATH]]
  #define freetype_cflags $[FREETYPE_CFLAGS]
  #define freetype_libs $[FREETYPE_LIBS]
  #define freetype_framework $[FREETYPE_FRAMEWORK]
#endif

#if $[and $[HAVE_MAYA],$[MAYA_LOCATION]]
  #define maya_ipath $[MAYA_LOCATION]/include
  #define maya_lpath $[MAYA_LOCATION]/lib
  #define maya_ld $[wildcard $[MAYA_LOCATION]/bin/mayald]
  #define maya_libs $[MAYA_LIBS]
#endif

#if $[HAVE_NET]
  #define net_ipath $[wildcard $[NET_IPATH]]
  #define net_lpath $[wildcard $[NET_LPATH]]
  #define net_libs $[NET_LIBS]
#endif

#if $[WANT_NATIVE_NET]
  #define native_net_ipath $[wildcard $[NATIVE_NET_IPATH]]
  #define native_net_lpath $[wildcard $[NATIVE_NET_LPATH]]
  #define native_net_libs $[NATIVE_NET_LIBS]
#endif

#if $[HAVE_RAD_MSS]
  #define rad_mss_ipath $[wildcard $[RAD_MSS_IPATH]]
  #define rad_mss_lpath $[wildcard $[RAD_MSS_LPATH]]
  #define rad_mss_libs $[RAD_MSS_LIBS]
#endif

#if $[HAVE_FMOD]
  #define fmod_ipath $[wildcard $[FMOD_IPATH]]
  #define fmod_lpath $[wildcard $[FMOD_LPATH]]
  #define fmod_cflags $[FMOD_CFLAGS]
  #define fmod_libs $[FMOD_LIBS]
#endif

#if $[HAVE_OPENAL]
  #define openal_ipath $[wildcard $[OPENAL_IPATH]]
  #define openal_lpath $[wildcard $[OPENAL_LPATH]]
  #define openal_libs $[OPENAL_LIBS]
  #define openal_framework $[OPENAL_FRAMEWORK]
#endif

#if $[HAVE_MIMALLOC]
  #define mimalloc_ipath $[wildcard $[MIMALLOC_IPATH]]
  #define mimalloc_lpath $[wildcard $[MIMALLOC_LPATH]]
  #define mimalloc_libs $[MIMALLOC_LIBS]
#endif

#if $[HAVE_FCOLLADA]
  #define fcollada_ipath $[wildcard $[FCOLLADA_IPATH]]
  #define fcollada_lpath $[wildcard $[FCOLLADA_LPATH]]
  #define fcollada_libs $[FCOLLADA_LIBS]
#endif

#if $[HAVE_ASSIMP]
  #define assimp_ipath $[wildcard $[ASSIMP_IPATH]]
  #define assimp_lpath $[wildcard $[ASSIMP_LPATH]]
  #define assimp_libs $[ASSIMP_LIBS]
#endif

#if $[HAVE_ARTOOLKIT]
  #define artoolkit_ipath $[wildcard $[ARTOOLKIT_IPATH]]
  #define artoolkit_lpath $[wildcard $[ARTOOLKIT_LPATH]]
  #define artoolkit_libs $[ARTOOLKIT_LIBS]
#endif

#if $[HAVE_ROCKET]
  #define rocket_ipath $[wildcard $[ROCKET_IPATH]]
  #define rocket_lpath $[wildcard $[ROCKET_LPATH]]
  #define rocket_libs $[ROCKET_LIBS]
#endif

#if $[HAVE_BULLET]
  #define bullet_ipath $[wildcard $[BULLET_IPATH]]
  #define bullet_lpath $[wildcard $[BULLET_LPATH]]
  #define bullet_libs $[BULLET_LIBS]
#endif

#if $[HAVE_PHYSX]
  #define physx_ipath $[wildcard $[PHYSX_IPATH]]
  #define physx_lpath $[wildcard $[PHYSX_LPATH]]
  #define physx_libs $[PHYSX_LIBS]
#endif

#if $[HAVE_VORBIS]
  #define vorbis_ipath $[wildcard $[VORBIS_IPATH]]
  #define vorbis_lpath $[wildcard $[VORBIS_LPATH]]
  #define vorbis_libs $[VORBIS_LIBS]
#endif

#if $[HAVE_OPUS]
  #define opus_ipath $[wildcard $[OPUS_IPATH]]
  #define opus_lpath $[wildcard $[OPUS_LPATH]]
  #define opus_libs $[OPUS_LIBS]
#endif

#if $[HAVE_HARFBUZZ]
  #define harfbuzz_ipath $[wildcard $[HARFBUZZ_IPATH]]
  #define harfbuzz_lpath $[wildcard $[HARFBUZZ_LPATH]]
  #define harfbuzz_libs $[HARFBUZZ_LIBS]
#endif

#if $[HAVE_OPENEXR]
  #define openexr_ipath $[wildcard $[OPENEXR_IPATH]]
  #define openexr_lpath $[wildcard $[OPENEXR_LPATH]]
  #define openexr_libs $[OPENEXR_LIBS]
#endif

#if $[HAVE_VALVE_STEAMNET]
  #define valve_steamnet_ipath $[wildcard $[VALVE_STEAMNET_IPATH]]
  #define valve_steamnet_lpath $[wildcard $[VALVE_STEAMNET_LPATH]]
  #define valve_steamnet_cflags $[VALVE_STEAMNET_CFLAGS]
  #define valve_steamnet_libs $[VALVE_STEAMNET_LIBS]
#endif

#if $[HAVE_GLSLANG]
  #define glslang_ipath $[wildcard $[GLSLANG_IPATH]]
  #define glslang_lpath $[wildcard $[GLSLANG_LPATH]]
  #define glslang_libs $[GLSLANG_LIBS]
#endif

#if $[HAVE_SPIRV_TOOLS]
  #define spirv_tools_ipath $[wildcard $[SPIRV_TOOLS_IPATH]]
  #define spirv_tools_lpath $[wildcard $[SPIRV_TOOLS_LPATH]]
  #define spirv_tools_libs $[SPIRV_TOOLS_LIBS]
#endif

#if $[HAVE_SPIRV_CROSS]
  #define spirv_cross_ipath $[wildcard $[SPIRV_CROSS_IPATH]]
  #define spirv_cross_lpath $[wildcard $[SPIRV_CROSS_LPATH]]
  #define spirv_cross_libs $[SPIRV_CROSS_LIBS]
#endif

#if $[HAVE_EMBREE]
  #define embree_ipath $[wildcard $[EMBREE_IPATH]]
  #define embree_lpath $[wildcard $[EMBREE_LPATH]]
  #define embree_libs $[EMBREE_LIBS]
#endif

#if $[HAVE_OIDN]
  #define oidn_ipath $[wildcard $[OIDN_IPATH]]
  #define oidn_lpath $[wildcard $[OIDN_LPATH]]
  #define oidn_libs $[OIDN_LIBS]
#endif

// We define these two variables true here in the global scope; a
// particular Sources.pp file can redefine these to be false to
// prevent a particular directory or target from being built in
// certain circumstances.
#define BUILD_DIRECTORY 1
#define BUILD_TARGET 1

// This is the default extension for a Maya file.  It might be
// overridden within a maya_char_egg rule to convert a .ma file
// instead.
#define MAYA_EXTENSION .mb

// This variable, when evaluated in the scope of a particular directory,
// will indicate true (i.e. nonempty) when the directory is truly built,
// or false (empty) when the directory is not to be built.
#defer build_directory $[BUILD_DIRECTORY]
// It maps to a direct evaluation of the user-set variable,
// BUILD_DIRECTORY, for historical reasons.  This also allows us to
// reserve the right to extend this variable to test other conditions
// as well, should the need arise.

// This variable, when evaluated in the scope of a particular target,
// will indicated true when the target should be built, or false when
// the target is not to be built.
#defer build_target $[BUILD_TARGET]

// If we have USE_TAU but not TAU_MAKEFILE, we invoke the tau
// instrumentor and compiler directly.
#define direct_tau $[and $[USE_TAU],$[not $[TAU_MAKEFILE]]]

#if $[and $[USE_TAU],$[TAU_MAKEFILE]]
  // Use the makefile-based rules to run the tau instrumentor.
#defer compile_c $(TAU_COMPILER) $[TAU_OPTS] $[if $[SELECT_TAU],-optTauSelectFile=$[SELECT_TAU]] $[COMPILE_C] $[TAU_CFLAGS]
#defer compile_c++ $(TAU_COMPILER) $[TAU_OPTS] $[if $[SELECT_TAU],-optTauSelectFile=$[SELECT_TAU]] $[COMPILE_C++] $[TAU_CFLAGS] $[TAU_C++FLAGS]
#defer link_bin_c $(TAU_COMPILER) $[TAU_OPTS] $[if $[SELECT_TAU],-optTauSelectFile=$[SELECT_TAU]] $[LINK_BIN_C] $[TAU_CFLAGS]
#defer link_bin_c++ $(TAU_COMPILER) $[TAU_OPTS] $[if $[SELECT_TAU],-optTauSelectFile=$[SELECT_TAU]] $[LINK_BIN_C++] $[TAU_CFLAGS] $[TAU_C++FLAGS]
#defer shared_lib_c $(TAU_COMPILER) $[TAU_OPTS] $[if $[SELECT_TAU],-optTauSelectFile=$[SELECT_TAU]] $[SHARED_LIB_C] $[TAU_CFLAGS]
#defer shared_lib_c++ $(TAU_COMPILER) $[TAU_OPTS] $[if $[SELECT_TAU],-optTauSelectFile=$[SELECT_TAU]] $[SHARED_LIB_C++] $[TAU_CFLAGS] $[TAU_C++FLAGS]

#else
#defer compile_c $[COMPILE_C]
#defer compile_c++ $[COMPILE_C++]
#defer link_bin_c $[LINK_BIN_C]
#defer link_bin_c++ $[LINK_BIN_C++]
#defer shared_lib_c $[SHARED_LIB_C]
#defer shared_lib_c++ $[SHARED_LIB_C++]
#endif  // USE_TAU

#defer static_lib_c $[STATIC_LIB_C]
#defer static_lib_c++ $[STATIC_LIB_C++]
#defer bundle_lib_c $[BUNDLE_LIB_C++]
#defer bundle_lib_c++ $[BUNDLE_LIB_C++]

// "lib" is the default prefix applied to every generated library.
// This comes from Unix convention.  This can be redefined on a
// per-target basis.
#define LIB_PREFIX lib
#defer lib_prefix $[LIB_PREFIX]

// OSX has a "bundle" concept.  This is kind of like a dylib, but not
// quite.  Sometimes you might want to link a library *as* a bundle
// instead of as a dylib; sometimes you might want to link a library
// into a dylib *and* a bundle.
#defer bundle_ext $[BUNDLE_EXT]
#defer link_as_bundle $[and $[OSX_PLATFORM],$[LINK_AS_BUNDLE]]

// On OSX 10.4, we need to have both a .dylib and an .so file.
#defer link_extra_bundle $[and $[OSX_PLATFORM],$[or $[LINK_EXTRA_BUNDLE],$[BUNDLE_EXT]],$[not $[LINK_AS_BUNDLE]],$[not $[LINK_ALL_STATIC]],$[not $[lib_is_static]]]

// The default library extension various based on the OS.
#defer dynamic_lib_ext $[DYNAMIC_LIB_EXT]
#defer static_lib_ext $[STATIC_LIB_EXT]
#defer lib_ext $[if $[link_as_bundle],$[bundle_ext],$[if $[lib_is_static],$[static_lib_ext],$[dynamic_lib_ext]]]

#defer link_lib_c $[if $[link_as_bundle],$[bundle_lib_c],$[if $[lib_is_static],$[static_lib_c],$[shared_lib_c]]]
#defer link_lib_c++ $[if $[link_as_bundle],$[bundle_lib_c++],$[if $[lib_is_static],$[static_lib_c++],$[shared_lib_c++]]]


// If BUILD_COMPONENTS is not true, we don't actually build all the
// libraries.  In particular, we don't build any libraries that are
// listed on a metalib.  This variable can be evaluated within a
// library's scope to determine whether it should be built according
// to this rule.
#defer build_lib $[or $[BUILD_COMPONENTS],$[eq $[module $[TARGET],$[TARGET]],]]

// This variable is true if the lib has an associated pdb (Windows
// only).  It appears that pdb's are generated only for dll's, not for
// static libs.
#defer has_pdb $[and $[build_pdbs],$[not $[lib_is_static]]]


// This takes advantage of the above two variables to get the actual
// list of local libraries we are to link with, eliminating those that
// won't be built.
#defer active_local_libs \
  $[all_libs $[if $[and $[build_directory],$[build_target],$[not $[is_interface]]],$[TARGET]],$[LOCAL_LIBS]]
#defer active_component_libs \
  $[all_libs $[if $[and $[build_directory],$[build_target],$[not $[is_interface]]],$[TARGET]],$[COMPONENT_LIBS]]
#defer active_igate_libs \
  $[all_libs $[if $[and $[build_directory],$[build_target],$[not $[is_interface]]],$[TARGET]],$[IGATE_LIBS]]
#defer active_other_libs \
  $[if $[BUILD_COMPONENTS], \
    $[patsubst %:m,,%:c,%,$[OTHER_LIBS]], \
    $[patsubst %:c,,%:m,%,$[OTHER_LIBS]]]

#defer active_libs $[active_local_libs] $[active_component_libs] $[active_igate_libs] $[active_other_libs]

// We define $[complete_local_libs] as the full set of libraries (from
// within this tree) that we must link a particular target with.  It
// is the transitive closure of our dependent libs: the libraries we
// depend on, plus the libraries *those* libraries depend on, and so on.
#defer nonunique_complete_local_libs $[closure all_libs,$[active_libs]]
#defer complete_local_libs $[unique $[nonunique_complete_local_libs]]


// This is essentially the same as above, but it returns the full
// set of include paths to add for all of the local libraries we are
// linking with.  The difference is that interface libraries are
// omitted from $[active_libs] (because there is no code to build),
// but they are included on the ipath.
#defer active_local_incs \
  $[all_libs $[if $[and $[build_directory],$[build_target]],$[TARGET]],$[LOCAL_LIBS]]
#defer active_component_incs \
  $[all_libs $[if $[and $[build_directory],$[build_target]],$[TARGET]],$[COMPONENT_LIBS]]
#defer active_igate_incs \
  $[all_libs $[if $[and $[build_directory],$[build_target]],$[TARGET]],$[IGATE_LIBS]]
#defer active_incs $[active_local_incs] $[active_component_incs] $[active_igate_incs]

// We define $[complete_local_incs] as the full set of include paths
// (from within this tree) that we must specify for a particular target.
// It is the transitive closure of our dependent libs: the libraries we
// depend on, plus the libraries *those* libraries depend on, and so on.
#defer nonunique_complete_local_incs $[closure all_libs,$[active_incs]]
#defer complete_local_incs $[unique $[nonunique_complete_local_incs]]

// And $[complete_ipath] is the list of directories (from within this
// tree) we should add to our -I list.  It's basically just one for
// each directory named in the $[complete_local_libs], above, plus
// whatever else the user might have explicitly named in
// $[LOCAL_INCS].  LOCAL_INCS MUST be a ppremake src dir! (RELDIR only
// checks those) To add an arbitrary extra include dir, define
// EXTRA_IPATH in the Sources.pp
#defer complete_ipath $[all_libs $[RELDIR],$[complete_local_incs]] $[RELDIR($[LOCAL_INCS:%=%/])] $[EXTRA_IPATH]

// This variable, when evaluated within a target, will either be empty
// string if the target is not to be built, or the target name if it
// is.
#defer active_target $[if $[build_target],$[TARGET]]
#defer active_target_libprefext $[if $[build_target],$[get_output_file]]
#defer active_target_bundleext $[if $[and $[build_target],$[link_extra_bundle]],$[get_output_bundle_file]]

// This subroutine will set up the sources variable to reflect the
// complete set of sources for this target, and also set the
// alt_cflags, alt_libs, etc. as appropriate according to how the
// various USE_* flags are set for the current target.

// This variable returns the complete set of sources for the current
// target.

#defer get_sources \
  $[SOURCES] \
  $[COMPOSITE_SOURCES]

#defer composite_sources $[COMPOSITE_SOURCES]

// This variable returns whether or not a composite source file should be
// created for a particular target.
#defer should_composite_sources \
  $[and $[not $[DONT_COMPOSITE]], $[> $[words $[composite_sources]], 1], \
      $[or $[USE_SINGLE_COMPOSITE_SOURCEFILE],$[USE_TAU]]]

// This variable returns the set of sources that are to be
// interrogated for the current target.  The target will only
// be interrogated if it is part of a module.
#defer get_igatescan \
  $[if $[and $[run_interrogate],$[IGATESCAN],$[python_module $[TARGET],$[TARGET]]], \
     $[if $[eq $[IGATESCAN], all], \
      $[filter-out %.I %.T %.lxx %.yxx %.N %_src.cxx %_src.h %_src.c,$[get_sources]], \
      $[IGATESCAN]] $[get_igateext]]

// This variable returns the set of sources that are to be
// treated as interrogate extensions for the current target.
// These are compiled and linked into the Python module, as
// if it were interrogate-generated code.
#defer get_igateext \
  $[if $[and $[run_interrogate],$[IGATEEXT]], \ // FIXME: Should $[IGATESCAN] be required as well?
    $[filter %.cxx %.h, $[IGATEEXT]]]

// This variable returns the name of the interrogate database file
// that will be generated for a particular target, or empty string if
// the target is not to be interrogated.
#defer get_igatedb \
  $[if $[and $[run_interrogate],$[get_igatescan]], \
    $[ODIR]/$[get_output_name]$[dllext].in]

// This variable returns the name of the interrogate code file
// that will be generated for a particular target, or empty string if
// the target is not to be interrogated.
#defer get_igateoutput \
  $[if $[and $[run_interrogate],$[get_igatescan]], \
    $[ODIR]/$[get_output_name]_igate.cxx]

// This variable returns the complete set of code files that are to
// be compiled and linked into a Python module for a particular
// target.
#defer get_igatecode $[get_igateoutput] $[filter %.cxx, $[get_igateext]]

// This variable is the set of .in files generated by all of our
// interrogated libraries.  If it is nonempty, then we do need to
// generate a module, and $[get_igatemout] is the name of the .cxx file
// that interrogate will produce to make this module.
// Also, $[get_igatemcode] is the set of .cxx files that will be compiled
// and linked into this module.
#defer get_igatemscan $[components $[get_igatedb:%=$[RELDIR]/%],$[active_igate_libs]]
#defer get_igatemcode $[components $[get_igatecode:%=$[RELDIR]/%],$[active_igate_libs]]
#defer get_igatemout $[if $[get_igatemscan],$[ODIR]/$[get_output_name]_module.cxx]

// This variable returns the set of external packages used by this
// target, and by all the components shared by this target.
#defer use_packages $[unique $[USE_PACKAGES] $[all_libs $[USE_PACKAGES], $[complete_local_libs]]]

#defer get_output_name $[lib_prefix]$[if $[OUTPUT],$[OUTPUT],$[TARGET]]
#defer get_output_file_noext $[get_output_name]$[dllext]
#defer get_output_file $[get_output_name]$[dllext]$[lib_ext]
#defer get_output_bundle_file $[get_output_name]$[dllext]$[bundle_ext]

// This function returns the appropriate cflags for the target, based
// on the various external packages this particular target claims to
// require.
#defun get_cflags
  // hack to add stl,python.  should be removed
  //#define alt_cflags $[if $[IGNORE_LIB_DEFAULTS_HACK],,$[stl_cflags] $[python_cflags] $[if $[HAVE_EIGEN],$[eigen_cflags]]]
  #define alt_cflags

  #foreach package $[use_packages]
    #set alt_cflags $[alt_cflags] $[$[package]_cflags]
  #end package

  $[unique $[alt_cflags]]
#end get_cflags

// This function returns the appropriate lflags for the target, based
// on the various external packages this particular target claims to
// require.
#defun get_lflags
  // hack to add stl,python.  should be removed
  //#define alt_lflags $[if $[IGNORE_LIB_DEFAULTS_HACK],,$[stl_lflags] $[python_lflags]]
  #define alt_lflags

  #foreach package $[use_packages]
    #set alt_lflags $[alt_lflags] $[$[package]_lflags]
  #end package

  $[unique $[alt_lflags]]
#end get_lflags

// This function returns the appropriate include path for the target,
// based on the various external packages this particular target
// claims to require.  This returns a space-separated set of directory
// names only; the -I switch is not included here.
#defun get_ipath
  // hack to add stl,python.  should be removed
  //#define alt_ipath $[if $[IGNORE_LIB_DEFAULTS_HACK],,$[stl_ipath] $[python_ipath] $[tau_ipath] $[if $[HAVE_EIGEN],$[eigen_ipath]]]
  #define alt_ipath
  #foreach package $[use_packages]
    #set alt_ipath $[alt_ipath] $[$[package]_ipath]
  #end package

  $[unique $[alt_ipath]]
#end get_ipath

// This function returns the appropriate library search path for the
// target, based on the various external packages this particular
// target claims to require.  This returns a space-separated set of
// directory names only; the -L switch is not included here.
#defun get_lpath
  //#define alt_lpath $[if $[IGNORE_LIB_DEFAULTS_HACK],,$[stl_lpath] $[python_lpath]]
  #define alt_lpath

  #if $[WINDOWS_PLATFORM]
    #set alt_lpath $[WIN32_PLATFORMSDK_LIBPATH] $[alt_lpath]
  #endif

  #foreach package $[use_packages]
    #set alt_lpath $[alt_lpath] $[$[package]_lpath]
  #end package

  $[unique $[alt_lpath]]
#end get_lpath

// This function returns the appropriate framework search path for the
// target, based on the various external frameworks this particular
// target claims to require.  This returns a space-separated set of
// directory names only; the -F switch is not included here.
#defun get_fpath
  //#define alt_fpath $[if $[IGNORE_LIB_DEFAULTS_HACK],,$[stl_fpath] $[python_fpath]]
  #define alt_fpath

  #foreach package $[use_packages]
    #set alt_fpath $[alt_fpath] $[$[package]_fpath]
  #end package

  $[unique $[alt_fpath]]
#end get_fpath

// This function returns the appropriate framework for the
// target, based on the various external frameworks this particular
// target claims to require.  This returns a space-separated set of
// framework names only; the -framework switch is not included here.
#defun get_frameworks
  //#define alt_frameworks $[if $[IGNORE_LIB_DEFAULTS_HACK],,$[stl_framework] $[python_framework]]
  #define alt_frameworks

  #if $[OSX_PLATFORM]
    #set alt_frameworks $[alt_frameworks] $[OSX_SYS_FRAMEWORKS]
  #endif

  #foreach package $[use_packages]
    #set alt_frameworks $[alt_frameworks] $[$[package]_framework]
  #end package

  $[unique $[alt_frameworks]]
#end get_frameworks

// This function returns the appropriate set of library names to link
// with for the target, based on the various external packages this
// particular target claims to require.  This returns a
// space-separated set of library names only; the -l switch is not
// included here.
#defun get_libs
  //#define alt_libs $[if $[IGNORE_LIB_DEFAULTS_HACK],,$[stl_libs] $[python_libs]]
  #define alt_libs

  #define alt_libs $[alt_libs] $[EXTRA_LIBS]

  #if $[WINDOWS_PLATFORM]
    #set alt_libs $[alt_libs] $[WIN_SYS_LIBS] $[components $[WIN_SYS_LIBS],$[active_libs] $[transitive_link]]
  #elif $[OSX_PLATFORM]
    #set alt_libs $[alt_libs] $[OSX_SYS_LIBS] $[components $[OSX_SYS_LIBS],$[active_libs] $[transitive_link]]
  #elif $[eq $[PLATFORM], Android]
    #set alt_libs $[alt_libs] $[ANDROID_SYS_LIBS] $[components $[ANDROID_SYS_LIBS],$[active_libs] $[transitive_link]]
  #else
    #set alt_libs $[alt_libs] $[UNIX_SYS_LIBS] $[components $[UNIX_SYS_LIBS],$[active_libs] $[transitive_link]]
  #endif

  #foreach package $[use_packages]
    #set alt_libs $[alt_libs] $[$[package]_libs]
  #end package

  $[unique $[alt_libs]]
#end get_libs

// This function returns the appropriate value for ld for the target.
#defun get_ld
  #if $[filter maya,$[use_packages]]
    $[maya_ld]
  #endif
#end get_ld

// This function determines the set of files a given source file
// depends on.  It is based on the setting of the $[filename]_sources
// variable to indicate the sources for composite files, etc.
#defun get_depends source
  #if $[$[source]_sources]
    #if $[ne $[$[source]_sources],none]
      $[$[source]_sources] $[dependencies $[$[source]_sources]]
    #endif
  #else
    $[dependencies $[source]]
  #endif
#end get_depends


// This function determines the set of libraries our various targets
// depend on.  This is a complicated definition.  It is the union of
// all of our targets' dependencies, except:

// If a target is part of a metalib, it depends (a) directly on all of
// its normal library dependencies that are part of the same metalib,
// and (b) indirectly on all of the metalibs that every other library
// dependency is part of.  If a target is not part of a metalib, it is
// the same as case (b) above.
#defun get_depend_libs
  #define depend_libs
  #forscopes lib_target noinst_lib_target test_lib_target
    #define metalib $[module $[TARGET],$[TARGET]]
    #if $[ne $[metalib],]
      // This library is included on a metalib.
      #foreach depend $[LOCAL_LIBS]
        #define depend_metalib $[module $[TARGET],$[depend]]
        #if $[eq $[depend_metalib],$[metalib]]
          // Here's a dependent library in the *same* metalib.
          #set depend_libs $[depend_libs] $[depend]
        #elif $[ne $[depend_metalib],]
          // This dependent library is in a *different* metalib.
          #set depend_libs $[depend_libs] $[depend_metalib]
        #else
          // This dependent library is not in any metalib.
          #set depend_libs $[depend_libs] $[depend]
        #endif
      #end depend
    #else
      // This library is *not* included on a metalib.
      #foreach depend $[LOCAL_LIBS]
        #define depend_metalib $[module $[TARGET],$[depend]]
        #if $[ne $[depend_metalib],]
          // This dependent library is on a metalib.
          #set depend_libs $[depend_libs] $[depend_metalib]
        #else
          // This dependent library is not in any metalib.
          #set depend_libs $[depend_libs] $[depend]
        #endif
      #end depend
    #endif
  #end lib_target noinst_lib_target test_lib_target

  // These will never be part of a metalib.
  #forscopes static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target metalib_target python_module_target python_target

    #foreach depend $[LOCAL_LIBS]
      #define depend_metalib $[module $[TARGET],$[depend]]
      #if $[ne $[depend_metalib],]
        // This dependent library is on a metalib.
        #if $[eq $[depend_metalib],$[TARGET]]
          #print Warning: $[TARGET] circularly depends on $[depend].
        #else
          #set depend_libs $[depend_libs] $[depend_metalib]
        #endif
      #else
        // This dependent library is not in any metalib.
        #set depend_libs $[depend_libs] $[depend]
      #endif
    #end depend
  #end static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target metalib_target python_module_target python_target

  // In case we're defining any metalibs, these depend directly on
  // their components as well.
  #set depend_libs $[depend_libs] $[COMPONENT_LIBS(metalib_target)]
  // Python modules also depend directly on their igate libs.
  #set depend_libs $[depend_libs] $[IGATE_LIBS(python_module_target)]

  $[depend_libs]
#end get_depend_libs


// dtool/pptempl/Global.pp

// Define a few directories that will be useful.

#define install_dir $[$[upcase $[PACKAGE]]_INSTALL]
#if $[eq $[install_dir],]
  #error Variable $[upcase $[PACKAGE]]_INSTALL is not set!  Cannot install!
#endif

#define other_trees
#define other_trees_lib
#define other_trees_include
#foreach tree $[NEEDS_TREES]
  #define tree_install $[$[upcase $[tree]]_INSTALL]
  #if $[eq $[tree_install],]
Warning: Variable $[upcase $[tree]]_INSTALL is not set!
  #else
    #set other_trees $[other_trees] $[tree_install]
    #set other_trees_lib $[other_trees_lib] $[tree_install]/lib
    #set other_trees_include $[other_trees_include] $[tree_install]/include
  #endif
#end tree

#define install_lib_dir $[or $[INSTALL_LIB_DIR],$[install_dir]/lib]
#define other_trees_lib $[or $[INSTALL_LIB_DIR],$[other_trees_lib]]

#define install_headers_dir $[or $[INSTALL_HEADERS_DIR],$[install_dir]/include]
#define other_trees_include $[or $[INSTALL_HEADERS_DIR],$[other_trees_include]]

#define install_bin_dir $[or $[INSTALL_BIN_DIR],$[install_dir]/bin]
#define install_data_dir $[or $[INSTALL_DATA_DIR],$[install_dir]/shared]
#define install_igatedb_dir $[or $[INSTALL_IGATEDB_DIR],$[install_dir]/etc]
#define install_config_dir $[or $[INSTALL_CONFIG_DIR],$[install_dir]/etc]
#defer install_scripts_dir $[or $[INSTALL_SCRIPTS_DIR],$[install_dir]/bin]

// Where are we installing Python code?
#defer install_py_dir $[install_lib_dir]/$[PACKAGE]/$[DIRNAME]
#defer install_py_package_dir $[install_lib_dir]/$[PACKAGE]

// Where are we installing Python modules?
// Note we have to define two directories, $[install_py_module_dir], where
// the actual modules are installed, and $[install_py_module_dir_old] to
// generate a compatibility shim that just imports the actual dir.
#if $[and $[WINDOWS_PLATFORM],$[DTOOL_INSTALL]]
  // On Windows, we need all of our Python modules under a single "panda3d"
  // directory so we can create the __init__.py file that appends each
  // directory on the PATH to the Python DLL search path.
  #define install_py_module_dir $[DTOOL_INSTALL]/lib/panda3d
#else
  #define install_py_module_dir $[install_lib_dir]/panda3d
#endif

#define install_py_module_dir_old $[install_lib_dir]/pandac

#if $[ne $[DTOOL_INSTALL],]
  #define install_parser_inc_dir $[DTOOL_INSTALL]/include/parser-inc
#else
  #define install_parser_inc_dir $[install_headers_dir]/parser-inc
#endif

// Set up the correct interrogate options.

// $[dllext] is redefined in the Windows Global.platform.pp files to
// the string _d if we are building a debug tree.  This is inserted
// into the .dll and .in filenames before the extension to make a
// runtime distinction between debug and non-debug builds.  For now,
// we make a global definition to empty string, since non-Windows
// platforms will leave this empty.
#define dllext

// $[obj_prefix] defines the prefix that is prepended to the name of
// the object files.  It can be used to avoid potential collisions
// when a source file is used by multiple targets but with different
// compile options for each.
//
// $[obj_prefix] may be redefined by one of the Global.platform.pp
// files.
#defer obj_prefix $[get_output_name]_

// Caution!  interrogate_ipath might be redefined in the
// Global.platform.pp file.
#defer interrogate_ipath $[install_parser_inc_dir:%=-S%] $[INTERROGATE_SYSTEM_IPATH:%=-S%] $[target_ipath:%=-I%]

#defer interrogate_options \
    -DCPPPARSER -D__STDC__=1 -D__cplusplus $[SYSTEM_IGATE_FLAGS] \
    $[interrogate_ipath] \
    $[CDEFINES_OPT$[OPTIMIZE]:%=-D%] \
    $[filter -D%,$[C++FLAGS]] \
    $[INTERROGATE_OPTIONS] \
    $[if $[INTERROGATE_PYTHON_INTERFACE],$[if $[PYTHON_NATIVE],-python-native,-python]] \
    $[if $[INTERROGATE_C_INTERFACE],-c] \
    $[if $[<= $[OPTIMIZE], 1],-spam]

#defer interrogate_module_options \
    $[if $[INTERROGATE_PYTHON_INTERFACE],$[if $[PYTHON_NATIVE],-python-native,-python]] \
    $[if $[INTERROGATE_C_INTERFACE],-c] \
    $[if $[IMPORT],$[patsubst %,-import %, $[IMPORT]]]


// The language stuff is used by model builds only.
// Set language_filters to be "%_english %_castillian %_japanese %_german" etc.
#if $[LANGUAGES]
  #define language_filters $[subst <pct>,%,$[LANGUAGES:%=<pct>_%]]
  #print Using language $[LANGUAGE]
#else
  #define language_filters
#endif
#define language_egg_filters $[language_filters:%=%.egg]
#define language_dna_filters $[language_filters:%=%.dna]

// This is used for evaluating SoftImage unpack rules in Template.models.pp.
#defer soft_scene_files $[matrix $[DATABASE]/SCENES/$[SCENE_PREFIX],$[MODEL] $[ANIMS],.1-0.dsc]

// This is also only used by model builds.
// This dictionary will be filled up by the templates within the source
// hierarchy.  It maps source assets to their built and installed counterparts.
#if $[eq $[dirnames $[DIR_TYPE], top], models_toplevel]

// #dict is a newer addition, make sure we are running a ppremake that supports
// them.
#if $[< $[PPREMAKE_VERSION],1.23]
  #error You need at least ppremake version 1.23 to build models.
#endif

#dict texture_index
#dict material_index
#dict model_index
#dict dna_index
#dict misc_index
#endif

// Include the global definitions for this particular build_type, if
// the file is there.
#sinclude $[GLOBAL_TYPE_FILE]
