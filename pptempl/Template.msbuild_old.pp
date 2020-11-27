//
// Template.msbuild.pp
//
// This file defines the set of output files that will be generated to
// support Microsoft's MSBuild build system.
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

// Converts the set of names to suitable MSBuild target names.
#defun targetname files
  $[subst -,_,.,_,/,_,$[files]]
#end targetname

// Converts the space-separated words to semicolon separated words.
#defun msjoin names
  $[join ;,$[names]]
#end msjoin

// Converts the space-seperated words to suitable MSBuild target names
// and separates them with a semicolon.
#defun jtargetname files
  $[msjoin $[targetname $[files]]]
#end jtargetname

// Writes an MSBuild line that invokes the given target on a single
// subdirectory project.
#defun msbuild target
  <MSBuild Projects="$[osfilename ./$[PATH]/$[dirname].proj]" Targets="$[target]" BuildInParallel="true"/>
#end msbuild

// Writes a MSBuild line that invokes the given target on all subdirectory
// projects.
#defun msbuildall target
  #foreach dirname $[alldirs]
  <MSBuild Projects="$[osfilename ./$[subdirs $[PATH],$[dirname]]/$[dirname].proj]" Targets="$[target]"/>
  #end dirname
#end msbuildall

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

// These are the complete set of extra flags the compiler requires.
#defer cflags $[patsubst -D%,/D%,$[get_cflags] $[CFLAGS] $[CFLAGS_OPT$[OPTIMIZE]]]
#defer c++flags $[patsubst -D%,/D%,$[get_cflags] $[C++FLAGS] $[CFLAGS_OPT$[OPTIMIZE]]]

// $[complete_lpath] is rather like $[complete_ipath]: the list of
// directories (from within this tree) we should add to our -L list.
#defer complete_lpath $[libs $[RELDIR:%=%/$[ODIR]],$[actual_local_libs]] $[EXTRA_LPATH]

// $[lpath] is like $[target_ipath]: it's the list of directories we
// should add to our -L list, from the context of a particular target.
#defer lpath $[sort $[complete_lpath]] $[other_trees_lib] $[get_lpath]

// $[libs] is the set of libraries we will link with.
#defer libs $[unique $[actual_local_libs:%=%$[dllext]] $[get_libs]]

#defer get_output_lib $[get_output_file_noext].lib
#defer get_output_pdb $[get_output_file_noext].pdb

// This is the set of files we might copy into *.prebuilt, if we have
// bison and flex (or copy from *.prebuilt if we don't have them).
#define bison_prebuilt $[patsubst %.yxx,%.cxx %.h,$[yxx_st_sources]] $[patsubst %.lxx,%.cxx,$[lxx_st_sources]]

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
#output $[DIRNAME].proj
#format collapse
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. -->
<!--                              DO NOT EDIT                                       -->
<Project DefaultTargets="all" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

// Write in references to all of the other projects we depend on, so MSBuild
// can correctly determine project-level build order.
<ItemGroup>
#foreach dirname $[DEPEND_DIRS]
  <ProjectReference Include="$[osfilename $[dirnames $[RELDIR],$[dirname]]/$[dirname].proj]"/>
#end dirname
</ItemGroup>

// The 'all' rule makes all the stuff in the directory except for the
// test_bin_targets.  It doesn't do any installation, however.
#define all_targets \
    $[targetname Makefile \
      $[if $[dep_sources],$[DEPENDENCY_CACHE_FILENAME]] \
      $[sort $[lib_targets] $[bin_targets]] \
      $[deferred_objs]]

<Target Name="all" DependsOnTargets="$[msjoin $[all_targets]]"/>

// The 'test' rule makes all the test_bin_targets.
<Target Name="test" DependsOnTargets="$[jtargetname $[test_bin_targets] $[test_lib_targets]]"/>

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
  <Exec Command="rmdir /s $[osfilename $[ODIR]]"/>
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
     $[patsubst %,install-lib$[targetname %],$[active_target(interface_target python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target)]] \
     $[patsubst %,install-$[targetname %],$[active_target(bin_target sed_bin_target csharp_target)]] \
     $[targetname $[installed_files]]

#define uninstall_targets \
    $[patsubst %,uninstall-lib$[targetname %],$[active_target(interface_target python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target)]] \
    $[patsubst %,uninstall-$[targetname %],$[active_target(bin_target)]]

<Target Name="install" DependsOnTargets="$[msjoin all $[install_targets]]"/>

<Target Name="install-igate" DependsOnTargets="$[jtargetname $[sort $[installed_igate_files]]]"/>
<Target Name="uninstall" DependsOnTargets="$[msjoin $[uninstall_targets]]">
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
<Target Name="prebuild-bison" DependsOnTargets="$[jtargetname $[patsubst %,%.prebuilt,$[bison_prebuilt]]]"/>
<Target Name="clean-prebuild-bison">
#if $[bison_prebuilt]
  <Exec Command="del /f $[osfilename $[sort $[patsubst %,%.prebuilt,$[bison_prebuilt]]]]"/>
#endif
</Target>
#endif

