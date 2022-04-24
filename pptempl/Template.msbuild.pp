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
#defer cflags $[patsubst -D%,/D%,$[get_cflags] $[CFLAGS] $[CFLAGS_OPT$[OPTIMIZE]]] $[CFLAGS_SHARED]
#defer c++flags $[patsubst -D%,/D%,$[get_cflags] $[C++FLAGS] $[CFLAGS_OPT$[OPTIMIZE]]] $[CFLAGS_SHARED]

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

// Okay, we're ready.  Start outputting the projects now.
// Create a project for each target.
#forscopes $[vcx_scopes]

#if $[and $[build_directory],$[build_target]]

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

// Should the target be installed?
#define is_installed $[filter-out noinst_bin_target noinst_lib_target,$[SCOPE]]

// True if this is a lib_target and it's part of a metalib (and we're building
// components).
#define is_metalib_component $[and $[eq $[SCOPE],lib_target],$[not $[filter $[TARGET],$[real_lib_targets]]]]
#define is_metalib $[eq $[SCOPE],metalib_target]

#define is_lib $[filter python_target python_module_target metalib_target \
                        lib_target noinst_lib_target test_lib_target static_lib_target \
                        dynamic_lib_target ss_lib_target, $[SCOPE]]

#define is_bin $[filter bin_target noinst_bin_target test_bin_target,$[SCOPE]]

#define config_type \
  $[if $[filter bin_target noinst_bin_target test_bin_target,$[SCOPE]],Application, \
    $[if $[is_metalib_component],MetalibComponent, \
      $[if $[lib_is_static],StaticLibrary,DynamicLibrary]]]

// Miscellaneous files that are added to the project just so they are visible
// from within Visual Studio.
#define misc_files $[lxx_sources] $[yxx_sources] $[INSTALL_DATA] $[INSTALL_CONFIG] $[INSTALL_SCRIPTS]

#output $[TARGET].vcxproj
#format collapse
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. -->
<!--                              DO NOT EDIT                                       -->
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

// Write in references to all of the other projects we depend on, so MSBuild
// can correctly determine project-level build order.
<ItemGroup>
// These are the target names we depend on.
#foreach depend $[get_depended_targets]
  <ProjectReference Include="$[osfilename $[all_libs $[RELDIR],$[depend]]/$[depend].vcxproj]"/>
#end depend
</ItemGroup>

<PropertyGroup>
#if $[ne $[USE_COMPILER],MSVC]
  // If using a compiler other than the default, specify the compiler/linker
  // programs and the paths to them.
  <CLToolExe>$[COMPILER]</CLToolExe>
  <CLToolPath>$[osfilename $[COMPILER_PATH]]</CLToolPath>
  <LinkToolExe>$[LINKER]</LinkToolExe>
  <LinkToolPath>$[osfilename $[LINKER_PATH]]</LinkToolPath>
#endif
  <UseMultiToolTask>$[if $[MSBUILD_MULTIPROC],true,false]</UseMultiToolTask>
  <MultiProcMaxCount>$[MSBUILD_MULTIPROC_COUNT]</MultiProcMaxCount>
</PropertyGroup>

<ItemGroup>
  <ProjectConfiguration Include="Release|$[platform_config]">
    <Configuration>Release</Configuration>
    <Platform>$[platform_config]</Platform>
  </ProjectConfiguration>
</ItemGroup>

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.default.props" />

#define vs_target_name $[if $[eq $[config_type],Application],$[TARGET],$[get_output_file_noext]]
#define vs_target_ext \
  $[if $[eq $[config_type],Application],.exe, \
    $[if $[eq $[config_type],StaticLibrary],.lib,$[lib_ext]]]

<PropertyGroup>
  <ConfigurationType>$[config_type]</ConfigurationType>
  <PlatformToolset>$[platform_toolset]</PlatformToolset>
  <PreferredToolArchitecture>$[tool_architecture]</PreferredToolArchitecture>
  <IntDir>$[osfilename $[ODIR]]\</IntDir>
  <OutDir>$[osfilename $[ODIR]]\</OutDir>
  <TargetName>$[osfilename $[vs_target_name]]</TargetName>
  <TargetExt>$[osfilename $[vs_target_ext]]</TargetExt>
  <TargetPath>$[osfilename $[ODIR]/$[vs_target_name]$[vs_target_ext]]</TargetPath>
</PropertyGroup>

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />

// Add the header files from the target.
#define headers $[filter %.hpp %.h %.I %.T %_src.cxx,$[get_sources]]
<ItemGroup>
#foreach file $[headers]
  <ClInclude Include="$[osfilename $[file]]" />
#end file
</ItemGroup>

// Add the misc files.
#if $[misc_files]
<ItemGroup>
#foreach file $[misc_files]
  <None Include="$[file]" />
#end file
</ItemGroup>
#endif

#if $[compile_sources]

#define compiler_flags $[c++flags] $[extra_cflags]

// This is the list of compiler flags that are set using built-in ClCompile
// properties.  Anything not in this list is passed into AdditionalOptions.
#define builtin_compiler_flags \
  /RTCs /RTCu /RTC1 /GS /Gd /Gr /Gz /Gv /Z7 /Zi /ZI /arch:SSE2 /arch:SSE /GT /EHa /EHsc /EHs \
  /Os /Ot /fp:precise /fp:strict /fp:fast /Ob0 /Ob1 /Ob2 /Oi /Gm /MP /Oy /Od /O1 /O2 \
  /MTd /MDd /MT /MD /GR /RTCc /Zp16 /Zp8 /Zp4 /Zp2 /Zp1 /nologo /W0 /W1 /W2 /W3 /W4 \
  /Wall /GL /Fr"%" /D% /Fd"%" /Zc:forScope

