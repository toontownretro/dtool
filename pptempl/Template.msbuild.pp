//
// Template.msbuild.pp
//
// This file defines the set of output files that will be generated to
// support Microsoft's MSBuild build system.  In particular, it generates
// a VC++ project file for each target, and all project files are colleected
// into a top-level Visual Studio Solution file for the package.
//

// Before this file is processed, the following files are read and
// processed (in order):

// The Package.pp file in the root of the current source hierarchy
//   (e.g. $PANDA/Package.pp)
// $DTOOL/Package.pp
// $DTOOL/Config.pp
// $DTOOL/Config.Platform.pp
// The user's PPREMAKE_CONFIG file.
// $DTOOL/pptempl/System.pp
// All of the Sources.pp files in the current source hierarchy
// $DTOOL/pptempl/Global.pp
// $DTOOL/pptempl/Global.gmsvc.pp
// $DTOOL/pptempl/Depends.pp, once for each Sources.pp file
// Template.msbuild.pp (this file), once for each Sources.pp file

#if $[ne $[DTOOL],]
#define dtool_ver_dir_cyg $[DTOOL]/src/dtoolbase
#define dtool_ver_dir $[osfilename $[dtool_ver_dir_cyg]]
#endif

//
// Correct LDFLAGS_OPT 3,4 here to get around early evaluation of, even
// if deferred
//
#defer nodefaultlib_cstatic \
  $[if $[ne $[LINK_FORCE_STATIC_RELEASE_C_RUNTIME],], \
     /NODEFAULTLIB:MSVCRT.LIB, \
     /NODEFAULTLIB:LIBCMT.LIB \
   ]
#defer LDFLAGS_OPT3 $[LDFLAGS_OPT3] $[nodefaultlib_cstatic]
#defer LDFLAGS_OPT4 $[LDFLAGS_OPT4] $[nodefaultlib_cstatic]

//////////////////////////////////////////////////////////////////////
#if $[or $[eq $[DIR_TYPE], src],$[eq $[DIR_TYPE], metalib],$[eq $[DIR_TYPE], module]]
//////////////////////////////////////////////////////////////////////
// For a source directory, build a single Makefile with rules to build
// each target.