// Now it's time to start generating the rules to make our actual
// targets.
<Target Name="igate" DependsOnTargets="$[jtargetname $[get_igatedb(python_module_target lib_target ss_lib_target)]]"/>

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
  #define depend_targets $[sources]
  #if $[not $[BUILD_COMPONENTS]]
    // Also link in all of the component files directly into the metalib.
    #define sources $[sources] \
      $[components $[patsubst %,$[RELDIR]/$[%_obj],$[compile_sources]],$[active_component_libs]]
    // Don't depend on these sources, MSBuild Targets cannot depend on Targets
    // from another project.
  #endif

  #define target $[ODIR]/$[get_output_file]

  #define extra \
    $[if $[not $[lib_is_static]], $[ODIR]/$[get_output_lib]] \
    $[if $[has_pdb], $[ODIR]/$[get_output_pdb]]

<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[jtargetname $[depend_targets]]"
        Inputs="$[msjoin $[osfilename $[sources] $[DLLBASEADDRFILENAME:%=$[dtool_ver_dir_cyg]/%]]]"
        Outputs="$[msjoin $[osfilename $[target] $[extra]]]">
  #define sources $[osfilename $[sources]]
  #if $[filter %.cxx %.cpp %.yxx %.lxx,$[get_sources]]
  <Exec Command='$[link_lib_c++]'/>
  #else
  <Exec Command='$[link_lib_c]'/>
  #endif
</Target>

// Additional dependency rules for the implicit files that get built
// along with a .dll.
#if $[not $[lib_is_static]]
<Target Name="$[targetname $[ODIR]/$[get_output_lib]]"
        DependsOnTargets="$[targetname $[ODIR]/$[get_output_file]]"/>
#endif
#if $[has_pdb]
<Target Name="$[targetname $[ODIR]/$[get_output_pdb]]"
        DependsOnTargets="$[targetname $[ODIR]/$[get_output_file]]"/>
#endif

#endif

// Here are the rules to install and uninstall the library and
// everything that goes along with it.
#define installed_files \
    $[if $[build_lib], \
      $[install_lib_dir]/$[get_output_file] \
      $[if $[not $[lib_is_static]],$[install_lib_dir]/$[get_output_lib]] \
      $[if $[has_pdb],$[install_lib_dir]/$[get_output_pdb]] \
    ] \
    $[INSTALL_SCRIPTS:%=$[install_bin_dir]/%] \
    $[INSTALL_MODULES:%=$[install_lib_dir]/%] \
    $[INSTALL_HEADERS:%=$[install_headers_dir]/%] \
    $[INSTALL_DATA:%=$[install_data_dir]/%] \
    $[INSTALL_CONFIG:%=$[install_config_dir]/%] \
    $[igatedb:$[ODIR]/%=$[install_igatedb_dir]/%]

<Target Name="install-lib$[targetname $[TARGET]]"
        DependsOnTargets="$[jtargetname $[installed_files]]"/>

<Target Name="uninstall-lib$[targetname $[TARGET]]">
#if $[installed_files]
  <Exec Command="del /f $[osfilename $[sort $[installed_files]]]"/>
#endif
</Target>

#define local $[get_output_file]
#define dest $[install_lib_dir]
#define inputs \
  $[osfilename $[ODIR]/$[get_output_file]]
#define outputs \
  $[osfilename $[dest]/$[get_output_file]]
<Target Name="$[targetname $[install_lib_dir]/$[get_output_file]]"
        DependsOnTargets="$[targetname $[ODIR]/$[get_output_file]]"
        Inputs="$[msjoin $[inputs]]"
        Outputs="$[msjoin $[outputs]]">
  <Exec Command="xcopy /I/Y $[osfilename $[ODIR]/$[local] $[dest]/]"/>
</Target>

// Install the .lib associated with a .dll.
#if $[not $[lib_is_static]]
<Target Name="$[targetname $[install_lib_dir]/$[get_output_lib]]"
        Inputs="$[osfilename $[ODIR]/$[get_output_lib]]"
        Outputs="$[osfilename $[install_lib_dir]/$[get_output_lib]]"
        DependsOnTargets="$[targetname $[ODIR]/$[get_output_lib]]">
#define local $[get_output_lib]
#define dest $[install_lib_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[ODIR]/$[local] $[dest]/]"/>
</Target>
#endif

#if $[has_pdb]
<Target Name="$[targetname $[install_lib_dir]/$[get_output_pdb]]"
        DependsOnTargets="$[targetname $[ODIR]/$[get_output_pdb]]"
        Inputs="$[osfilename $[ODIR]/$[get_output_pdb]]"
        Outputs="$[osfilename $[install_lib_dir]/$[get_output_pdb]]">
#define local $[get_output_pdb]
#define dest $[install_lib_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[ODIR]/$[local] $[dest]/]"/>
</Target>
#endif

#if $[igatescan]
// Now, some additional rules to generate and compile the interrogate
// data, if needed.

// The library name is based on this library.
#define igatelib $[get_output_name]
// The module name comes from the Python module that includes this library.
#define igatemod $[python_module $[TARGET],$[TARGET]]
#if $[eq $[igatemod],]
  // Unless no metalib includes this library.
  #define igatemod $[TARGET]
#endif