// The additional options are any flags not part of the built-in list.
#define additional_compiler_flags $[filter-out $[builtin_compiler_flags],$[compiler_flags]]

// Determine a bunch of <ClCompile> properties based on the given compiler
// flags.
#define preprocessor_defs $[patsubst /D%,%,$[filter /D%,$[c++flags] $[extra_cflags]]] $[building_var]
#define runtime_checks Default
#if $[filter /RTCs,$[compiler_flags]]
  #set runtime_checks StackFrameRuntimeCheck
#elif $[filter /RTCu,$[compiler_flags]]
  #set runtime_checks UninitializedLocalUsageCheck
#elif $[filter /RTC1,$[compiler_flags]]
  #set runtime_checks EnableFastChecks
#endif
#define buffer_security_check $[if $[filter /GS,$[compiler_flags]],true,false]
#define calling_convention
#if $[filter /Gd,$[compiler_flags]]
  #set calling_convention Cdecl
#elif $[filter /Gr,$[compiler_flags]]
  #set calling_convention FastCall
#elif $[filter /Gz,$[compiler_flags]]
  #set calling_convention StdCall
#elif $[filter /Gv,$[compiler_flags]]
  #set calling_convention VectorCall
#endif
#define debug_information_format
#if $[filter /Z7,$[compiler_flags]]
  #set debug_information_format OldStyle
#elif $[filter /Zi,$[compiler_flags]]
  #set debug_information_format ProgramDatabase
#elif $[filter /ZI,$[compiler_flags]]
  #set debug_information_format EditAndContinue
#endif
#define enhanced_instruction_set
#if $[filter /arch:SSE2,$[compiler_flags]]
  #set enhanced_instruction_set StreamingSIMDExtensions2
#elif $[filter /arch:SSE,$[compiler_flags]]
  #set enhanced_instruction_set StreamingSIMDExtensions
#endif
#define fiber_safe_optimizations $[if $[filter /GT,$[compiler_flags]],true,false]
#define exception_handling false
#if $[filter /EHa,$[compiler_flags]]
  #set exception_handling Async
#elif $[filter /EHsc,$[compiler_flags]]
  #set exception_handling Sync
#elif $[filter /EHs,$[compiler_flags]]
  #set exception_handling SyncCThrow
#endif
#define size_or_speed Neither
#if $[filter /Os,$[compiler_flags]]
  #set size_or_speed Size
#elif $[filter /Ot,$[compiler_flags]]
  #set size_or_speed Speed
#endif
#define fp_exceptions $[if $[filter /fp:except,$[compiler_flags]],true,false]
#define fp_model
#if $[filter /fp:precise,$[compiler_flags]]
  #set fp_model Precise
#elif $[filter /fp:strict,$[compiler_flags]]
  #set fp_model Strict
#elif $[filter /fp:fast,$[compiler_flags]]
  #set fp_model Fast
#endif
#define for_scope_conformance $[if $[filter /Zc:forScope,$[compiler_flags]],true,false]
#define function_level_linking $[if $[filter /Gy,$[compiler_flags]],true,false]
#define inline_function_expansion Default
#if $[filter /Ob0,$[compiler_flags]]
  #set inline_function_expansion Disabled
#elif $[filter /Ob1,$[compiler_flags]]
  #set inline_function_expansion OnlyExplicitInline
#elif $[filter /Ob2,$[compiler_flags]]
  #set inline_function_expansion AnySuitable
#endif
#define intrinsic_functions $[if $[filter /Oi,$[compiler_flags]],true,false]
#define minimal_rebuild $[if $[filter /Gm,$[compiler_flags]],true,false]
#define multiprocessor_compilation $[if $[filter /MP,$[compiler_flags]],true,false]
#define omit_frame_pointers $[if $[filter /Oy,$[compiler_flags]],true,false]
#define optimization Full
#if $[filter /Od,$[compiler_flags]]
  #set optimization Disabled
#elif $[filter /O1,$[compiler_flags]]
  #set optimization MinSpace
#elif $[filter /O2,$[compiler_flags]]
  #set optimization MaxSpeed
#endif
#define runtime_library MultiThreaded
#if $[filter /MTd,$[compiler_flags]]
  #set runtime_library MultiThreadedDebug
#elif $[filter /MDd,$[compiler_flags]]
  #set runtime_library MultiThreadedDebugDLL
#elif $[filter /MD,$[compiler_flags]]
  #set runtime_library MultiThreadedDLL
#endif
#define rtti $[if $[filter /GR,$[compiler_flags]],true,false]
#define smaller_type_check $[if $[filter /RTCc,$[compiler_flags]],true,false]
#define struct_member_alignment Default
#if $[filter /Zp16,$[compiler_flags]]
  #set struct_member_alignment 16Bytes
#elif $[filter /Zp8,$[compiler_flags]]
  #set struct_member_alignment 8Bytes
#elif $[filter /Zp4,$[compiler_flags]]
  #set struct_member_alignment 4Bytes
