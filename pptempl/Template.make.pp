//
//
// Template.make.pp
//
// This file defines the set of output files that will be generated to
// support a generic Makefile build system.  Supports Windows and Unix
// platforms.
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
// $DTOOL/pptempl/Global.make.pp
// $DTOOL/pptempl/Depends.pp, once for each Sources.pp file
// Template.make.pp (this file), once for each Sources.pp file

#if $[< $[PPREMAKE_VERSION],1.25]
  #error You need at least ppremake version 1.25 to generate Makefiles.
#endif

// Include portable aliases for OS-specific console commands.
#include $[THISDIRPREFIX]SystemCommands.pp

#if $[ne $[DTOOL],]
#define dtool_ver_dir_cyg $[DTOOL]/src/dtoolbase
#define dtool_ver_dir $[osfilename $[dtool_ver_dir_cyg]]
#endif

//////////////////////////////////////////////////////////////////////
#if $[or $[eq $[DIR_TYPE], src],$[eq $[DIR_TYPE], metalib],$[eq $[DIR_TYPE], module]]
//////////////////////////////////////////////////////////////////////
// For a source directory, build a single Makefile with rules to build
// each target.

#if $[build_directory]
  // This is the real set of lib_targets we'll be building.  On Windows,
  // we don't build the shared libraries which are included on metalibs.

  // This is the set lib_target scopes that will actually result in a shared library.
  // This is any lib_target that is not included in a metalib, or all of them
  // if we're building components.
  #define real_lib_targets
  #define real_lib_target_libs

  // If we're not building components and any lib_target is included on a
  // metalib, their object files will be added to this list.
  #define deferred_objs

  #forscopes lib_target
    #if $[build_target]
      #if $[or $[BUILD_COMPONENTS],$[eq $[module $[TARGET],$[TARGET]],]]
        // This library is not on a metalib or we're building components, so we
        // can build it.
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
  #define bundle_targets $[active_target_bundleext(metalib_target):%=$[ODIR]/%]

  #define bin_targets $[active_target(bin_target noinst_bin_target sed_bin_target):%=$[ODIR]/%$[prog_ext]]
  #define test_bin_targets $[active_target(test_bin_target):%=$[ODIR]/%]

  // And these variables will define the various things we need to
  // install.
  #define install_lib $[active_target(metalib_target lib_target ss_lib_target static_lib_target)] $[real_lib_targets]
  #define install_bin $[active_target(bin_target)]
  #define install_scripts $[sort $[INSTALL_SCRIPTS(metalib_target lib_target ss_lib_target static_lib_target bin_target)] $[INSTALL_SCRIPTS]]
  #define install_headers $[sort $[INSTALL_HEADERS(interface_target metalib_target lib_target ss_lib_target static_lib_target bin_target)] $[INSTALL_HEADERS]]
  #define install_parser_inc $[sort $[INSTALL_PARSER_INC]]
  #define install_data $[sort $[INSTALL_DATA(metalib_target lib_target ss_lib_target static_lib_target dynamic_lib_target bin_target)] $[INSTALL_DATA]]
  #define install_config $[sort $[INSTALL_CONFIG(metalib_target lib_target ss_lib_target static_lib_target dynamic_lib_target bin_target)] $[INSTALL_CONFIG]]
  #define install_igatedb $[sort $[get_igatedb(metalib_target lib_target ss_lib_target)]]

  // These are the various sources collected from all targets within the
  // directory.
  #define st_sources $[sort $[compile_sources(python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target)]]
  #define yxx_st_sources $[sort $[yxx_sources(metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target)]]
  #define lxx_st_sources $[sort $[lxx_sources(metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target)]]
  #define dep_sources_1 $[sort $[get_sources(interface_target python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target)]]

  // These are the source files that our dependency cache file will
  // depend on.  If it's an empty list, we won't bother writing rules to
  // freshen the cache file.
  #define dep_sources $[sort $[filter %.c %.cxx %.mm %.yxx %.lxx %.h %.hpp %.I %.T,$[dep_sources_1]]]

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
#if $[WINDOWS_PLATFORM]
#defer cflags $[patsubst -D%,/D%,$[get_cflags] $[CFLAGS] $[CFLAGS_OPT$[OPTIMIZE]]]
#defer c++flags $[patsubst -D%,/D%,$[get_cflags] $[C++FLAGS] $[CFLAGS_OPT$[OPTIMIZE]]]
#defer lflags $[patsubst -D%,/D%,$[get_lflags] $[LFLAGS] $[LFLAGS_OPT$[OPTIMIZE]]]
#else
#defer cflags $[get_cflags] $[CFLAGS] $[CFLAGS_OPT$[OPTIMIZE]]
#defer c++flags $[get_cflags] $[C++FLAGS] $[CFLAGS_OPT$[OPTIMIZE]]
#defer lflags $[get_lflags] $[LFLAGS] $[LFLAGS_OPT$[OPTIMIZE]]
#endif