#if $[build_directory]
  // This is the real set of lib_targets we'll be building.  On Windows,
  // we don't build the shared libraries which are included on metalibs.
  #define real_lib_targets
  #define real_lib_target_libs
  #define deferred_objs
  #forscopes lib_target
    #if $[build_target]
      #if $[eq $[module $[TARGET],$[TARGET]],]
        // This library is not on a metalib, so we can build it.
        #set real_lib_targets $[real_lib_targets] $[TARGET]
        #set real_lib_target_libs $[real_lib_target_libs] $[ODIR]/$[get_output_file]
      #else
        // This library is on a metalib, so we can't build it, but we
        // should build all the obj's that go into it.
        #set deferred_objs $[deferred_objs] \
          $[patsubst %,$[%_obj],$[compile_sources]]
      #endif
    #endif
  #end lib_target

  // We need to know the various targets we'll be building.
  // $[lib_targets] will be the list of dynamic and static libraries,
  // and $[bin_targets] the list of binaries.  $[test_bin_targets] is
  // the list of binaries that are to be built only when specifically
  // asked for.

  #define lib_targets \
    $[forscopes python_target python_module_target metalib_target \
                noinst_lib_target test_lib_target static_lib_target \
                dynamic_lib_target ss_lib_target, \
      $[if $[build_target],$[ODIR]/$[get_output_file]]] $[real_lib_target_libs]

  #define bin_targets \
      $[active_target(bin_target noinst_bin_target csharp_target):%=$[ODIR]/%.exe] \
      $[active_target(sed_bin_target):%=$[ODIR]/%]
  #define test_bin_targets $[active_target(test_bin_target):%=$[ODIR]/%.exe]

  #defer test_lib_targets $[active_target(test_lib_target):%=$[if $[TEST_ODIR],$[TEST_ODIR],$[ODIR]]/%$[dllext]$[lib_ext]]

  // And these variables will define the various things we need to
  // install.
  #define install_lib $[active_target(metalib_target static_lib_target dynamic_lib_target ss_lib_target)] $[real_lib_targets]
  #define install_bin $[active_target(bin_target)]
  #define install_scripts $[sort $[INSTALL_SCRIPTS(metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target)] $[INSTALL_SCRIPTS]]
  #define install_modules $[sort $[INSTALL_MODULES(metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target)] $[INSTALL_MODULES]]
  #define install_headers $[sort $[INSTALL_HEADERS(interface_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target)] $[INSTALL_HEADERS]]
  #define install_parser_inc $[sort $[INSTALL_PARSER_INC]]
  #define install_data $[sort $[INSTALL_DATA(metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target)] $[INSTALL_DATA]]
  #define install_config $[sort $[INSTALL_CONFIG(metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target)] $[INSTALL_CONFIG]]
  #define install_igatedb $[sort $[get_igatedb(metalib_target lib_target)]]

  // These are the various sources collected from all targets within the
  // directory.
  #define st_sources $[sort $[compile_sources(python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target csharp_target)]]
  #define yxx_st_sources $[sort $[yxx_sources(metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target)]]
  #define lxx_st_sources $[sort $[lxx_sources(metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target)]]
  #define dep_sources_1  $[sort $[get_sources(interface_target python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target)]]

  // These are the source files that our dependency cache file will
  // depend on.  If it's an empty list, we won't bother writing rules to
  // freshen the cache file.
  #define dep_sources $[sort $[filter %.c %.cxx %.cpp %.yxx %.lxx %.h %.hpp %.I %.T,$[dep_sources_1]]]

  // If there is an __init__.py in the directory, then all Python
  // files in the directory just get installed without having to be
  // named.
  #if $[and $[INSTALL_PYTHON_SOURCE],$[wildcard $[TOPDIR]/$[DIRPREFIX]__init__.py]]
    #define py_sources $[wildcard $[TOPDIR]/$[DIRPREFIX]*.py]
  #endif
  #define install_py $[py_sources:$[TOPDIR]/$[DIRPREFIX]%=%]

  #define install_py_module $[active_target(python_module_target python_target)]

#endif  // $[build_directory]

#defer actual_local_libs $[get_metalibs $[TARGET],$[complete_local_libs]]

// $[static_lib_dependencies] is the set of libraries we will link
// with that happen to be static libs.  We will introduce dependency
// rules for these.  (We don't need dependency rules for dynamic libs,
// since these don't get burned in at build time.)
#defer static_lib_dependencies $[all_libs $[if $[and $[lib_is_static],$[build_lib]],$[RELDIR:%=%/$[ODIR]/$[get_output_file]]],$[complete_local_libs]]

// $[target_ipath] is the proper ipath to put on the command line,
// from the context of a particular target.

#defer target_ipath $[TOPDIR] $[sort $[complete_ipath]] $[other_trees_include] $[get_ipath]

// $[converted_ipath] is the properly-formatted version of the include path
// for Visual Studio .NET.  The resulting list is semicolon separated and uses
// Windows-style pathnames.
#defer converted_ipath $[join ;,$[osfilename $[target_ipath]]]

// These are the complete set of extra flags the compiler requires.
#defer cflags $[get_cflags] $[CFLAGS] $[CFLAGS_OPT$[OPTIMIZE]]
#defer c++flags $[get_cflags] $[C++FLAGS] $[CFLAGS_OPT$[OPTIMIZE]]

// $[complete_lpath] is rather like $[complete_ipath]: the list of
// directories (from within this tree) we should add to our -L list.
#defer complete_lpath $[libs $[RELDIR:%=%/$[ODIR]],$[actual_local_libs]] $[EXTRA_LPATH]

// $[lpath] is like $[target_ipath]: it's the list of directories we
// should add to our -L list, from the context of a particular target.
#defer lpath $[sort $[complete_lpath]] $[other_trees_lib] $[get_lpath]

// $[converted_lpath] is the properly-formatted version of the library path
// for Visual Studio .NET.  The resulting list is semicolon separated and uses
// Windows-style pathnames.
#defer converted_lpath $[join ;,$[osfilename $[lpath]]]