#elif $[filter /Zp2,$[compiler_flags]]
  #set struct_member_alignment 2Bytes
#elif $[filter /Zp1,$[compiler_flags]]
  #set struct_member_alignment 1Byte
#endif
#define suppress_startup_banner $[if $[filter /nologo,$[compiler_flags]],true,false]
#define warning_level
#if $[filter /W0,$[compiler_flags]]
  #set warning_level TurnOffAllWarnings
#elif $[filter /W1,$[compiler_flags]]
  #set warning_level Level1
#elif $[filter /W2,$[compiler_flags]]
  #set warning_level Level2
#elif $[filter /W3,$[compiler_flags]]
  #set warning_level Level3
#elif $[filter /W4,$[compiler_flags]]
  #set warning_level Level4
#elif $[filter /Wall,$[compiler_flags]]
  #set warning_level EnableAllWarnings
#endif
#define whole_program_optimization $[if $[filter /GL,$[compiler_flags]],true,false]

// Add all of the source files for the target onto the list.
<ItemGroup>
#foreach file $[compile_sources]
  #define target $[$[file]_obj]
  #define source $[file]
  #define flags $[c++flags]
  #define browse_info $[patsubstw /Fr"%",%,$[filter /Fr"%",$[flags]]]
  #define pdb_filename $[patsubstw /Fd"%",%,$[filter /Fd"%",$[flags]]]
  <ClCompile Include="$[osfilename $[file]]">
    <ObjectFileName>$[osfilename $[target]]</ObjectFileName>
    <ProgramDatabaseFilename>$[osfilename $[pdb_filename]]</ProgramDatabaseFilename>
    <BrowseInformation>$[if $[browse_info],true,false]</BrowseInformation>
    <BrowseInformationFile>$[browse_info]</BrowseInformationFile>
  #if $[filter %.c,$[file]]
    // This is a C file.
    <CompileAs>CompileAsC</CompileAs>
  #else
    // Assume C++ if it's not a C file.
    <CompileAs>CompileAsCpp</CompileAs>
  #endif
  </ClCompile>
#end file
// If we are compositing, include the composited source files in the project,
// but don't compile them.
#if $[should_composite_sources]
#foreach file $[COMPOSITE_SOURCES]
  <None Include="$[osfilename $[file]]"/>
#end file
#endif
</ItemGroup>

// Add include directories and preprocessor definitions.
<ItemDefinitionGroup>
  <ClCompile>
    // Note the . to add the current directory.
    <AdditionalIncludeDirectories>$[msjoin $[osfilename . $[target_ipath]]]</AdditionalIncludeDirectories>
    <AdditionalOptions>$[additional_compiler_flags]</AdditionalOptions>
    <PreprocessorDefinitions>$[msjoin $[preprocessor_defs]]</PreprocessorDefinitions>
    <BasicRuntimeChecks>$[runtime_checks]</BasicRuntimeChecks>
    <BufferSecurityCheck>$[buffer_security_check]</BufferSecurityCheck>
    <CallingConvention>$[calling_convention]</CallingConvention>
    <DebugInformationFormat>$[debug_information_format]</DebugInformationFormat>
    <EnableEnhancedInstructionSet>$[enhanced_instruction_set]</EnableEnhancedInstructionSet>
    <EnableFiberSafeOptimizations>$[fiber_safe_optimizations]</EnableFiberSafeOptimizations>
    <ExceptionHandling>$[exception_handling]</ExceptionHandling>
    <FavorSizeOrSpeed>$[size_or_speed]</FavorSizeOrSpeed>
    <FloatingPointExceptions>$[fp_exceptions]</FloatingPointExceptions>
    <FloatingPointModel>$[fp_model]</FloatingPointModel>
    <ForceConformanceInForLoopScope>$[for_scope_conformance]</ForceConformanceInForLoopScope>
    <FunctionLevelLinking>$[function_level_linking]</FunctionLevelLinking>
    <InlineFunctionExpansion>$[inline_function_expansion]</InlineFunctionExpansion>
    <IntrinsicFunctions>$[intrinsic_functions]</IntrinsicFunctions>

    // These aren't supported on Clang.  If they are set they cause the project
    // to always rebuild from scratch.
    <MinimalRebuild>$[if $[ne $[USE_COMPILER], Clang],$[minimal_rebuild]]</MinimalRebuild>
    <MultiProcessorCompilation>$[if $[ne $[USE_COMPILER], Clang],$[multiprocessor_compilation]]</MultiProcessorCompilation>

    <OmitFramePointers>$[omit_frame_pointers]</OmitFramePointers>
    <Optimization>$[optimization]</Optimization>
    <RuntimeLibrary>$[runtime_library]</RuntimeLibrary>
    <RuntimeTypeInfo>$[rtti]</RuntimeTypeInfo>
    <SmallerTypeCheck>$[smaller_type_check]</SmallerTypeCheck>
    <StructMemberAlignment>$[struct_member_alignment]</StructMemberAlignment>
    <SuppressStartupBanner>$[suppress_startup_banner]</SuppressStartupBanner>
    <WarningLevel>$[warning_level]</WarningLevel>
    <ExternalWarningLevel></ExternalWarningLevel>
    <WholeProgramOptimization>$[whole_program_optimization]</WholeProgramOptimization>
  </ClCompile>
</ItemDefinitionGroup>

#endif // $[compile_sources]