// $[complete_lpath] is rather like $[complete_ipath]: the list of
// directories (from within this tree) we should add to our -L list.
#defer complete_lpath $[libs $[RELDIR:%=%/$[ODIR]],$[actual_local_libs]] $[EXTRA_LPATH]

// $[lpath] is like $[target_ipath]: it's the list of directories we
// should add to our -L list, from the context of a particular target.
#defer lpath $[sort $[complete_lpath]] $[other_trees_lib] $[install_lib_dir] $[get_lpath]

// $[libs] is the set of libraries we will link with.
#defer libs $[unique $[actual_local_libs:%=%$[dllext]] $[get_libs]]

// And $[frameworks] is the set of OSX-style frameworks we will link with.
#defer frameworks $[unique $[get_frameworks]]
#defer bin_frameworks $[unique $[get_frameworks] $[all_libs $[get_frameworks],$[complete_local_libs]]]
//#defer bin_frameworks $[unique $[get_frameworks]]

// This is the set of files we might copy into *.prebuilt, if we have
// bison and flex (or copy from *.prebuilt if we don't have them).
#define bison_prebuilt $[patsubst %.yxx,%.cxx %.h,$[yxx_st_sources]] $[patsubst %.lxx,%.cxx,$[lxx_st_sources]]

// Rather than making a rule to generate each install directory later,
// we create the directories now.  This reduces problems from
// multiprocess builds.
#mkdir $[sort \
    $[if $[install_lib],$[install_lib_dir]] \
    $[if $[install_bin],$[install_bin_dir]] \
    $[if $[install_scripts],$[install_scripts_dir]] \
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
#output Makefile
#format makefile
#### Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE].
################################# DO NOT EDIT ###########################

#if $[and $[USE_TAU],$[TAU_MAKEFILE]]
include $[TAU_MAKEFILE]
#endif

// If we are using GNU make, this will automatically enable the
// multiprocessor build mode according to the value in
// NUMBER_OF_PROCESSORS, which should be set by NT.  Maybe this isn't
// a good idea to do all the time, but you can always disable it by
// explicitly unsetting NUMBER_OF_PROCESSORS, or by setting it to 1.
//#if $[NUMBER_OF_PROCESSORS]
//MAKEFLAGS := -j$[NUMBER_OF_PROCESSORS]
//#endif

// The 'all' rule makes all the stuff in the directory except for the
// test_bin_targets.  It doesn't do any installation, however.
#define all_targets \
    Makefile \
    $[if $[dep_sources],$[DEPENDENCY_CACHE_FILENAME]] \
    $[sort $[lib_targets] $[bundle_targets] $[bin_targets]] \
    $[deferred_objs]
all : $[all_targets]

// The 'test' rule makes all the test_bin_targets.
test : $[test_bin_targets]

clean : clean-igate
#forscopes python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target
#if $[compile_sources]
#foreach file $[compile_sources]
$[TAB] $[DEL_CMD $[patsubst %,$[%_obj],$[file]]]
#end file
#endif
#end python_target python_module_target metalib_target lib_target noinst_lib_target static_lib_target dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target test_lib_target
// Clean up any object files generated by metalib components.
#if $[deferred_objs]
#foreach file $[deferred_objs]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif
#if $[lib_targets] $[bundle_targets] $[bin_targets] $[test_bin_targets]
#foreach file $[lib_targets] $[bundle_targets] $[bin_targets] $[test_bin_targets]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif
#if $[yxx_st_sources] $[lxx_st_sources]
#foreach file $[yxx_st_sources]
$[TAB] $[DEL_CMD $[patsubst %.yxx,%.cxx %.h,$[file]]]
#end file
#foreach file $[lxx_st_sources]
$[TAB] $[DEL_CMD $[patsubst %.lxx,%.cxx,$[file]]]
#end file
#endif
#if $[py_sources]
$[TAB] $[DEL_CMD *.pyc *.pyo] // Also scrub out old generated Python code.
#endif
#if $[USE_TAU]
$[TAB] $[DEL_CMD *.pdb *.inst.* *.il]  // scrub out tau-generated files.
#endif

// 'cleanall' is intended to undo all the effects of running ppremake
// and building.  It removes everything except the Makefile.
cleanall : clean
#if $[st_sources]
$[TAB] $[DEL_DIR_CMD $[ODIR]]
#endif
#if $[ne $[DEPENDENCY_CACHE_FILENAME],]
$[TAB] $[DEL_CMD $[DEPENDENCY_CACHE_FILENAME]]
#endif
#if $[composite_list]
#foreach file $[composite_list]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif

clean-igate :
#forscopes python_module_target lib_target ss_lib_target dynamic_lib_target
  #define igatedb $[get_igatedb]
  #define igateoutput $[get_igateoutput]
  #define igatemscan $[get_igatemscan]
  #define igatemout $[get_igatemout]
  #if $[igatedb]
$[TAB] $[DEL_CMD $[igatedb]]
  #endif
  #if $[igateoutput]
$[TAB] $[DEL_CMD $[igateoutput] $[$[igateoutput]_obj]]
  #endif
  #if $[igatemout]
$[TAB] $[DEL_CMD $[igatemout] $[$[igatemout]_obj]]
  #endif
#end python_module_target lib_target ss_lib_target dynamic_lib_target

// Now, 'install' and 'uninstall'.  These simply copy files into the
// install directory (or remove them).  The 'install' rule also makes
// the directories if necessary.
#define installed_files \
     $[INSTALL_SCRIPTS:%=$[install_scripts_dir]/%] \
     $[INSTALL_HEADERS:%=$[install_headers_dir]/%] \
     $[INSTALL_PARSER_INC:%=$[install_parser_inc_dir]/%] \
     $[INSTALL_DATA:%=$[install_data_dir]/%] \
     $[INSTALL_CONFIG:%=$[install_config_dir]/%] \
     $[if $[install_py],$[install_py:%=$[install_py_dir]/%] $[install_py_package_dir]/__init__.py]

#define installed_igate_files \
     $[get_igatedb(python_module_target lib_target ss_lib_target):$[ODIR]/%=$[install_igatedb_dir]/%]

#define install_targets \
     $[active_target(interface_target python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target):%=install-lib%] \
     $[active_target(bin_target sed_bin_target):%=install-%] \
     $[osgeneric $[installed_files]]

install : all $[install_targets]

install-igate : $[osgeneric $[sort $[installed_igate_files]]]

uninstall : $[active_target(interface_target python_target python_module_target metalib_target lib_target static_lib_target dynamic_lib_target ss_lib_target):%=uninstall-lib%] $[active_target(bin_target):%=uninstall-%]
#if $[installed_files]
#foreach file $[sort $[installed_files]]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif

uninstall-igate :
#if $[installed_igate_files]
#foreach file $[sort $[installed_igate_files]]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif

#if $[HAVE_BISON]
prebuild-bison : $[patsubst %,%.prebuilt,$[bison_prebuilt]]
clean-prebuild-bison :
#if $[bison_prebuilt]
$[TAB] $[DEL_CMD $[sort $[patsubst %,%.prebuilt,$[bison_prebuilt]]]]
#endif
#endif

// Now it's time to start generating the rules to make our actual
// targets.

igate : $[get_igatedb(python_module_target lib_target ss_lib_target)]


/////////////////////////////////////////////////////////////////////
// First, the normally installed dynamic and static libraries.
/////////////////////////////////////////////////////////////////////

#forscopes python_target python_module_target metalib_target lib_target ss_lib_target static_lib_target dynamic_lib_target

// We might need to define a BUILDING_ symbol for win32.  We use the
// BUILDING_DLL variable name, defined typically in the metalib, for
// this; but in some cases, where the library isn't part of a metalib,
// we define BUILDING_DLL directly for the target.

#define building_var
#if $[or $[BUILD_COMPONENTS], $[eq $[module $[TARGET],$[TARGET]],]]
  // If we're not on a metalib or building components, use the BUILDING_DLL
  // directly from the target.
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

  #define cc_ld $[or $[get_ld],$[CC]]
  #define cxx_ld $[or $[get_ld],$[CXX]]
  #define flags $[lflags]

  // Link up the non-interrogate .obj files.
#if $[not $[WINDOWS_PLATFORM]]
  #define varname $[subst -,_,.,_,$[get_output_file]]
$[varname] = $[osgeneric $[sources]]
  #define sources $($[varname])
#endif // not WINDOWS_PLATFORM
  #define target $[osgeneric $[ODIR]/$[get_output_file]]

$[target] : $[if $[WINDOWS_PLATFORM], $[osgeneric $[sources]], $[sources]] $[static_lib_dependencies]
#if $[WINDOWS_PLATFORM]
  // Work around the stupid character limit on Windows by outputting the set
  // of .obj files to a separate file and passing in the file to the linker.
  #define tmpfile $[osfilename $[ODIR]/link_$[osfilename $[basename $[notdir $[target]]]]]
$[TAB] $[DEL_CMD $[tmpfile]]
  #foreach src $[sources]
$[TAB] $[ECHO_TO_FILE $[osfilename $[src]],$[tmpfile],]
  #end src
  #define sources @$[tmpfile]
#endif // WINDOWS_PLATFORM
  #if $[filter %.mm %.cxx %.cpp %.yxx %.lxx,$[get_sources]]
$[TAB] $[link_lib_c++]
  #else
$[TAB] $[link_lib_c]
  #endif