// Target to install the interrogate database.
#define out_igatedb $[igatedb:$[ODIR]/%=$[install_igatedb_dir]/%]
#define local $[igatedb]
#define dest $[install_igatedb_dir]
<Target Name="$[targetname $[out_igatedb]]"
        DependsOnTargets="$[jtargetname $[igatedb]]"
        Inputs="$[osfilename $[local]]"
        Outputs="$[osfilename $[dest]/$[out_igatedb]]">
  <Exec Command="xcopy /I/Y $[osfilename $[local] $[dest]/]"/>
</Target>

// We have to split this out as a separate rule to properly support
// parallel make.
<Target Name="$[targetname $[igatedb]]"
        DependsOnTargets="$[jtargetname $[igateoutput]]"/>

#define igate_inputs $[sort $[patsubst %.h,%.h,%.I,%.I,%.T,%.T,%,,$[dependencies $[igatescan]] $[igatescan:%=./%]]]
// Target to run interrogate on the library.
<Target Name="$[targetname $[igateoutput]]"
        Inputs="$[msjoin $[osfilename $[igate_inputs]]]"
        Outputs="$[osfilename $[igateoutput]]">
  <Exec Command='$[INTERROGATE] -od $[igatedb] -oc $[igateoutput] $[interrogate_options] -module "$[igatemod]" -library "$[igatelib]" $[igatescan]'/>
</Target>
#endif  // igatescan

#if $[igatemout]
// And finally, some additional rules to build the interrogate module
// file into the library, if this is a metalib that includes
// interrogated components.

#define igatelib $[get_output_name]
#define igatemod $[TARGET]

#define target $[igatemout]
#define sources $[igatemscan]

<Target Name="$[targetname $[target]]"
        Inputs="$[msjoin $[osfilename $[sources]]]"
        Outputs="$[osfilename $[target]]">
  <Exec Command='$[INTERROGATE_MODULE] -oc $[target] -module "$[igatemod]" -library "$[igatelib]" $[interrogate_module_options] $[sources]'/>
</Target>

#endif  // igatemout

#end python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target

/////////////////////////////////////////////////////////////////////
// Now, the noninstalled dynamic libraries.  These are presumably used
// only within this directory, or at the most within this tree, and
// also presumably will never include interrogate data.  That, plus
// the fact that we don't need to generate install rules, makes it a
// lot simpler.
/////////////////////////////////////////////////////////////////////

#forscopes noinst_lib_target test_lib_target

#define sources $[patsubst %,$[%_obj],$[compile_sources]]
#define inputs $[sources] $[static_lib_dependencies]
#define depend_targets $[sources]
#define target $[ODIR]/$[get_output_file]
#define outputs \
  $[target] \
  $[if $[not $[lib_is_static]], $[ODIR]/$[get_output_lib]] \
  $[if $[has_pdb], $[ODIR]/$[get_output_pdb]]
<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[jtargetname $[depend_targets]]"
        Inputs="$[msjoin $[osfilename $[inputs]]]"
        Outputs="$[msjoin $[osfilename $[outputs]]]">

#if $[filter %.cxx %.cpp %.yxx %.lxx,$[get_sources]]
  <Exec Command='$[link_lib_c++]'/>
#else
  <Exec Command='$[link_lib_c]'/>
#endif
</Target>

#end noinst_lib_target test_lib_target

/////////////////////////////////////////////////////////////////////
// For interfaces, just install the headers, but don't build any code.
/////////////////////////////////////////////////////////////////////

#forscopes interface_target
// Here are the rules to install and uninstall the library and
// everything that goes along with it.
#define installed_files \
    $[INSTALL_HEADERS:%=$[install_headers_dir]/%]

<Target Name="install-lib$[targetname $[TARGET]]"
        DependsOnTargets="$[jtargetname $[installed_files]]"/>

<Target Name="uninstall-lib$[targetname $[TARGET]]">
#if $[installed_files]
  <Exec Command="del /f $[osfilename $[sort $[installed_files]]]"/>
#endif
</Target>
#end interface_target

/////////////////////////////////////////////////////////////////////
// The sed_bin_targets are a special bunch.  These are scripts that
// are to be preprocessed with sed before being installed, for
// instance to insert a path or something in an appropriate place.
/////////////////////////////////////////////////////////////////////
#forscopes sed_bin_target
<Target Name="$[targetname $[TARGET]]"
        DependsOnTargets="$[targetname $[ODIR]/$[TARGET]]"
        Inputs="$[osfilename $[ODIR]/$[TARGET]]"
        Outputs="$[osfilename $[TARGET]]"/>

#define target $[ODIR]/$[TARGET]
#define source $[SOURCE]
#define script $[COMMAND]
<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[targetname $[source]]"
        Inputs="$[osfilename $[source]]"
        Outputs="$[osfilename $[target]]">
  <Exec Command='$[SED]'/>
</Target>

#define installed_files \
    $[install_bin_dir]/$[TARGET]
#define inputs $[patsubst %,$[osfilename %],$[installed_files]]
<Target Name="install-$[targetname $[TARGET]]"
        DependsOnTargets="$[jtargetname $[inputs]]"/>

<Target Name="uninstall-$[targetname $[TARGET]]">
#if $[installed_files]
#foreach file $[patsubst %,$[osfilename %],$[sort $[installed_files]]]
  <Exec Command='if exist $[file] del /f $[file]'/>