// $[libs] is the set of libraries we will link with.
#defer libs $[unique $[actual_local_libs:%=%$[dllext]] $[get_libs]]

#defer converted_libs $[patsubst %.lib,%.lib,%,lib%.lib,$[libs]]

// This is the set of files we might copy into *.prebuilt, if we have
// bison and flex (or copy from *.prebuilt if we don't have them).
#define bison_prebuilt $[patsubst %.yxx,%.cxx %.h,$[yxx_st_sources]] $[patsubst %.lxx,%.cxx,$[lxx_st_sources]]

#define vs_platform_name $[if $[WIN64_PLATFORM],x64,Win32]

#defer vs_lib_config_type $[if $[lib_is_static],Static Library,Dynamic Library]

#defer opt_cxx_flags \
  $[get_cflags] $[C++FLAGS] $[CFLAGS_OPT$[level]]

// Returns the list of preprocessor definitions.
#defer vs_preprocessor_definitions \
  $[join ;,$[patsubst /D%,%,$[filter /D%,$[opt_cxx_flags]]]]

#defer vs_compiler_flags \
  $[filter-out /D%,$[opt_cxx_flags]]

#define optimize_levels 1 2 3 4

#defun get_optimize_base_config level
  #define ret

  #if $[eq $[level],1]
    #set ret Debug
  #elif $[eq $[level],2]
    #set ret Debug
  #elif $[eq $[level], 3]
    #set ret Release
  #elif $[eq $[level], 4]
    #set ret Release
  #endif

  $[ret]
#end get_optimize_base_config

// Rather than making a rule to generate each install directory later,
// we create the directories now.  This reduces problems from
// multiprocess builds.
#mkdir $[sort \
    $[if $[install_lib],$[install_lib_dir]] \
    $[if $[install_bin] $[install_scripts],$[install_bin_dir]] \
    $[if $[install_bin] $[install_modules],$[install_lib_dir]] \
    $[if $[install_headers],$[install_headers_dir]] \
    $[if $[install_parser_inc],$[install_parser_inc_dir]] \
    $[if $[install_data],$[install_data_dir]] \
    $[if $[install_config],$[install_config_dir]] \
    $[if $[install_igatedb],$[install_igatedb_dir]] \
    $[if $[install_py],$[install_py_dir] $[install_py_package_dir]] \
    $[if $[install_py_module],$[install_py_module_dir]] \
    ]

// Similarly, we need to ensure that $[ODIR] exists.  Trying to make
// the makefiles do this automatically just causes problems with
// multiprocess builds.
#mkdir $[ODIR] $[TEST_ODIR]

// Pre-compiled headers are one way to speed the compilation of many
// C++ source files that include similar headers, but it turns out a
// more effective (and more portable) way is simply to compile all the
// similar source files in one pass.

// We do this by generating a *_composite.cxx file that has an
// #include line for each of several actual source files, and then we
// compile the composite file instead of the original files.
#foreach composite_file $[composite_list]
#output $[composite_file] notouch
#format collapse
/* Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. */
/* ################################# DO NOT EDIT ########################### */

#foreach file $[$[composite_file]_sources]
#if $[USE_TAU]
// For the benefit of Tau, we copy the source file verbatim into the
// composite file.  (Tau doesn't instrument files picked up via #include.)
#copy $[DIRPREFIX]$[file]

#else
##include "$[file]"
#endif  // USE_TAU
#end file

#end $[composite_file]
#end composite_file

// Okay, we're ready.  Start outputting the Makefile now.
#output $[DIRNAME].msbuild
#format straight
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. -->
<!--                              DO NOT EDIT                                       -->
<Project DefaultTargets="all" ToolsVersion="16.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

// The 'all' rule makes all the stuff in the directory except for the
// test_bin_targets.  It doesn't do any installation, however.
#define all_targets \
    Makefile \
    $[if $[dep_sources],$[DEPENDENCY_CACHE_FILENAME]] \
    $[sort $[lib_targets] $[bin_targets]] \
    $[deferred_objs]

<Target Name="all" DependsOnTargets="$[join ;,$[all_targets]]"/>