#if $[WINDOWS_PLATFORM]
$[TAB] $[DEL_CMD $[tmpfile]]
#endif

// Additional dependency rules for the implicit files that get built
// along with a .dll.
#if $[WINDOWS_PLATFORM]
#if $[not $[lib_is_static]]
$[osgeneric $[ODIR]/$[get_output_file_noext].lib] : $[osgeneric $[ODIR]/$[get_output_file]]
#endif
#if $[lib_has_pdb]
$[osgeneric $[ODIR]/$[get_output_file_noext].pdb] : $[osgeneric $[ODIR]/$[get_output_file]]
#endif
#endif // WINDOWS_PLATFORM

#endif

// Here are the rules to install and uninstall the library and
// everything that goes along with it.
#define installed_files \
    $[if $[build_lib], \
      $[install_lib_dir]/$[get_output_file] \
      $[if $[link_extra_bundle],$[install_lib_dir]/$[get_output_bundle_file]] \
      $[if $[WINDOWS_PLATFORM], \
        $[if $[not $[lib_is_static]],$[install_lib_dir]/$[get_output_file_noext].lib] \
        $[if $[lib_has_pdb],$[install_lib_dir]/$[get_output_file_noext].pdb] \
      ] \
    ] \
    $[INSTALL_SCRIPTS:%=$[install_scripts_dir]/%] \
    $[INSTALL_HEADERS:%=$[install_headers_dir]/%] \
    $[INSTALL_DATA:%=$[install_data_dir]/%] \
    $[INSTALL_CONFIG:%=$[install_config_dir]/%] \
    $[igatedb:$[ODIR]/%=$[install_igatedb_dir]/%]

install-lib$[TARGET] : $[osgeneric $[installed_files]]

uninstall-lib$[TARGET] :
#if $[installed_files]
#foreach file $[sort $[installed_files]]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif

$[osgeneric $[install_lib_dir]/$[get_output_file]] : $[ODIR]/$[get_output_file]
#define local $[ODIR]/$[get_output_file]
#define dest $[install_lib_dir]
$[TAB] $[INSTALL_PROG]

#if $[link_extra_bundle]
$[osgeneric $[install_lib_dir]/$[get_output_bundle_file]] : $[ODIR]/$[get_output_bundle_file]
#define local $[ODIR]/$[get_output_bundle_file]
#define dest $[install_lib_dir]
$[TAB] $[INSTALL_PROG]
#endif  // link_extra_bundle

#if $[WINDOWS_PLATFORM]
// Install the .lib associated with a .dll.
#if $[not $[lib_is_static]]
$[osgeneric $[install_lib_dir]/$[get_output_file_noext].lib] : $[ODIR]/$[get_output_file_noext].lib
#define local $[ODIR]/$[get_output_file_noext].lib
#define dest $[install_lib_dir]
$[TAB] $[INSTALL]
#endif

#if $[lib_has_pdb]
$[osgeneric $[install_lib_dir]/$[get_output_file_noext].pdb] : $[ODIR]/$[get_output_file_noext].pdb
#define local $[ODIR]/$[get_output_file_noext].pdb
#define dest $[install_lib_dir]
$[TAB] $[INSTALL]
#endif
#endif // WINDOWS_PLATFORM

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

$[osgeneric $[igatedb:$[ODIR]/%=$[install_igatedb_dir]/%]] : $[osgeneric $[igatedb]]
#define local $[igatedb]
#define dest $[install_igatedb_dir]
$[TAB] $[INSTALL]

// We have to split this out as a separate rule to properly support
// parallel make.
$[igatedb] : $[igateoutput]

$[get_output_name]_igatescan = $[igatescan]
$[igateoutput] : $[osgeneric $[sort $[patsubst %.h,%.h,%.I,%.I,%.T,%.T,%,,$[dependencies $[igatescan]] $[igatescan:%=./%]]]]
$[TAB] $[INTERROGATE] -od $[igatedb] -oc $[igateoutput] $[interrogate_options] -module "$[igatemod]" -library "$[igatelib]" $($[get_output_name]_igatescan)

#endif  // igatescan


#if $[igatemout]
// And finally, some additional rules to build the interrogate module
// file into the library, if this is a metalib that includes
// interrogated components.

#define igatelib $[get_output_name]
#define igatemod $[TARGET]

$[get_output_name]_igatemscan = $[igatemscan]
#define target $[igatemout]
#define sources $($[get_output_name]_igatemscan)

$[target] : $[sources]
$[TAB] $[INTERROGATE_MODULE] -oc $[target] -module "$[igatemod]" -library "$[igatelib]" $[interrogate_module_options] $[sources]

#endif  // igatemout

#end python_target python_module_target metalib_target lib_target ss_lib_target static_lib_target dynamic_lib_target