// Set up the stuff to perform linking.
// Don't do this if we're a component on a metalib, though.  Those just get
// compiled into a bunch of .objs and are eventually linked into the metalib.
#if $[not $[is_metalib_component]]
#define extra_objs $[if $[and $[is_metalib],$[not $[BUILD_COMPONENTS]]], \
  $[components $[patsubst %,$[RELDIR]/$[%_obj],$[compile_sources]],$[active_component_libs]]]
<ItemDefinitionGroup>
  <Link>
    <AdditionalLibraryDirectories>$[msjoin $[osfilename $[lpath]]]</AdditionalLibraryDirectories>
    <AdditionalDependencies>$[msjoin $[osfilename $[patsubst %.lib,%.lib,%,lib%.lib,$[libs]] $[extra_objs]]]</AdditionalDependencies>
    <OutputFile>$[osfilename $[ODIR]/$[vs_target_name]$[vs_target_ext]]</OutputFile>
  </Link>
</ItemDefinitionGroup>
#endif

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.Targets" />

/////////////////////////////////////////////////////////////////////
// Rules to run interrogate as needed.
/////////////////////////////////////////////////////////////////////
#if $[igatescan]

// The library name is based on this library.
#define igatelib $[get_output_name]
// The module name comes from the Python module that includes this library.
#define igatemod $[python_module $[TARGET],$[TARGET]]
#if $[eq $[igatemod],]
  // Unless no metalib includes this library.
  #define igatemod $[TARGET]
#endif

#define igate_inputs $[sort $[patsubst %.h,%.h,%.I,%.I,%.T,%.T,%,,$[dependencies $[igatescan]] $[igatescan:%=./%]]]
// Target to run interrogate on the library.
<Target Name="igate"
        Inputs="$[msjoin $[osfilename $[igate_inputs]]]"
        Outputs="$[osfilename $[igateoutput]]"
        BeforeTargets="ClCompile">
  <Exec Command='$[INTERROGATE] -od $[igatedb] -oc $[igateoutput] $[interrogate_options] -module "$[igatemod]" -library "$[igatelib]" $[igatescan]'/>
</Target>

#endif // igatescan

#if $[igatemout]
// And finally, some additional rules to build the interrogate module
// file into the library, if this is a metalib that includes
// interrogated components.

#define igatelib $[get_output_name]
#define igatemod $[TARGET]

#define target $[igatemout]
#define sources $[igatemscan]

<Target Name="igate-module"
        Inputs="$[msjoin $[osfilename $[sources]]]"
        Outputs="$[osfilename $[target]]"
        BeforeTargets="ClCompile">
  <Exec Command='$[INTERROGATE_MODULE] -oc $[target] -module "$[igatemod]" -library "$[igatelib]" $[interrogate_module_options] $[sources]'/>
</Target>

#endif // igatemout

/////////////////////////////////////////////////////////////////////
// Rules to run bison and/or flex as needed.
/////////////////////////////////////////////////////////////////////

//////////////////// BISON ///////////////////////
#if $[yxx_sources]

#define targets $[patsubst %.yxx,%.cxx,$[yxx_sources]]
#define target_headers $[patsubst %.yxx,%.h,$[yxx_sources]]
#define targets_prebuilt $[patsubst %.yxx,%.cxx.prebuilt,$[yxx_sources]]
#define target_headers_prebuilt $[patsubst %.yxx,%.h.prebuilt,$[yxx_sources]]

// If bison is available, the inputs are the unbuilt yxx sources.  Bison will
// then be run to generate the outputs.
// If bison is not available, the inputs are the prebuilt bison sources, and
// we will simply copy them to the output files.
#define bison_inputs \
  $[if $[HAVE_BISON],$[yxx_sources],$[targets_prebuilt] $[target_headers_prebuilt]]

// Rules to generate a C++ file from a Bison input file.
<Target Name="bison"
        Inputs="$[msjoin $[osfilename $[bison_inputs]]]"
        Outputs="$[msjoin $[osfilename $[targets] $[target_headers]]]"
        BeforeTargets="ClCompile">
#if $[HAVE_BISON]

#foreach file $[yxx_sources]
  #define target $[patsubst %.yxx,%.cxx,$[file]]
  #define target_header $[patsubst %.yxx,%.h,$[file]]
  #define target_prebuilt $[target].prebuilt
  #define target_header_prebuilt $[target_header].prebuilt
  <Exec Command="$[BISON] $[YFLAGS] -y $[if $[YACC_PREFIX],-d --name-prefix=$[YACC_PREFIX]] $[osfilename $[file]]"/>
  <Exec Command="move /y y.tab.c $[osfilename $[target]]"/>
  <Exec Command="move /y y.tab.h $[osfilename $[target_header]]"/>
  <Exec Command="copy /y $[osfilename $[target]] $[osfilename $[target_prebuilt]]"/>
  <Exec Command="copy /y $[osfilename $[target_header]] $[osfilename $[target_header_prebuilt]]"/>
#end file

#else // HAVE_BISON

#foreach file $[yxx_sources]
  #define target $[patsubst %.yxx,%.cxx,$[file]]
  #define target_header $[patsubst %.yxx,%.h,$[file]]
  #define target_prebuilt $[target].prebuilt
  #define target_header_prebuilt $[target_header].prebuilt
  <Exec Command="copy /Y $[osfilename $[target_prebuilt]] $[osfilename $[target]]"/>
  <Exec Command="copy /Y $[osfilename $[target_header_prebuilt]] $[osfilename $[target_header]]"/>
