//
// Global.msbuild.pp
//
// This file is read in before any of the individual Sources.pp files
// are read.  It defines a few global variables to assist
// Template.msbuild.pp.
//

#define platform_config $[if $[WIN64_PLATFORM],x64,Win32]

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

// Scopes/targets that result in a .vcxproj
#define vcx_scopes \
  interface_target python_target python_module_target metalib_target \
  lib_target noinst_lib_target test_lib_target static_lib_target \
  dynamic_lib_target ss_lib_target bin_target noinst_bin_target test_bin_target

#defer get_depended_targets \
  $[sort $[get_metalibs $[TARGET],$[active_local_libs] $[active_igate_libs]] $[active_component_libs]]

#define platform_toolset $[MSBUILD_PLATFORM_TOOLSET]

#define tool_architecture $[if $[WIN64_PLATFORM],x64,x86]