/////////////////////////////////////////////////////////////////////
// Now, the noninstalled dynamic libraries.  These are presumably used
// only within this directory, or at the most within this tree, and
// also presumably will never include interrogate data.  That, plus
// the fact that we don't need to generate install rules, makes it a
// lot simpler.
/////////////////////////////////////////////////////////////////////

#forscopes noinst_lib_target
#define varname $[subst -,_,$[get_output_name]_so]
$[varname] = $[osgeneric $[patsubst %,$[%_obj],$[compile_sources]]]
#define target $[ODIR]/$[get_output_file]
#define sources $($[varname])
#define flags $[lflags]
$[target] : $[sources] $[static_lib_dependencies]
#if $[filter %.mm %.cxx %.yxx %.lxx,$[get_sources]]
$[TAB] $[link_lib_c++]
#else
$[TAB] $[link_lib_c]
#endif

#if $[WINDOWS_PLATFORM]
#if $[not $[lib_is_static]]
$[ODIR]/$[get_output_file_noext].lib : $[ODIR]/$[get_output_file]
#endif

#if $[lib_has_pdb]
$[ODIR]/$[get_output_file_noext].pdb : $[ODIR]/$[get_output_file]
#endif
#endif // WINDOWS_PLATFORM

#end noinst_lib_target

/////////////////////////////////////////////////////////////////////
// For interfaces, just install the headers, but don't build any code.
/////////////////////////////////////////////////////////////////////

#forscopes interface_target
// Here are the rules to install and uninstall the library and
// everything that goes along with it.
#define installed_files \
    $[INSTALL_HEADERS:%=$[install_headers_dir]/%]

install-lib$[TARGET] : $[osgeneric $[installed_files]]

uninstall-lib$[TARGET] :
#if $[installed_files]
#foreach file $[sort $[installed_files]]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif
#end interface_target


/////////////////////////////////////////////////////////////////////
// The sed_bin_targets are a special bunch.  These are scripts that
// are to be preprocessed with sed before being installed, for
// instance to insert a path or something in an appropriate place.
/////////////////////////////////////////////////////////////////////

#forscopes sed_bin_target
$[TARGET] : $[ODIR]/$[TARGET]

#define target $[ODIR]/$[TARGET]
#define source $[SOURCE]
#define script $[COMMAND]
$[target] : $[source]
$[TAB] $[SED]
$[TAB] chmod +x $[target]

#define installed_files \
    $[install_bin_dir]/$[TARGET]

install-$[TARGET] : $[osgeneric $[installed_files]]

uninstall-$[TARGET] :
#if $[installed_files]
#foreach file $[sort $[installed_files]]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif

#define local $[ODIR]/$[TARGET]
#define dest $[install_bin_dir]
$[osgeneric $[install_bin_dir]/$[TARGET]] : $[ODIR]/$[TARGET]
$[TAB] $[INSTALL_PROG]

#end sed_bin_target


/////////////////////////////////////////////////////////////////////
// And now, the bin_targets.  These are normal C++ executables.  No
// interrogate, metalibs, or any such nonsense here.
/////////////////////////////////////////////////////////////////////

#forscopes bin_target
$[TARGET] : $[ODIR]/$[TARGET]$[prog_ext]

#define varname $[subst -,_,bin_$[TARGET]]
$[varname] = $[osgeneric $[patsubst %,$[%_obj],$[compile_sources]]]
#define target $[ODIR]/$[TARGET]$[prog_ext]
#define sources $($[varname])
#define cc_ld $[or $[get_ld],$[CC]]
#define cxx_ld $[or $[get_ld],$[CXX]]
#define flags $[lflags]
$[target] : $[sources] $[static_lib_dependencies]
#if $[filter %.mm %.cxx %.yxx %.lxx,$[get_sources]]
$[TAB] $[link_bin_c++]
#else
$[TAB] $[link_bin_c]
#endif

#if $[WINDOWS_PLATFORM]
#if $[prog_has_pdb]
$[ODIR]/$[TARGET].pdb : $[target]
#endif
#endif

#define installed_files \
    $[install_bin_dir]/$[TARGET]$[prog_ext] \
    $[if $[prog_has_pdb],$[install_bin_dir]/$[TARGET].pdb] \
    $[INSTALL_SCRIPTS:%=$[install_scripts_dir]/%] \
    $[INSTALL_HEADERS:%=$[install_headers_dir]/%] \
    $[INSTALL_DATA:%=$[install_data_dir]/%] \
    $[INSTALL_CONFIG:%=$[install_config_dir]/%]

install-$[TARGET] : $[osgeneric $[installed_files]]

uninstall-$[TARGET] :
#if $[installed_files]
#foreach file $[sort $[installed_files]]
$[TAB] $[DEL_CMD $[file]]
#end file
#endif