#end file

#endif // HAVE_BISON
</Target>

#endif // $[yxx_sources]

//////////////////// FLEX ///////////////////////
#if $[lxx_sources]

#define targets $[patsubst %.lxx,%.cxx,$[lxx_sources]]
#define targets_prebuilt $[patsubst %.lxx,%.cxx.prebuilt,$[lxx_sources]]

#define flex_inputs \
  $[if $[HAVE_BISON],$[lxx_sources],$[targets_prebuilt]]

// Rules to generate a C++ file from a Flex input file.
<Target Name="flex"
        Inputs="$[msjoin $[osfilename $[flex_inputs]]]"
        Outputs="$[msjoin $[osfilename $[targets]]]"
        BeforeTargets="ClCompile">

#if $[HAVE_BISON]

#foreach file $[lxx_sources]
  #define target $[patsubst %.lxx,%.cxx,$[file]]
  #define target_prebuilt $[target].prebuilt
  <Exec Command="$[FLEX] $[FLEXFLAGS] $[if $[YACC_PREFIX],-P$[YACC_PREFIX]] -olex.yy.c $[osfilename $[file]]"/>
  #define source lex.yy.c
  #define script /#include <unistd.h>/d
  <Exec Command="$[SED]"/>
  <Exec Command="if exist lex.yy.c del lex.yy.c"/>
  <Exec Command="copy /Y $[osfilename $[target]] $[osfilename $[target_prebuilt]]"/>
#end file

#else // HAVE_BISON

#foreach file $[lxx_sources]
  #define target $[patsubst %.lxx,%.cxx,$[file]]
  #define target_prebuilt $[target].prebuilt
  <Exec Command="copy /Y $[osfilename $[target_prebuilt]] $[osfilename $[target]]"/>
#end file

#endif // HAVE_BISON
</Target>

#endif // $[lxx_sources]

#if $[is_installed]

// Here are the rules to install and uninstall the library and
// everything that goes along with it.
#define install_files \
  $[if $[and $[build_lib],$[is_lib]],\
    $[ODIR]/$[get_output_file] \
    $[if $[not $[lib_is_static]],$[ODIR]/$[get_output_lib]] \
      $[if $[has_pdb],$[ODIR]/$[get_output_pdb]] \
  ] \
  $[if $[is_bin], \
    $[ODIR]/$[TARGET].exe \
    $[if $[has_pdb],$[ODIR]/$[TARGET].pdb] \
  ] \
  $[INSTALL_SCRIPTS] \
  $[INSTALL_MODULES] \
  $[INSTALL_HEADERS] \
  $[INSTALL_DATA] \
  $[INSTALL_CONFIG] \
  $[igatedb]

#define installed_files \
    $[if $[and $[build_lib],$[is_lib]], \
      $[install_lib_dir]/$[get_output_file] \
      $[if $[not $[lib_is_static]],$[install_lib_dir]/$[get_output_lib]] \
      $[if $[has_pdb],$[install_lib_dir]/$[get_output_pdb]] \
    ] \
    $[if $[is_bin], \
      $[install_bin_dir]/$[TARGET].exe \
      $[if $[has_pdb],$[install_bin_dir]/$[TARGET].pdb] \
    ] \
    $[INSTALL_SCRIPTS:%=$[install_scripts_dir]/%] \
    $[INSTALL_MODULES:%=$[install_lib_dir]/%] \
    $[INSTALL_HEADERS:%=$[install_headers_dir]/%] \
    $[INSTALL_DATA:%=$[install_data_dir]/%] \
    $[INSTALL_CONFIG:%=$[install_config_dir]/%] \
    $[igatedb:$[ODIR]/%=$[install_igatedb_dir]/%]

// Now create the rules to install the stuff.
<Target Name="install"
        Outputs="$[msjoin $[osfilename $[installed_files]]]"
        Inputs="$[msjoin $[osfilename $[install_files]]]"
        DependsOnTargets="Build">
#if $[and $[build_lib],$[is_lib]]
  <Copy SourceFiles="$[osfilename $[ODIR]/$[get_output_file]]"
        DestinationFiles="$[osfilename $[install_lib_dir]/$[get_output_file]]"
        SkipUnchangedFiles="true" />
  #if $[not $[lib_is_static]]
  <Copy SourceFiles="$[osfilename $[ODIR]/$[get_output_lib]]"
        DestinationFiles="$[osfilename $[install_lib_dir]/$[get_output_lib]]"
        SkipUnchangedFiles="true" />
  #endif
  #if $[has_pdb]
  <Copy SourceFiles="$[osfilename $[ODIR]/$[get_output_pdb]]"
        DestinationFiles="$[osfilename $[install_lib_dir]/$[get_output_pdb]]"
        SkipUnchangedFiles="true" />
  #endif
#endif

#if $[is_bin]
  <Copy SourceFiles="$[osfilename $[ODIR]/$[TARGET].exe]"
        DestinationFiles="$[osfilename $[install_bin_dir]/$[TARGET].exe]"
        SkipUnchangedFiles="true" />

  #if $[has_pdb]
  <Copy SourceFiles="$[osfilename $[ODIR]/$[TARGET].pdb]"
        DestinationFiles="$[osfilename $[install_bin_dir]/$[TARGET].pdb]"
        SkipUnchangedFiles="true" />
  #endif