#end file
#endif
</Target>

#define local $[TARGET]
#define dest $[install_bin_dir]
<Target Name="$[targetname $[dest]/$[TARGET]]"
        DependsOnTargets="$[targetname $[ODIR]/$[TARGET]]"
        Inputs="$[osfilename $[ODIR]/$[TARGET]]"
        Outputs="$[osfilename $[dest]/$[TARGET]]">
  <Exec Command="xcopy /I/Y $[osfilename $[ODIR]/$[local]] $[osfilename $[dest]/]"/>
</Target>

#end sed_bin_target

/////////////////////////////////////////////////////////////////////
// And now, the bin_targets.  These are normal C++ executables.  No
// interrogate, metalibs, or any such nonsense here.
/////////////////////////////////////////////////////////////////////

#forscopes bin_target
<Target Name="$[targetname $[TARGET]]"
        DependsOnTargets="$[targetname $[ODIR]/$[TARGET].exe]"/>

#define target $[ODIR]/$[TARGET].exe
#define sources $[patsubst %,$[%_obj],$[compile_sources]]
#define ld $[get_ld]
#define outputs \
  $[target] \
  $[if $[build_pdbs],$[ODIR]/$[TARGET].pdb]

<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[jtargetname $[sources]]"
        Inputs="$[msjoin $[osfilename $[sources] $[static_lib_dependencies]]]"
        Outputs="$[msjoin $[osfilename $[outputs]]]">
#if $[ld]
  // If there's a custom linker defined for the target, we have to use it.
  <Exec Command='$[ld] -o $[target] $[sources] $[lpath:%=-L%] $[libs:%=-l%]'/>
#else
  // Otherwise, we can use the normal linker.
  #if $[filter %.cxx %.cpp %.yxx %.lxx,$[get_sources]]
  <Exec Command='$[link_bin_c++]'/>
  #else
  <Exec Command='$[link_bin_c]'/>
  #endif
#endif
</Target>

#if $[build_pdbs]
<Target Name="$[targetname $[ODIR]/$[TARGET].pdb]"
        DependsOnTargets="$[targetname $[ODIR]/$[TARGET].exe]"/>
#endif

#define installed_files \
    $[install_bin_dir]/$[TARGET].exe \
    $[if $[build_pdbs],$[install_bin_dir]/$[TARGET].pdb] \
    $[if $[or $[eq $[USE_COMPILER],MSVC8],$[eq $[USE_COMPILER],MSVC9],$[eq $[USE_COMPILER],MSVC9x64]],$[install_bin_dir]/$[TARGET].exe.manifest] \
    $[INSTALL_SCRIPTS:%=$[install_bin_dir]/%] \
    $[INSTALL_MODULES:%=$[install_lib_dir]/%] \
    $[INSTALL_HEADERS:%=$[install_headers_dir]/%] \
    $[INSTALL_DATA:%=$[install_data_dir]/%] \
    $[if $[bin_postprocess_target],$[install_bin_dir]/$[bin_postprocess_target].exe] \
    $[INSTALL_CONFIG:%=$[install_config_dir]/%]

<Target Name="install-$[targetname $[TARGET]]"
        DependsOnTargets="$[jtargetname $[installed_files]]"/>

<Target Name="uninstall-$[targetname $[TARGET]]">
#if $[installed_files]
  <Exec Command="del /f $[osfilename $[sort $[installed_files]]]"/>
#endif
</Target>

#define local $[TARGET].exe
#define dest $[install_bin_dir]
<Target Name="$[targetname $[dest]/$[local]]"
        DependsOnTargets="$[targetname $[ODIR]/$[local]]"
        Inputs="$[osfilename $[ODIR]/$[local]]"
        Outputs="$[osfilename $[dest]/$[local]]">
  <Exec Command="xcopy /I/Y $[osfilename $[ODIR]/$[local] $[dest]/]"/>
</Target>

#if $[build_pdbs]
#define local $[TARGET].pdb
#define dest $[install_bin_dir]
<Target Name="$[targetname $[dest]/$[local]]"
        DependsOnTargets="$[targetname $[ODIR]/$[local]]"
        Inputs="$[osfilename $[ODIR]/$[local]]"
        Outputs="$[osfilename $[dest]/$[local]]">
  <Exec Command="xcopy /I/Y $[osfilename $[ODIR]/$[local] $[dest]/]"/>
</Target>
#endif

#if $[bin_postprocess_target]
#define input_exe $[ODIR]/$[TARGET].exe
#define output_exe $[ODIR]/$[bin_postprocess_target].exe

<Target Name="$[targetname $[output_exe]]"
        DependsOnTargets="$[targetname $[input_exe]]"
        Inputs="$[osfilename $[input_exe]]"
        Outputs="$[osfilename $[output_exe]]">
  <Exec Command="if exist $[osfilename $[output_exe]] del /f $[osfilename $[output_exe]]"/>
  <Exec Command="$[bin_postprocess_cmd] $[bin_postprocess_arg1] $[osfilename $[input_exe]] $[bin_postprocess_arg2] $[osfilename $[output_exe]]"/>
</Target>