$[osgeneric $[install_bin_dir]/$[TARGET]$[prog_ext]] : $[ODIR]/$[TARGET]$[prog_ext]
#define local $[ODIR]/$[TARGET]$[prog_ext]
#define dest $[install_bin_dir]
$[TAB] $[INSTALL_PROG]

#if $[prog_has_pdb]
$[osgeneric $[install_bin_dir]/$[TARGET].pdb] : $[ODIR]/$[TARGET].pdb
#define local $[ODIR]/$[TARGET].pdb
#define dest $[install_bin_dir]
$[TAB] $[INSTALL]
#endif

#end bin_target



/////////////////////////////////////////////////////////////////////
// The noinst_bin_targets and the test_bin_targets share the property
// of being built (when requested), but having no install rules.
/////////////////////////////////////////////////////////////////////

#forscopes noinst_bin_target test_bin_target
$[TARGET] : $[ODIR]/$[TARGET]$[prog_ext]

#define varname $[subst -,_,bin_$[TARGET]]
$[varname] = $[osgeneric $[patsubst %,$[%_obj],$[compile_sources]]]
#define target $[ODIR]/$[TARGET]$[prog_ext]
#define sources $($[varname])
#define cc_ld $[or $[get_ld],$[CC]]
#define cxx_ld $[or $[get_ld],$[CXX]]
#define flags $[lflags]
$[target] : $[sources] $[static_lib_dependencies]
#if $[filter %.mm %.cxx %.yxx %.lxx,$[get_sources]]
$[TAB] $[link_bin_c++]
#else
$[TAB] $[link_bin_c]
#endif

#end noinst_bin_target test_bin_target



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
$[target] : $[file]
$[TAB] $[BISON] $[YFLAGS] -y $[if $[YACC_PREFIX],-d --name-prefix=$[YACC_PREFIX]] $[file]
$[TAB] $[MOVE_CMD y.tab.c, $[target]]
$[TAB] $[MOVE_CMD y.tab.h, $[target_header]]
$[target_header] : $[target]
$[target_prebuilt] : $[target]
$[TAB] $[COPY_CMD $[target], $[target_prebuilt]]
$[target_header_prebuilt] : $[target_header]
$[TAB] $[COPY_CMD $[target_header], $[target_header_prebuilt]]
#else // HAVE_BISON
$[target] : $[target_prebuilt]
$[TAB] $[COPY_CMD $[target_prebuilt], $[target]]
$[target_header] : $[target_header_prebuilt]
$[TAB] $[COPY_CMD $[target_header_prebuilt], $[target_header]]
#endif // HAVE_BISON

#end file

// Rules to generate a C++ file from a Flex input file.
#foreach file $[sort $[lxx_st_sources]]
#define target $[patsubst %.lxx,%.cxx,$[file]]
#define target_prebuilt $[target].prebuilt
#if $[HAVE_BISON]
#define source $[file]
$[target] : $[file]
$[TAB] $[FLEX] $[FLEXFLAGS] $[if $[YACC_PREFIX],-P$[YACC_PREFIX]] -olex.yy.c $[file]
#define source lex.yy.c
#define script /#include <unistd.h>/d
$[TAB] $[SED]
$[TAB] $[DEL_CMD lex.yy.c]
$[target_prebuilt] : $[target]
$[TAB] $[COPY_CMD $[target], $[target_prebuilt]]
#else // HAVE_BISON
$[target] : $[target_prebuilt]
$[TAB] $[COPY_CMD $[target_prebuilt], $[target]]
#endif // HAVE_BISON

#end file


/////////////////////////////////////////////////////////////////////
// Finally, we put in the rules to compile each source file into a .obj
// file.
/////////////////////////////////////////////////////////////////////

#forscopes static_lib_target bin_target noinst_bin_target test_bin_target

// Rules to compile ordinary C files (static objects).
#foreach file $[sort $[c_sources]]
#define target $[$[file]_obj]
#define source $[file]
#define ipath $[target_ipath]
#if $[WINDOWS_PLATFORM]
#define flags $[cflags] $[building_var:%=/D%]
#else
#define flags $[cflags] $[building_var:%=-D%]
#endif
#if $[ne $[file], $[notdir $file]]
  // If the source file is not in the current directory, tack on "."
  // to front of the ipath.
  #set ipath . $[ipath]
#endif

$[target] : $[source] $[osgeneric $[get_depends $[source]]]
$[TAB] $[compile_c]

#end file

// Rules to compile C++ files (static objects).

#foreach file $[sort $[mm_sources] $[cxx_sources]]
#define target $[$[file]_obj]
#define source $[file]
#define ipath $[target_ipath]
#if $[WINDOWS_PLATFORM]
#define flags $[c++flags] $[building_var:%=/D%]
#else
#define flags $[c++flags] $[building_var:%=-D%]
#endif
#if $[ne $[file], $[notdir $file]]
  // If the source file is not in the current directory, tack on "."
  // to front of the ipath.
  #set ipath . $[ipath]