#endif

#if $[INSTALL_SCRIPTS]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_SCRIPTS]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_SCRIPTS:%=$[install_scripts_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_MODULES]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_MODULES]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_MODULES:%=$[install_lib_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_HEADERS]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_HEADERS]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_HEADERS:%=$[install_headers_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_DATA]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_DATA]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_DATA:%=$[install_data_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_CONFIG]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_CONFIG]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_CONFIG:%=$[install_config_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[igatedb]
  <Copy SourceFiles="$[msjoin $[osfilename $[igatedb]]]"
        DestinationFiles="$[msjoin $[osfilename $[igatedb:$[ODIR]/%=$[install_igatedb_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif
</Target>

<Target Name="uninstall">
#if $[installed_files]
  <Delete Files="$[msjoin $[osfilename $[installed_files]]]" />
#endif
</Target>

// Make rules to clean the project, i.e delete all intermediate and output
// build files, to reset the build to a clean slate.

// This target cleans interrogated-generated code.
<Target Name="clean-igate">
#if $[igatedb]
  <Delete Files="$[msjoin $[osfilename $[igatedb]]]" />
#endif
#if $[igateoutput]
  <Delete Files="$[msjoin $[osfilename $[igateoutput] $[$[igateoutput]_obj]]]" />
#endif
#if $[igatemout]
  <Delete Files="$[msjoin $[osfilename $[igatemout] $[$[igatemout]_obj]]]" />
#endif
</Target>

// This target cleans compiled source files, libraries, and Bison/Flex
// generated files.
<Target Name="clean" DependsOnTargets="clean-igate">
// Delete compiled source files.
#if $[compile_sources]
  <Delete Files="$[msjoin $[osfilename $[patsubst %,$[%_obj],$[compile_sources]]]]" />
#endif

// Delete a linked library.
#if $[and $[is_lib],$[not $[is_metalib_component]]]
  <Delete Files="$[osfilename $[ODIR]/$[get_output_file]]" />
  #if $[not $[lib_is_static]]
  <Delete Files="$[osfilename $[ODIR]/$[get_output_lib]]" />
  #endif
  #if $[has_pdb]
  <Delete Files="$[osfilename $[ODIR]/$[get_output_pdb]]" />
  #endif

// Delete a binary.
#elif $[is_bin]
  <Delete Files="$[osfilename $[ODIR]/$[TARGET].exe]" />
  #if $[has_pdb]
  <Delete Files="$[osfilename $[ODIR]/$[TARGET].pdb]" />
  #endif
#endif

// Delete Bison/Flex generated files.
#if $[yxx_sources]
  <Delete Files="$[msjoin $[osfilename $[patsubst %.yxx,%.cxx %.h,$[yxx_sources]]]]" />
#endif
#if $[lxx_sources]
  <Delete Files="$[msjoin $[osfilename $[patsubst %.lxx,%.cxx,$[lxx_sources]]]]" />
#endif

</Target>

// This is only used by directory-level projects, but it needs to be stubbed
// here.
<Target Name="cleanall" DependsOnTargets="clean" />

#endif // $[is_installed]

</Project>

#end $[TARGET].vcxproj

// Add a filter file to organize the headers and source files.
#output $[TARGET].vcxproj.filters
#format collapse
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. -->
<!--                              DO NOT EDIT                                       -->
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

// Add each header file to the filter.
<ItemGroup>
#foreach file $[headers]
  <ClInclude Include="$[osfilename $[file]]">
    <Filter>Header Files</Filter>
  </ClInclude>
#end file
</ItemGroup>

// Now add each source file.
<ItemGroup>
#foreach file $[compile_sources]
  <ClCompile Include="$[osfilename $[file]]">
	<Filter>Source Files</Filter>
  </ClCompile>
#end file
#if $[should_composite_sources]
#foreach file $[COMPOSITE_SOURCES]
  <None Include="$[osfilename $[file]]">
    <Filter>Source Files</Filter>
  </None>
#end file
#endif
</ItemGroup>

<ItemGroup>
  <Filter Include="Source Files" />
  <Filter Include="Header Files" />
</ItemGroup>

</Project>

#end $[TARGET].vcxproj.filters

#endif // $[and $[build_directory],$[build_target]]

#end $[vcx_scopes]

// We need another project to install directory-level files, aka scripts and
// config files that are not inside a target.
#output dir_$[DIRNAME].vcxproj
#format collapse
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. -->
<!--                              DO NOT EDIT                                       -->
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

// Miscellaneous files that are added to the project just so they are visible
// from within Visual Studio.
#define misc_files $[lxx_sources] $[yxx_sources] $[INSTALL_DATA] $[INSTALL_CONFIG] \
                   $[INSTALL_SCRIPTS] $[INSTALL_HEADERS] \
                   $[INSTALL_MODULES] $[INSTALL_PARSER_INC] $[install_py]

// The directory-level project depends on all of the target-level projects.
<ItemGroup>
#forscopes $[vcx_scopes]
#if $[and $[build_directory],$[build_target]]
  <ProjectReference Include="$[osfilename $[RELDIR]/$[TARGET].vcxproj]"/>
#endif
#end $[vcx_scopes]
</ItemGroup>

<ItemGroup>
  <ProjectConfiguration Include="Release|$[platform_config]">
    <Configuration>Release</Configuration>
    <Platform>$[platform_config]</Platform>
  </ProjectConfiguration>