// The 'test' rule makes all the test_bin_targets.
<Target Name="test" DependsOnTargets="$[join ;,$[test_bin_targets] $[test_lib_targets]]"/>

<Target Name="clean" DependsOnTargets="clean-igate">
#forscopes python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target
#if $[compile_sources]
  <Exec Command="del /f $[osfilename $[patsubst %,$[%_obj],$[compile_sources]]]"/>
#endif
#end python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target
#if $[deferred_objs]
  <Exec Command="del /f $[osfilename $[deferred_objs]]"/>
#endif
#if $[lib_targets] $[bin_targets] $[test_bin_targets]
  <Exec Command="del /f $[osfilename $[lib_targets] $[bin_targets] $[test_bin_targets]]"/>
#endif
#if $[yxx_st_sources] $[lxx_st_sources]
  <Exec Command="del /f $[osfilename $[patsubst %.yxx,%.cxx %.h,$[yxx_st_sources]] $[patsubst %.lxx,%.cxx,$[lxx_st_sources]]]"/>
#endif
#if $[py_sources]
  <Exec Command="del /f *.pyc *.pyo"/> // Also scrub out old generated Python code.
#endif
#if $[USE_TAU]
  <Exec Command="del /f $[osfilename $[ODIR]/*.il $[ODIR]/*.pdb *.inst.*]"/>  // scrub out tau-generated files.
#endif
</Target>

// 'cleanall' is intended to undo all the effects of running ppremake
// and building.  It removes everything except the Makefile.
<Target Name="cleanall" DependsOnTargets="clean">
#if $[st_sources]
  <Exec Command="del /f $[osfilename $[ODIR]]"/>
#endif
#if $[ne $[DEPENDENCY_CACHE_FILENAME],]
  <Exec Command="del /f $[osfilename $[DEPENDENCY_CACHE_FILENAME]]"/>
#endif
#if $[composite_list]
  <Exec Command="del /f $[osfilename $[composite_list]]"/>
#endif
</Target>

<Target Name="clean-igate">
#forscopes python_module_target lib_target ss_lib_target
  #define igatedb $[get_igatedb]
  #define igateoutput $[get_igateoutput]
  #define igatemscan $[get_igatemscan]
  #define igatemout $[get_igatemout]
  #if $[igatedb]
  <Exec Command="del /f $[osfilename $[igatedb]]"/>
  #endif
  #if $[igateoutput]
  <Exec Command="del /f $[osfilename $[igateoutput] $[$[igateoutput]_obj]]"/>
  #endif
  #if $[igatemout]
  <Exec Command="del /f $[osfilename $[igatemout] $[$[igatemout]_obj]]"/>
  #endif
#end python_module_target lib_target ss_lib_target
</Target>

// Now, 'install' and 'uninstall'.  These simply copy files into the
// install directory (or remove them).  The 'install' rule also makes
// the directories if necessary.
#define installed_files \
     $[INSTALL_SCRIPTS:%=$[install_bin_dir]/%] \
     $[INSTALL_MODULES:%=$[install_lib_dir]/%] \
     $[INSTALL_HEADERS:%=$[install_headers_dir]/%] \
     $[INSTALL_PARSER_INC:%=$[install_parser_inc_dir]/%] \
     $[INSTALL_DATA:%=$[install_data_dir]/%] \
     $[INSTALL_CONFIG:%=$[install_config_dir]/%] \
     $[if $[install_py],$[install_py:%=$[install_py_dir]/%] $[install_py_package_dir]/__init__.py]

#define installed_igate_files \
     $[get_igatedb(python_module_target lib_target ss_lib_target):$[ODIR]/%=$[install_igatedb_dir]/%]

#define install_targets \
     $[active_target(interface_target python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target):%=install-lib%] \
     $[active_target(bin_target sed_bin_target csharp_target):%=install-%] \
     $[installed_files]

<Target Name="install" DependsOnTargets="$[join ;,all $[install_targets]]"/>

<Target Name="install-igate" DependsOnTargets="$[join ;,$[sort $[installed_igate_files]]]"/>