#endif

// Yacc must run before some files can be compiled, so all files
// depend on yacc having run.
$[target] : $[source] $[osgeneric $[get_depends $[source]]] $[generated_sources]
$[TAB] $[compile_c++]

#end file

#end static_lib_target bin_target noinst_bin_target test_bin_target

#forscopes python_target python_module_target metalib_target lib_target noinst_lib_target ss_lib_target

// Rules to compile ordinary C files (shared objects).
#foreach file $[sort $[c_sources]]
#define target $[$[file]_obj]
#define source $[file]
#define ipath $[target_ipath]
#define flags $[cflags] $[CFLAGS_SHARED] $[building_var:%=-D%]
#if $[ne $[file], $[notdir $file]]
  // If the source file is not in the current directory, tack on "."
  // to front of the ipath.
  #set ipath . $[ipath]
#endif

$[target] : $[source] $[osgeneric $[get_depends $[source]]]
$[TAB] $[compile_c]

#end file

// Rules to compile C++ files (shared objects).

#foreach file $[sort $[mm_sources] $[cxx_sources]]
#define target $[$[file]_obj]
#define source $[file]
#define ipath $[target_ipath]
#define flags $[c++flags] $[CFLAGS_SHARED] $[building_var:%=-D%]
#if $[ne $[file], $[notdir $file]]
  // If the source file is not in the current directory, tack on "."
  // to front of the ipath.
  #set ipath . $[ipath]
#endif

// Yacc must run before some files can be compiled, so all files
// depend on yacc having run.
$[target] : $[source] $[osgeneric $[get_depends $[source]]] $[yxx_sources:%.yxx=%.h]
$[TAB] $[compile_c++]

#end file

#end python_target python_module_target metalib_target lib_target noinst_lib_target ss_lib_target

// And now the rules to install the auxiliary files, like headers and
// data files.
#foreach file $[install_scripts]
#if $[ne $[dir $[file]], ./]
$[osgeneric $[install_scripts_dir]/$[file]] : $[file]
  #define local $[file]
  #define dest $[install_scripts_dir]/$[dir $[file]]
$[TAB] $[MKDIR_CMD $[dest]]
$[TAB] $[INSTALL_PROG]
#else
$[osgeneric $[install_scripts_dir]/$[file]] : $[file]
  #define local $[file]
  #define dest $[install_scripts_dir]
$[TAB] $[INSTALL_PROG]
#endif
#end file

#foreach file $[install_headers]
$[osgeneric $[install_headers_dir]/$[file]] : $[file]
#define local $[file]
#define dest $[install_headers_dir]
$[TAB] $[INSTALL]
#end file

#foreach file $[install_parser_inc]
#if $[ne $[dir $[file]], ./]
$[osgeneric $[install_parser_inc_dir]/$[file]] : $[file]
  #define local $[file]
  #define dest $[install_parser_inc_dir]/$[dir $[file]]
$[TAB] $[MKDIR_CMD $[dest]]
$[TAB] $[INSTALL]
#else
$[osgeneric $[install_parser_inc_dir]/$[file]] : $[file]
  #define local $[file]
  #define dest $[install_parser_inc_dir]
$[TAB] $[INSTALL]
#endif
#end file

#foreach file $[install_data]
$[osgeneric $[install_data_dir]/$[file]] : $[file]
#define local $[file]
#define dest $[install_data_dir]
$[TAB] $[INSTALL]
#end file

#foreach file $[install_config]
$[osgeneric $[install_config_dir]/$[file]] : $[file]
#define local $[file]
#define dest $[install_config_dir]
$[TAB] $[INSTALL]
#end file

#foreach file $[install_py]
$[osgeneric $[install_py_dir]/$[file]] : $[file]
#define local $[file]
#define dest $[install_py_dir]
$[TAB] $[INSTALL]
#end file

#if $[install_py]
$[osgeneric $[install_py_package_dir]/__init__.py] :
$[TAB] $[TOUCH_CMD $[install_py_package_dir]/__init__.py]
#endif

// Finally, all the special targets.  These are commands that just need
// to be invoked; we don't pretend to know what they are.
#forscopes special_target
$[TARGET] :
$[TAB] $[COMMAND]

#end special_target


// Finally, the rules to freshen the Makefile itself.
Makefile : $[SOURCE_FILENAME] $[EXTRA_PPREMAKE_SOURCE]
$[TAB] ppremake

#if $[USE_TAU]
#foreach composite_file $[composite_list]
$[composite_file] : $[$[composite_file]_sources]
$[TAB] ppremake
#end composite_file
#endif   // USE_TAU

#if $[and $[DEPENDENCY_CACHE_FILENAME],$[dep_sources]]
$[DEPENDENCY_CACHE_FILENAME] : $[dep_sources]
$[TAB] @ppremake -D $[DEPENDENCY_CACHE_FILENAME]
#endif