</ItemGroup>

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.default.props" />

<PropertyGroup>
  <PlatformToolset>$[platform_toolset]</PlatformToolset>
</PropertyGroup>

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.Targets" />

// Add the Sources.pp file so it is visible within Visual Studio.
<ItemGroup>
    <None Include="$[SOURCEFILE]"/>
</ItemGroup>

// And the misc files.
#if $[misc_files]
<ItemGroup>
#foreach file $[misc_files]
  <None Include="$[file]" />
#end file
</ItemGroup>
#endif

// Here are all the directory-level things we can install.
#define install_files \
  $[INSTALL_SCRIPTS] \
  $[INSTALL_MODULES] \
  $[INSTALL_HEADERS] \
  $[INSTALL_PARSER_INC] \
  $[INSTALL_DATA] \
  $[INSTALL_CONFIG] \
  $[if $[install_py], $[install_py] __init__.py]

#define installed_files \
    $[INSTALL_SCRIPTS:%=$[install_scripts_dir]/%] \
    $[INSTALL_MODULES:%=$[install_lib_dir]/%] \
    $[INSTALL_HEADERS:%=$[install_headers_dir]/%] \
    $[INSTALL_PARSER_INC:%=$[install_parser_inc_dir]/%] \
    $[INSTALL_DATA:%=$[install_data_dir]/%] \
    $[INSTALL_CONFIG:%=$[install_config_dir]/%] \
    $[if $[install_py],$[install_py:%=$[install_py_dir]/%] $[install_py_package_dir]/__init__.py]

<Target Name="install"
        Inputs="$[msjoin $[osfilename $[install_files]]]"
        Outputs="$[msjoin $[osfilename $[installed_files]]]">
#if $[INSTALL_SCRIPTS]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_SCRIPTS]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_SCRIPTS:%=$[install_scripts_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_MODULES]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_MODULES]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_MODULES:%=$[install_lib_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_HEADERS]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_HEADERS]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_HEADERS:%=$[install_headers_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_PARSER_INC]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_PARSER_INC]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_PARSER_INC:%=$[install_parser_inc_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_DATA]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_DATA]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_DATA:%=$[install_data_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[INSTALL_CONFIG]
  <Copy SourceFiles="$[msjoin $[osfilename $[INSTALL_CONFIG]]]"
        DestinationFiles="$[msjoin $[osfilename $[INSTALL_CONFIG:%=$[install_config_dir]/%]]]"
        SkipUnchangedFiles="true" />
#endif

#if $[install_py]
  <Copy SourceFiles="$[msjoin $[osfilename $[install_py]]]"
        DestinationFiles="$[msjoin $[osfilename $[install_py:%=$[install_py_dir]/%]]]"
        SkipUnchangedFiles="true" />
  <Touch Files="$[osfilename $[install_py_package_dir]/__init__.py]" AlwaysCreate="true" />
#endif
</Target>

<Target Name="uninstall">
#if $[installed_files]
  <Delete Files="$[msjoin $[osfilename $[installed_files]]]" />
#endif
</Target>

// Stub out clean-igate and clean targets, which only mean something to
// target-level projects.
<Target Name="clean-igate" />
<Target Name="clean" DependsOnTargets="clean-igate">
#if $[py_sources]
  // Scrub out old generated Python code.
  <Delete Files="*.pyc;*.pyo" />
  // Python 3 puts bytecode in a __pycache__ folder.
  <RemoveDir Directories="__pycache__" />
#endif
</Target>

// This target is intended to undo all the effects of running ppremake and
// building.  It removes everything except the projects.
<Target Name="cleanall" DependsOnTargets="clean">
  <RemoveDir Directories="$[osfilename $[ODIR]]" />
#if $[DEPENDENCY_CACHE_FILENAME]
  <Delete Files="$[osfilename $[DEPENDENCY_CACHE_FILENAME]]" />
#endif
#if $[composite_list]
  <Delete Files="$[msjoin $[osfilename $[composite_list]]]" />
#endif
</Target>

</Project>

#end dir_$[DIRNAME].vcxproj

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

// Miscellaneous files that are added to the project just so they are visible
// from within Visual Studio.
#define misc_files $[CONFIG_HEADER]

// We need a top-level project to install the config header... booo!
#output dir_$[DIRNAME].vcxproj
#format collapse
<?xml version="1.0" encoding="utf-8"?>
<!-- Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE]. -->
<!--                              DO NOT EDIT                                       -->
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

<ItemGroup>
  <ProjectConfiguration Include="Release|$[platform_config]">
    <Configuration>Release</Configuration>
    <Platform>$[platform_config]</Platform>
  </ProjectConfiguration>
</ItemGroup>

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.default.props" />

<PropertyGroup>
  <PlatformToolset>$[platform_toolset]</PlatformToolset>
</PropertyGroup>

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />

<Import Project="$(VCTargetsPath)\Microsoft.Cpp.Targets" />

// Add the Sources.pp and Package.pp files.
<ItemGroup>
  <None Include="$[SOURCE_FILENAME]" />
  <None Include="$[PACKAGE_FILENAME]" />
</ItemGroup>

// Add the misc files.
#if $[misc_files]
<ItemGroup>
#foreach file $[misc_files]
  <None Include="$[file]" />
#end file
</ItemGroup>
#endif

#define install_files \
  $[CONFIG_HEADER]