<Target Name="uninstall" DependsOnTargets="$[join ;,$[active_target(interface_target python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target):%=uninstall-lib%] $[active_target(bin_target):%=uninstall-%]]">
#if $[installed_files]
  <Exec Command="del /f $[osfilename $[sort $[installed_files]]]"/>
#endif
</Target>

<Target Name="uninstall-igate">
#if $[installed_igate_files]
  <Exec Command="del /f $[osfilename $[sort $[installed_igate_files]]]"/>
#endif
</Target>

#if $[HAVE_BISON]
<Target Name="prebuild-bison" DependsOnTargets="$[join ;,$[patsubst %,%.prebuilt,$[bison_prebuilt]]]"/>
<Target Name="clean-prebuild-bison">
#if $[bison_prebuilt]
  <Exec Command="del /f $[osfilename $[sort $[patsubst %,%.prebuilt,$[bison_prebuilt]]]]"/>
#endif
</Target>
#endif

// Now it's time to start generating the rules to make our actual
// targets.
<Target Name="igate" DependsOnTargets="$[join ;,$[get_igatedb(python_module_target lib_target ss_lib_target)]]"/>

/////////////////////////////////////////////////////////////////////
// First, the dynamic and static libraries.
/////////////////////////////////////////////////////////////////////

#forscopes python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target

// We might need to define a BUILDING_ symbol for win32.  We use the
// BUILDING_DLL variable name, defined typically in the metalib, for
// this; but in some cases, where the library isn't part of a metalib,
// we define BUILDING_DLL directly for the target.

#define building_var
#if $[eq $[module $[TARGET],$[TARGET]],]
  // If we're not on a metalib, use the BUILDING_DLL directly from the target.
  #set building_var $[BUILDING_DLL]
#else
  // If we're on a metalib, use the metalib's BUILDING_DLL instead of ours.
  #set building_var $[module $[BUILDING_DLL],$[TARGET]]
#endif

// $[igatescan] is the set of C++ headers and source files that we
// need to scan for interrogate.  $[igateoutput] is the name of the
// generated .cxx file that interrogate will produce (and which we
// should compile into the library).  $[igatedb] is the name of the
// generated .in file that interrogate will produce (and which should
// be installed into the /etc directory).
#define igatescan $[get_igatescan]
#define igateoutput $[get_igateoutput]
#define igatedb $[get_igatedb]

// If this is a metalib, it may have a number of components that
// include interrogated interfaces.  If so, we need to generate a
// 'module' file within this library.  This is mainly necessary for
// Python; it contains a table of all of the interrogated functions,
// so we can load the library as a Python module and have access to
// the interrogated functions.

// $[igatemscan] is the set of .in files generated by all of our
// component libraries.  If it is nonempty, then we do need to
// generate a module, and $[igatemout] is the name of the .cxx file
// that interrogate will produce to make this module.
#define igatemscan $[get_igatemscan]
#define igatemout $[get_igatemout]

#if $[build_lib]
  // Now output the rule to actually link the library from all of its
  // various .obj files.

  #define sources \
   $[patsubst %,$[%_obj],$[compile_sources]]
  #if $[not $[BUILD_COMPONENTS]]
    // Also link in all of the component files directly into the metalib.
    #define sources $[sources] \
      $[components $[patsubst %,$[RELDIR]/$[%_obj],$[compile_sources]],$[active_component_libs]]
  #endif

  #define target $[ODIR]/$[get_output_file]
  #define flags   $[get_cflags] $[C++FLAGS] $[CFLAGS_OPT$[OPTIMIZE]] $[CFLAGS_SHARED] $[building_var:%=/D%]

<Target Name="$[target]" DependsOnTargets="$[join ;,$[sources] $[DLLBASEADDRFILENAME:%=$[dtool_ver_dir_cyg]/%]]">
  #define sources $[osfilename $[sources]]
  #if $[filter %.cxx %.cpp %.yxx %.lxx,$[get_sources]]
  <Exec Command='$[link_lib_c++]'/>
  #else
  <Exec Command='$[link_lib_c]'/>
  #endif
</Target>
#endif

#end python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target

</Project>

#end $[DIRNAME].msbuild

#endif