#end Makefile

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

#if $[PYTHON_PACKAGE]
#include $[THISDIRPREFIX]PythonPackageInit.pp
#endif

#output Makefile
#format makefile
#### Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE].
################################# DO NOT EDIT ###########################

all : $[subdirs]
test : $[subdirs:%=test-%]
igate : $[subdirs:%=igate-%]
clean : $[subdirs:%=clean-%]
clean-igate : $[subdirs:%=clean-igate-%]
cleanall : $[subdirs:%=cleanall-%]
install : $[osgeneric $[if $[CONFIG_HEADER],$[install_headers_dir] $[install_headers_dir]/$[CONFIG_HEADER]]] $[subdirs:%=install-%]
install-igate : $[subdirs:%=install-igate-%]
uninstall : $[subdirs:%=uninstall-%]
#if $[CONFIG_HEADER]
$[TAB]$[DEL_CMD $[install_headers_dir]/$[CONFIG_HEADER]]
#endif
uninstall-igate : $[subdirs:%=uninstall-igate-%]

#if $[HAVE_BISON]
prebuild-bison : $[subdirs:%=prebuild-bison-%]
clean-prebuild-bison : $[subdirs:%=clean-prebuild-bison-%]
#endif

#formap dirname subdirs
#define depends
$[dirname] : $[dirnames $[if $[build_directory],$[DIRNAME]],$[DEPEND_DIRS]]
$[TAB] cd ./$[PATH] && $(MAKE) all
#end dirname

#formap dirname subdirs
test-$[dirname] :
$[TAB] cd ./$[PATH] && $(MAKE) test
#end dirname

#formap dirname subdirs
igate-$[dirname] :
$[TAB]cd ./$[PATH] && $(MAKE) igate
#end dirname

#formap dirname subdirs
clean-$[dirname] :
$[TAB] cd ./$[PATH] && $(MAKE) clean
#end dirname

#formap dirname subdirs
clean-igate-$[dirname] :
$[TAB] cd ./$[PATH] && $(MAKE) clean-igate
#end dirname

#formap dirname subdirs
cleanall-$[dirname] : $[patsubst %,cleanall-%,$[dirnames $[if $[build_directory],$[DIRNAME]],$[DEPEND_DIRS]]]
$[TAB] cd ./$[PATH] && $(MAKE) cleanall
#end dirname

#formap dirname subdirs
install-$[dirname] : $[patsubst %,install-%,$[dirnames $[if $[build_directory],$[DIRNAME]],$[DEPEND_DIRS]]]
$[TAB] cd ./$[PATH] && $(MAKE) install
#end dirname

#formap dirname subdirs
install-igate-$[dirname] :
$[TAB] cd ./$[PATH] && $(MAKE) install-igate
#end dirname

#formap dirname subdirs
uninstall-$[dirname] :
$[TAB] cd ./$[PATH] && $(MAKE) uninstall
#end dirname

#formap dirname subdirs
uninstall-igate-$[dirname] :
$[TAB] cd ./$[PATH] && $(MAKE) uninstall-igate
#end dirname

#if $[HAVE_BISON]
#formap dirname subdirs
prebuild-bison-$[dirname] :
$[TAB]cd ./$[PATH] && $(MAKE) prebuild-bison
clean-prebuild-bison-$[dirname] :
$[TAB]cd ./$[PATH] && $(MAKE) clean-prebuild-bison
#end dirname
#endif

#if $[ne $[CONFIG_HEADER],]
$[osgeneric $[install_headers_dir]] :
$[TAB] $[MKDIR_CMD $[install_headers_dir]]

$[osgeneric $[install_headers_dir]/$[CONFIG_HEADER]] : $[CONFIG_HEADER]
#define local $[CONFIG_HEADER]
#define dest $[install_headers_dir]
$[TAB] $[INSTALL]
#endif

// Finally, the rules to freshen the Makefile itself.
Makefile : $[SOURCE_FILENAME] $[EXTRA_PPREMAKE_SOURCE]
$[TAB] ppremake

#end Makefile

// If there is a file called LocalSetup.pp in the package's top
// directory, then invoke that.  It might contain some further setup
// instructions.
#sinclude $[TOPDIRPREFIX]LocalSetup.unix.pp
#sinclude $[TOPDIRPREFIX]LocalSetup.pp


//////////////////////////////////////////////////////////////////////
#elif $[or $[eq $[DIR_TYPE], models],$[eq $[DIR_TYPE], models_toplevel],$[eq $[DIR_TYPE], models_group]]
//////////////////////////////////////////////////////////////////////

#include $[THISDIRPREFIX]Template.models.pp

//////////////////////////////////////////////////////////////////////
#endif // DIR_TYPE