<Target Name="$[targetname $[install_bin_dir]/$[bin_postprocess_target].exe]"
        DependsOnTargets="$[targetname $[output_exe]]"
        Inputs="$[osfilename $[output_exe]]"
        Outputs="$[osfilename $[install_bin_dir]/$[bin_postprocess_target].exe]">
  <Exec Command="xcopy /I/Y $[osfilename $[output_exe]] $[osfilename $[install_bin_dir]/]"/>
</Target>

#endif

#end bin_target

/////////////////////////////////////////////////////////////////////
// The noinst_bin_targets and the test_bin_targets share the property
// of being built (when requested), but having no install rules.
/////////////////////////////////////////////////////////////////////

#forscopes noinst_bin_target test_bin_target test_lib_target
<Target Name="$[targetname $[TARGET]]"
        DependsOnTargets="$[targetname $[ODIR]/$[TARGET].exe]"/>

#define sources $[patsubst %,$[osfilename $[%_obj]],$[compile_sources]]
#define target $[ODIR]/$[TARGET].exe

<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[jtargetname $[sources]]"
        Inputs="$[msjoin $[osfilename $[sources] $[static_lib_dependencies]]]"
        Outputs="$[osfilename $[target]]">
#if $[filter %.cxx %.cpp %.yxx %.lxx,$[get_sources]]
  <Exec Command='$[link_bin_c++]'/>
#else
  <Exec Command='$[link_bin_c]'/>
#endif
</Target>

#end noinst_bin_target test_bin_target test_lib_target

/////////////////////////////////////////////////////////////////////
// Rules to run bison and/or flex as needed.
/////////////////////////////////////////////////////////////////////

// Rules to generate a C++ file from a Bison input file.
#foreach file $[sort $[yxx_st_sources]]
#define target $[patsubst %.yxx,%.cxx,$[file]]
#define target_header $[patsubst %.yxx,%.h,$[file]]
#define target_prebuilt $[target].prebuilt
#define target_header_prebuilt $[target_header].prebuilt
#if $[HAVE_BISON]
<Target Name="$[targetname $[target]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[msjoin $[osfilename $[target] $[target_header]]]">
  <Exec Command="$[BISON] $[YFLAGS] -y $[if $[YACC_PREFIX],-d --name-prefix=$[YACC_PREFIX]] $[osfilename $[file]]"/>
  <Exec Command="move /y y.tab.c $[osfilename $[target]]"/>
  <Exec Command="move /y y.tab.h $[osfilename $[target_header]]"/>
</Target>

<Target Name="$[targetname $[target_header]]"
        DependsOnTargets="$[targetname $[target]]"/>

<Target Name="$[targetname $[target_prebuilt]]"
        DependsOnTargets="$[targetname $[target]]"
        Inputs="$[osfilename $[target]]"
        Outputs="$[osfilename $[target_prebuilt]]">
  <Exec Command="copy /y $[osfilename $[target]] $[osfilename $[target_prebuilt]]"/>
</Target>

<Target Name="$[targetname $[target_header_prebuilt]]"
        DependsOnTargets="$[targetname $[target_header]]"
        Inputs="$[osfilename $[target_header]]"
        Outputs="$[osfilename $[target_header_prebuilt]]">
  <Exec Command="copy /y $[osfilename $[target_header]] $[osfilename $[target_header_prebuilt]]"/>
</Target>

#else // HAVE_BISON

<Target Name="$[targetname $[target]]"
        Inputs="$[osfilename $[target_prebuilt]]"
        Outputs="$[osfilename $[target]]">
  <Exec Command="copy /Y $[osfilename $[target_prebuilt]] $[osfilename $[target]]"/>
</Target>

<Target Name="$[targetname $[target_header]]"
        Inputs="$[osfilename $[target_header_prebuilt]]"
        Outputs="$[osfilename $[target_header]]">
  <Exec Command="copy /Y $[osfilename $[target_header_prebuilt]] $[osfilename $[target_header]]"/>
</Target>

#endif // HAVE_BISON

#end file

// Rules to generate a C++ file from a Flex input file.
#foreach file $[sort $[lxx_st_sources]]
#define target $[patsubst %.lxx,%.cxx,$[file]]
#define target_prebuilt $[target].prebuilt
#if $[HAVE_BISON]