#define installed_files \
  $[if $[CONFIG_HEADER],$[install_headers_dir]/$[CONFIG_HEADER]]

<Target Name="install"
        Inputs="$[msjoin $[osfilename $[install_files]]]"
        Outputs="$[msjoin $[osfilename $[installed_files]]]">
#if $[install_files]
  <Copy SourceFiles="$[msjoin $[osfilename $[install_files]]]"
        DestinationFiles="$[msjoin $[osfilename $[installed_files]]]"
        SkipUnchangedFiles="true" />
#endif
</Target>

<Target Name="uninstall">
#if $[installed_files]
  <Delete Files="$[msjoin $[osfilename $[installed_files]]]" />
#endif
</Target>

<Target Name="clean-igate" />
<Target Name="clean" DependsOnTargets="clean-igate" />
<Target Name="cleanall" DependsOnTargets="clean" />

</Project>

#end dir_$[DIRNAME].vcxproj

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

#define project_scopes \
  $[patsubst %,*/%,$[vcx_scopes]]

#if $[PYTHON_PACKAGE]
#include $[THISDIRPREFIX]PythonPackageInit.pp
#endif

#output $[PACKAGE].sln
#format collapse
Microsoft Visual Studio Solution File, Format Version 12.00
#forscopes $[project_scopes]
#if $[and $[build_directory],$[build_target]]
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "$[TARGET]", "$[osfilename $[PATH]/$[TARGET].vcxproj]", "{$[makeguid $[TARGET]]}"
	ProjectSection(ProjectDependencies) = postProject
#foreach depend $[get_depended_targets]
		{$[makeguid $[depend]]} = {$[makeguid $[depend]]}
 #end depend
	EndProjectSection
EndProject
#endif
#end $[project_scopes]
// Also add in the directory-level projects.
#formap dirname subdirs
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "dir_$[dirname]", "$[osfilename $[PATH]/dir_$[dirname].vcxproj]", "{$[makeguid dir_$[dirname]]}"
  // The directory-level project depends on all the target-level projects in the directory.
	ProjectSection(ProjectDependencies) = postProject
    #define depend_scopes $[patsubst %,$[dirname]/%,$[vcx_scopes]]
    #forscopes $[depend_scopes]
    #if $[and $[build_directory],$[build_target]]
		{$[makeguid $[TARGET]]} = {$[makeguid $[TARGET]]}
    #endif
    #end $[depend_scopes]
	EndProjectSection
EndProject
// Also add a solution folder that will group the targets in a directory.
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "$[dirname]", "$[dirname]", "{$[makeguid folder_$[dirname]]}"
EndProject
#end dirname
// And the top-level project.
Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "dir_$[DIRNAME]", "$[osfilename $[PATH]/dir_$[DIRNAME].vcxproj]", "{$[makeguid dir_$[DIRNAME]]}"
EndProject
// Top-level solution folder.
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "$[DIRNAME]", "$[DIRNAME]", "{$[makeguid folder_$[DIRNAME]]}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Release|$[platform_config] = Release|$[platform_config]
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
#forscopes $[project_scopes]
#if $[and $[build_directory],$[build_target]]
#define guid $[makeguid $[TARGET]]
		{$[guid]}.Release|$[platform_config].ActiveCfg = Release|$[platform_config]
		{$[guid]}.Release|$[platform_config].Build.0 = Release|$[platform_config]
#endif
#end $[project_scopes]
// Also add in the directory-level projects.
#formap dirname subdirs
#define guid $[makeguid dir_$[dirname]]
		{$[guid]}.Release|$[platform_config].ActiveCfg = Release|$[platform_config]
		{$[guid]}.Release|$[platform_config].Build.0 = Release|$[platform_config]
#end dirname
// And the top-level project.
#define guid $[makeguid dir_$[DIRNAME]]
		{$[guid]}.Release|$[platform_config].ActiveCfg = Release|$[platform_config]
		{$[guid]}.Release|$[platform_config].Build.0 = Release|$[platform_config]
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
	EndGlobalSection
	GlobalSection(NestedProjects) = preSolution
#forscopes $[project_scopes]
#if $[and $[build_directory],$[build_target]]
		{$[makeguid $[TARGET]]} = {$[makeguid folder_$[DIRNAME]]}
#endif
#end $[project_scopes]
#formap dirname subdirs
		{$[makeguid dir_$[dirname]]} = {$[makeguid folder_$[dirname]]}
#end dirname
		{$[makeguid dir_$[DIRNAME]]} = {$[makeguid folder_$[DIRNAME]]}
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
    SolutionGuid = {$[makeguid $[PACKAGE].sln]}
	EndGlobalSection
EndGlobal
#end $[PACKAGE].sln

// If there is a file called LocalSetup.pp in the package's top
// directory, then invoke that.  It might contain some further setup
// instructions.
#sinclude $[TOPDIRPREFIX]LocalSetup.msbuild.pp
#sinclude $[TOPDIRPREFIX]LocalSetup.pp


//////////////////////////////////////////////////////////////////////
#elif $[or $[eq $[DIR_TYPE], models],$[eq $[DIR_TYPE], models_toplevel],$[eq $[DIR_TYPE], models_group]]
//////////////////////////////////////////////////////////////////////

#include $[THISDIRPREFIX]Template.models.pp

//////////////////////////////////////////////////////////////////////

#endif // DIR_TYPE