#define source $[file]
<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[targetname $[file]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[osfilename $[target]]">
  <Exec Command="$[FLEX] $[FLEXFLAGS] $[if $[YACC_PREFIX],-P$[YACC_PREFIX]] -olex.yy.c $[osfilename $[file]]"/>
#define source lex.yy.c
#define script /#include <unistd.h>/d
  <Exec Command="$[SED]"/>
  <Exec Command="if exist lex.yy.c del lex.yy.c"/>
</Target>

<Target Name="$[targetname $[target_prebuilt]]"
        DependsOnTargets="$[targetname $[target]]"
        Inputs="$[osfilename $[target]]"
        Outputs="$[osfilename $[target_prebuilt]]>
  <Exec Command="copy /Y $[osfilename $[target]] $[osfilename $[target_prebuilt]]"/>
</Target>

#else // HAVE_BISON

<Target Name="$[targetname $[target]]"
        Inputs="$[osfilename $[target_prebuilt]]"
        Outputs="$[osfilename $[target]]">
  <Exec Command="copy /Y $[osfilename $[target_prebuilt]] $[osfilename $[target]]"/>
</Target>

#endif // HAVE_BISON

#end file

/////////////////////////////////////////////////////////////////////
// Finally, we put in the rules to compile each source file into a .obj
// file.
/////////////////////////////////////////////////////////////////////

#forscopes python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target

// Rules to compile ordinary C files.
#foreach file $[sort $[c_sources]]
#define target $[$[file]_obj]
#define source $[file]
#define ipath $[target_ipath]
#define flags $[cflags] $[building_var:%=/D%]
#if $[ne $[file], $[notdir $file]]
  // If the source file is not in the current directory, tack on "."
  // to front of the ipath.
  #set ipath . $[ipath]
#endif

#if $[not $[direct_tau]]

<Target Name="$[targetname $[target]]"
        Inputs="$[msjoin $[osfilename $[source] $[get_depends $[source]]]]"
        Outputs="$[osfilename $[target]]">
  <Exec Command='$[compile_c]'/>
</Target>

#else // direct_tau
// This version is used to invoke the tau compiler directly.
#define il_source $[target].il
#define pdb_source $[target].pdb  // Not to be confused with windows .pdb debugger info files.
#define inst_source $[notdir $[target:%.obj=%.inst.c]]

<Target Name="$[targetname $[il_source]]"
        Inputs="$[osfilename $[source]]"
        Outputs="$[osfilename $[il_source]]">
  <Exec Command="$[TAU_MAKE_IL]"/>
</Target>

<Target Name="$[targetname $[pdb_source]]"
        Inputs="$[osfilename $[il_source]]"
        DependsOnTargets="$[targetname $[il_source]]"
        Outputs="$[osfilename $[pdb_source]]">
  <Exec Command="$[TAU_MAKE_PDB]"/>
</Target>

<Target Name="$[targetname $[inst_source]]"
        DependsOnTargets="$[targetname $[pdb_source]]]"
        Inputs="$[osfilename $[pdb_source]]"
        Outputs="$[osfilename $[inst_source]]">
  <Exec Command="$[TAU_MAKE_INST] -c"/>
</Target>

<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[targetname $[inst_source]]"
        Inputs="$[msjoin $[osfilename $[inst_source] $[get_depends $[source]]]]"
        Outputs="$[osfilename $[target]]">
#define source $[inst_source]
  <Exec Command='$[COMPILE_C]'/>
</Target>

#endif // direct_tau

#end file

// Rules to compile C++ files.

#foreach file $[sort $[cxx_sources]]
#define target $[$[file]_obj]
#define source $[file]
#define ipath $[target_ipath]
#define flags $[c++flags] $[building_var:%=/D%]
#if $[ne $[file], $[notdir $file]]
  // If the source file is not in the current directory, tack on "."
  // to front of the ipath.
  #set ipath . $[ipath]
#endif

#if $[not $[direct_tau]]
// Yacc must run before some files can be compiled, so all files
// depend on yacc having run.
<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[jtargetname $[generated_sources]]"
        Inputs="$[msjoin $[osfilename $[source] $[get_depends $[source]]]]"
        Outputs="$[osfilename $[target]]">
  <Exec Command='$[compile_c++]'/>
</Target>

#else  // direct_tau
// This version is used to invoke the tau compiler directly.
#define il_source $[target].il
#define pdb_source $[target].pdb  // Not to be confused with windows .pdb debugger info files.
#define inst_source $[notdir $[target:%.obj=%.inst.cxx]]

<Target Name="$[targetname $[il_source]]"
        DependsOnTargets="$[jtargetname $[generated_sources]]"
        Inputs="$[msjoin $[osfilename $[source]]]"
        Outputs="$[osfilename $[il_source]]">
  <Exec Command="$[TAU_MAKE_IL]"/>
</Target>

<Target Name="$[targetname $[pdb_source]]"
        DependsOnTargets="$[targetname $[il_source]]"
        Inputs="$[osfilename $[il_source]]"
        Outputs="$[osfilename $[pdb_source]]">
  <Exec Command="$[TAU_MAKE_PDB]"/>
</Target>

<Target Name="$[targetname $[inst_source]]"
        DependsOnTargets="$[targetname $[pdb_source]]"
        Inputs="$[osfilename $[pdb_source]]"
        Outputs="$[osfilename $[inst_source]]">
  <Exec Command="$[TAU_MAKE_INST]"/>
</Target>

<Target Name="$[targetname $[target]]"
        DependsOnTargets="$[targetname $[inst_source]]"
        Inputs="$[msjoin $[osfilename $[inst_source] $[get_depends $[source]]]]"
        Outputs="$[osfilename $[target]]">
#define source $[inst_source]
  <Exec Command='$[COMPILE_C++]'/>
#endif // direct_tau

#end file // file

#end python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target

// And now the rules to install the auxiliary files, like headers and
// data files.

#foreach file $[install_scripts]
<Target Name="$[targetname $[install_bin_dir]/$[file]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[osfilename $[install_bin_dir]/$[file]]">
#define local $[file]
#define dest $[install_bin_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#end file

#foreach file $[install_modules]
<Target Name="$[targetname $[install_lib_dir]/$[file]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[osfilename $[install_lib_dir]/$[file]]">
#define local $[file]
#define dest $[install_lib_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#end file

#foreach file $[install_headers]
<Target Name="$[targetname $[install_headers_dir]/$[file]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[osfilename $[install_headers_dir]/$[file]]">
#define local $[file]
#define dest $[install_headers_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#end file

#foreach file $[install_parser_inc]
#if $[ne $[dir $[file]], ./]
<Target Name="$[targetname $[install_parser_inc_dir]/$[file]]"
        Inputs="$[osfilename $[notdir $[file]]]"
        Outputs="$[osfilename $[install_parser_inc_dir]/$[dir $[file]]]">
  #define local $[file]
  #define dest $[osfilename $[install_parser_inc_dir]/$[dir $[file]]]
  <Exec Command="if not exist $[dest] mkdir $[dest] || echo"/>
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#else
<Target Name="$[targetname $[install_parser_inc_dir]/$[file]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[osfilename $[install_parser_inc_dir]/$[file]]">
  #define local $[file]
  #define dest $[install_parser_inc_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#endif
#end file

#foreach file $[install_data]
<Target Name="$[targetname $[install_data_dir]/$[file]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[osfilename $[install_data_dir]/$[file]]">
#define local $[file]
#define dest $[install_data_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#end file

#foreach file $[install_config]
<Target Name="$[targetname $[install_config_dir]/$[file]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[osfilename $[install_config_dir]/$[file]]">
#define local $[file]
#define dest $[install_config_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#end file

#foreach file $[install_py]
<Target Name="$[targetname $[install_py_dir]/$[file]]"
        Inputs="$[osfilename $[file]]"
        Outputs="$[osfilename $[install_py_dir]/$[file]]">
#define local $[file]
#define dest $[install_py_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#end file

#if $[install_py]
#define output $[install_py_package_dir]/__init__.py
<Target Name="$[targetname $[output]]"
        Outputs="$[osfilename $[output]]">
  <Exec Command="echo. > $[osfilename $[output]]"/>
</Target>
#endif

// Finally, all the special targets.  These are commands that just need
// to be invoked; we don't pretend to know what they are.
#forscopes special_target
<Target Name="$[targetname $[TARGET]]">
  <Exec Command='$[COMMAND]'/>
</Target>

#end special_target

// Finally, the rules to freshen the Makefile itself.
<Target Name="Makefile"
        Inputs="$[msjoin $[osfilename $[SOURCE_FILENAME] $[EXTRA_PPREMAKE_SOURCE]]]"
        Outputs="$[osfilename $[DIRNAME].proj]">
  <Exec Command="ppremake"/>
</Target>

#if $[USE_TAU]
#foreach composite_file $[composite_list]
#define composite_file_sources $[$[composite_file]_sources]
<Target Name="$[targetname $[composite_file]]"
        Inputs="$[osfilename $[composite_file_sources]]"
        Outputs="$[osfilename $[composite_file]]">
  <Exec Command="ppremake"/>
</Target>
#end composite_file
#endif   // USE_TAU

#if $[and $[DEPENDENCY_CACHE_FILENAME],$[dep_sources]]
<Target Name="$[targetname $[DEPENDENCY_CACHE_FILENAME]]"
        Inputs="$[msjoin $[osfilename $[dep_sources]]]"
        Outputs="$[osfilename $[DEPENDENCY_CACHE_FILENAME]]">
  <Exec Command="@ppremake -D $[DEPENDENCY_CACHE_FILENAME]"/>
</Target>
#endif

</Project>

#end $[DIRNAME].proj

//////////////////////////////////////////////////////////////////////
#elif $[eq $[DIR_TYPE], group]
//////////////////////////////////////////////////////////////////////

// This is a group directory: a directory above a collection of source
// directories, e.g. $DTOOL/src.  We don't need to output anything in
// this directory.


//////////////////////////////////////////////////////////////////////
#elif $[eq $[DIR_TYPE], toplevel]
//////////////////////////////////////////////////////////////////////

// This is the toplevel directory, e.g. $DTOOL.  Here we build the
// root makefile and also synthesize the dtool_config.h (or whichever
// file) we need.

#map subdirs
// Iterate through all of our known source files.  Each src and
// metalib type file gets its corresponding Makefile listed
// here.  However, we test for $[DIR_TYPE] of toplevel, because the
// source directories typically don't define their own DIR_TYPE
// variable, and they end up inheriting this one dynamically.
#forscopes */
#if $[or $[eq $[DIR_TYPE], src],$[eq $[DIR_TYPE], metalib],$[eq $[DIR_TYPE], module],$[and $[eq $[DIR_TYPE], toplevel],$[ne $[DIRNAME],top]]]
#if $[build_directory]
  #addmap subdirs $[DIRNAME]
#endif
#endif
#end */

#define alldirs $[subdirs]

#if $[PYTHON_PACKAGE]
#include $[THISDIRPREFIX]PythonPackageInit.pp
#endif

#output $[PACKAGE].proj
#format collapse
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. -->
<!--                              DO NOT EDIT                                       -->
<Project DefaultTargets="all" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

<Target Name="all"
        DependsOnTargets="$[msjoin $[subdirs]]"/>
<Target Name="test"
        DependsOnTargets="$[msjoin $[subdirs:%=test-%]]"/>
<Target Name="igate"
        DependsOnTargets="$[msjoin $[subdirs:%=igate-%]]"/>
<Target Name="clean"
        DependsOnTargets="$[msjoin $[subdirs:%=clean-%]]"/>
<Target Name="clean-igate"
        DependsOnTargets="$[msjoin $[subdirs:%=clean-igate-%]]"/>
<Target Name="cleanall"
        DependsOnTargets="$[msjoin $[subdirs:%=cleanall-%]]"/>

<Target Name="install"
        DependsOnTargets="$[msjoin $[if $[CONFIG_HEADER],$[targetname $[install_headers_dir] $[install_headers_dir]/$[CONFIG_HEADER]]] $[subdirs:%=install-%]]"/>
<Target Name="install-igate"
        DependsOnTargets="$[msjoin $[subdirs:%=install-igate-%]]"/>
<Target Name="uninstall"
        DependsOnTargets="$[msjoin $[subdirs:%=uninstall-%]]">
#if $[CONFIG_HEADER]
  <Exec Command="if exist $[osfilename $[install_headers_dir]/$[CONFIG_HEADER]] del /f $[osfilename $[install_headers_dir]/$[CONFIG_HEADER]]"/>
#endif
</Target>
<Target Name="uninstall-igate"
        DependsOnTargets="$[msjoin $[subdirs:%=uninstall-igate-%]]"/>

#if $[HAVE_BISON]
<Target Name="prebuild-bison"
        DependsOnTargets="$[msjoin $[subdirs:%=prebuild-bison-%]]"/>
<Target Name="clean-prebuild-bison"
        DependsOnTargets="$[msjoin $[subdirs:%=clean-prebuild-bison-%]]"/>
#endif

#formap dirname subdirs
#define depends
<Target Name="$[dirname]"
        DependsOnTargets="$[msjoin $[dirnames $[if $[build_directory],$[DIRNAME]],$[DEPEND_DIRS]]]">
  $[msbuild all]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="test-$[dirname]">
  $[msbuild test]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="igate-$[dirname]">
  $[msbuild igate]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="clean-$[dirname]">
  $[msbuild clean]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="clean-igate-$[dirname]">
  $[msbuild clean-igate]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="cleanall-$[dirname]"
        DependsOnTargets="$[msjoin $[patsubst %,cleanall-%,$[dirnames $[if $[build_directory],$[DIRNAME]],$[DEPEND_DIRS]]]]">
  $[msbuild cleanall]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="install-$[dirname]"
        DependsOnTargets="$[msjoin $[patsubst %,install-%,$[dirnames $[if $[build_directory],$[DIRNAME]],$[DEPEND_DIRS]]]]">
  $[msbuild install]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="install-igate-$[dirname]">
  $[msbuild install-igate]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="uninstall-$[dirname]">
  $[msbuild uninstall]
</Target>
#end dirname

#formap dirname subdirs
<Target Name="uninstall-igate-$[dirname]">
  $[msbuild uninstall-igate]
</Target>
#end dirname

#if $[HAVE_BISON]
#formap dirname subdirs
<Target Name="prebuild-bison-$[dirname]">
  $[msbuild prebuild-bison]
</Target>
<Target Name="clean-prebuild-bison-$[dirname]">
  $[msbuild clean-prebuild-bison]
</Target>
#end dirname
#endif

#if $[ne $[CONFIG_HEADER],]
<Target Name="$[targetname $[install_headers_dir]]">
  <Exec Command="if not exist $[osfilename $[install_headers_dir]] echo mkdir $[osfilename $[install_headers_dir]]"/>
  <Exec Command="if not exist $[osfilename $[install_headers_dir]] mkdir $[osfilename $[install_headers_dir]]"/>
</Target>

<Target Name="$[targetname $[install_headers_dir]/$[CONFIG_HEADER]]">
#define local $[CONFIG_HEADER]
#define dest $[install_headers_dir]
  <Exec Command="xcopy /I/Y $[osfilename $[local]] $[osfilename $[dest]/]"/>
</Target>
#endif

// Finally, the rules to freshen the Makefile itself.
<Target Name="Makefile"
        Inputs="$[osfilename $[SOURCE_FILENAME] $[EXTRA_PPREMAKE_SOURCE]]"
        Outputs="$[osfilename $[PACKAGE].proj]">
  <Exec Command="ppremake"/>
</Target>

</Project>

#end $[PACKAGE].proj

// If there is a file called LocalSetup.pp in the package's top
// directory, then invoke that.  It might contain some further setup
// instructions.
#sinclude $[TOPDIRPREFIX]LocalSetup.nmake.pp
#sinclude $[TOPDIRPREFIX]LocalSetup.pp


//////////////////////////////////////////////////////////////////////
#elif $[or $[eq $[DIR_TYPE], models],$[eq $[DIR_TYPE], models_toplevel],$[eq $[DIR_TYPE], models_group]]
//////////////////////////////////////////////////////////////////////

#include $[THISDIRPREFIX]Template.models.pp

//////////////////////////////////////////////////////////////////////

#endif // DIR_TYPE
