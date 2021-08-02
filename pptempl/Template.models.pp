//
// Template.models.pp
//
// This file defines the Makefiles that will be built to generate
// models (egg, bam models computed from flt, soft, alias,
// etc. sources).  Unlike the other Template files, this is not based
// directly on the BUILD_TYPE, but is specifically included when a
// directory specifies a DIR_TYPE of "models".  It uses some
// Unix-specific conventions (like forward slashes as a directory
// separator), so it requires either a Unix platform or a Cygwin
// environment.
//

#if $[< $[PPREMAKE_VERSION],1.23]
  #error You need at least ppremake version 1.23 to build models.
#endif

#if $[and $[CTPROJS],$[not $[findstring PANDATOOL,$[CTPROJS]]]]
  #error You must be attached to PANDATOOL to build models.
#endif

// Search for the texattrib dir definition.  This will be in the
// models_topdir directory.
#define texattrib_dir $[dir_type $[TEXATTRIB_DIR],models_toplevel]

// Prefix $[TOPDIR].  If it wasn't defined, make a default.
#if $[texattrib_dir]
  #define texattrib_dir $[TOPDIR]/$[texattrib_dir]
#else
  #define texattrib_dir $[TOPDIR]/src/maps
#endif
#define texattrib_file $[texattrib_dir]/textures.txa

#if $[eq $[BUILD_TYPE], nmake]
  #define TOUCH_CMD echo.>>
  #define COPY_CMD xcopy /I/Y
  #define DEL_CMD del /f/s/q
  #define DEL_DIR_CMD rmdir /s/q
#else
  #define TOUCH_CMD touch
  #define COPY_CMD cp
  #define DEL_CMD rm -rf
  #define DEL_DIR_CMD rm -rf
#endif

//////////////////////////////////////////////////////////////////////
#if $[eq $[DIR_TYPE], models]
//////////////////////////////////////////////////////////////////////

#define ABSDIR $[TOPDIR]/$[PATH]

#define pal_egg_dir pal_egg
#define bam_dir bams

#defer phase_prefix $[if $[PHASE],phase_$[PHASE]/]
#defer install_model_dir $[install_dir]/$[phase_prefix]$[INSTALL_TO]
#defer install_tex_dir $[install_dir]/$[phase_prefix]maps
#defer install_mats_dir $[install_dir]/$[phase_prefix]materials

#defer install_egg_sources $[SOURCES] $[SOURCES_NC] $[UNPAL_SOURCES] $[UNPAL_SOURCES_NC]

#define filter_dirs $[sort $[TARGET_DIR(filter_egg filter_char_egg optchar_egg)]]

#defer source_prefix $[SOURCE_DIR:%=%/]

#if $[LANGUAGES]
  #define exlanguage_sources $[notdir $[filter %.flt %.mb %.ma %.lwo %.LWO %.egg %.dna,$[wildcard $[TOPDIR]/$[DIRPREFIX]*_$[LANGUAGE].*]]]

  #defun lang_add_files sources, src_ext, local_extra
    #define default_filter
    #define local_filter
    #foreach ext $[src_ext]
      #set default_filter $[default_filter] %_$[DEFAULT_LANGUAGE].$[ext]
      #set local_filter $[local_filter] %_$[LANGUAGE].$[ext]
    #end ext
    #define default_langlist $[filter $[default_filter],$[sources]]
    #define locallist $[filter $[local_filter],$[local_extra] $[exlanguage_sources]]
    #define havelist
    #foreach file $[default_langlist]
      #foreach ext $[src_ext]
        #define wantfile $[file:%_$[DEFAULT_LANGUAGE].$[ext]=%_$[LANGUAGE].$[ext]]
        #set havelist $[havelist] $[filter $[wantfile],$[locallist]]
      #end ext
    #end file
    $[havelist]
  #end lang_add_files

  #forscopes flt_egg
    #if $[SOURCES]
      #set SOURCES $[sort $[SOURCES] $[lang_add_files $[SOURCES], flt, ]]
    #endif
  #end flt_egg

  #forscopes lwo_egg
    #if $[SOURCES]
      #set SOURCES $[sort $[SOURCES] $[lang_add_files $[SOURCES], lwo LWO, ]]
    #endif
  #end lwo_egg

  #forscopes maya_egg
    #if $[SOURCES]
      #set SOURCES $[sort $[SOURCES] $[lang_add_files $[SOURCES], mb ma, ]]
    #endif
  #end maya_egg

  #forscopes blender_egg
    #if $[SOURCES]
      #set SOURCES $[sort $[SOURCES] $[lang_add_files $[SOURCES], blend, ]]
    #endif
  #end blender_egg
#endif

#define build_flt_eggs \
   $[forscopes flt_egg,$[patsubst %.flt,%$[EGG_SUFFIX].egg,$[SOURCES]]]

#define build_lwo_eggs \
   $[forscopes lwo_egg,$[patsubst %.lwo %.LWO,%$[EGG_SUFFIX].egg,$[SOURCES]]]

#define build_maya_eggs \
   $[forscopes maya_egg,$[patsubst %$[MODEL].ma %$[MODEL].mb ,$[EGG_PREFIX]%$[EGG_SUFFIX].egg,$[SOURCES]]] \
   $[forscopes maya_char_egg,$[POLY_MODEL:%=$[EGG_PREFIX]%$[EGG_SUFFIX].egg] $[NURBS_MODEL:%=$[EGG_PREFIX]%$[EGG_SUFFIX].egg]] \
   $[forscopes maya_char_egg,$[ANIMS:%=$[EGG_PREFIX]%$[CHAN_SUFFIX].egg]]

#define build_soft_eggs \
   $[forscopes soft_char_egg,$[POLY_MODEL:%=$[EGG_PREFIX]%$[EGG_SUFFIX].egg] $[NURBS_MODEL:%=$[EGG_PREFIX]%$[EGG_SUFFIX].egg]] \
   $[forscopes soft_char_egg,$[ANIMS:%=$[EGG_PREFIX]%$[CHAN_SUFFIX].egg]]

#define build_blender_eggs \
   $[forscopes blender_egg,$[patsubst %.blend,$[EGG_PREFIX]%$[EGG_SUFFIX].egg,$[SOURCES]]] \
   $[forscopes blender_char_egg,$[POLY_MODEL:%=$[EGG_PREFIX]%$[EGG_SUFFIX].egg]] \
   $[forscopes blender_char_egg,$[ANIMS:%=$[if $[ANIMS_DIR],$[ANIMS_DIR]/,]$[EGG_PREFIX]%$[CHAN_SUFFIX].egg]]

#define build_eggs \
   $[sort \
     $[build_flt_eggs] \
     $[build_lwo_eggs] \
     $[build_maya_eggs] \
     $[build_soft_eggs] \
     $[build_blender_eggs]]

#define optchar_dirs \
   $[unique $[forscopes optchar_egg,$[TARGET_DIR]]]

#if $[LANGUAGES]
  #forscopes install_egg filter_egg
    #if $[SOURCES]
      #set SOURCES $[sort $[SOURCES] $[lang_add_files $[SOURCES], egg, $[build_eggs]]]
    #endif
  #end install_egg filter_egg

  #forscopes install_dna
    #if $[SOURCES]
      #set SOURCES $[sort $[SOURCES] $[lang_add_files $[SOURCES], dna, ]]
    #endif
  #end install_dna
#endif

// Get the list of egg files that are to be installed
#define install_pal_eggs
#define install_unpal_eggs
#forscopes install_egg
  #define egglist $[notdir $[SOURCES]]
  #set install_pal_eggs $[install_pal_eggs] $[filter-out $[language_egg_filters],$[egglist]]
  #if $[LANGUAGES]
    // Now look for the eggs of the current language.
    #foreach egg $[filter %_$[DEFAULT_LANGUAGE].egg,$[egglist]]
      #define wantegg $[egg:%_$[DEFAULT_LANGUAGE].egg=%_$[LANGUAGE].egg]
      #if $[filter $[wantegg],$[egglist]]
          // The current language file exists.
        #set install_pal_eggs $[install_pal_eggs] $[wantegg]
      #else
        #set install_pal_eggs $[install_pal_eggs] $[egg]
      #endif
    #end egg
  #endif
  #define egglist $[notdir $[UNPAL_SOURCES] $[UNPAL_SOURCES_NC]]
  #set install_unpal_eggs $[install_unpal_eggs] $[filter-out $[language_egg_filters],$[egglist]]
  #if $[LANGUAGES]
    // Now look for the eggs of the current language.
    #foreach egg $[filter %_$[DEFAULT_LANGUAGE].egg,$[egglist]]
      #define wantegg $[egg:%_$[DEFAULT_LANGUAGE].egg=%_$[LANGUAGE].egg]
      #if $[filter $[wantegg],$[egglist]]
          // The current language file exists.
        #set install_unpal_eggs $[install_unpal_eggs] $[wantegg]
      #else
        #set install_unpal_eggs $[install_unpal_eggs] $[egg]
      #endif
    #end egg
  #endif
#end install_egg
#define install_eggs $[install_pal_eggs] $[install_unpal_eggs]

// Get the list of bam files in the install directories
#define install_egg_dirs $[sort $[forscopes install_egg,$[install_model_dir]]]

#define installed_generic_eggs $[sort $[forscopes install_egg,$[patsubst %.egg,$[install_model_dir]/%.egg,$[notdir $[install_egg_sources]]]]]
#define installed_generic_bams $[sort $[forscopes install_egg,$[patsubst %.egg,$[install_model_dir]/%.bam,$[filter-out $[language_egg_filters],$[notdir $[install_egg_sources]]]]]]
#if $[LANGUAGES]
  #define installed_language_bams $[sort $[forscopes install_egg,$[patsubst %.egg,$[install_model_dir]/%.bam,$[patsubst %_$[DEFAULT_LANGUAGE].egg,%.egg,%,,$[notdir $[install_egg_sources]]]]]]
#endif

// And the list of dna files in the install directories.
#define install_dna_dirs $[sort $[forscopes install_dna,$[install_model_dir]]]
#define installed_generic_dna $[sort $[forscopes install_dna,$[patsubst %,$[install_model_dir]/%,$[filter-out $[language_dna_filters],$[notdir $[SOURCES]]]]]]
#if $[LANGUAGES]
  #define installed_language_dna $[sort $[forscopes install_dna,$[patsubst %,$[install_model_dir]/%,$[patsubst %_$[DEFAULT_LANGUAGE].dna,%.dna,%,,$[notdir $[SOURCES]]]]]]
#endif

#define install_other_dirs $[sort $[forscopes install_audio install_icons install_shader install_misc,$[install_model_dir]]]
#define installed_other $[sort $[forscopes install_audio install_icons install_shader install_misc,$[SOURCES:%=$[install_model_dir]/%]]]

#define build_texs \
  $[forscopes install_tex, \
    $[foreach source,$[SOURCES],$[basename $[source]].txo]]

#define install_tex_dirs $[sort $[forscopes install_tex, $[install_tex_dir]]]
#define installed_tex $[sort $[foreach tex,$[build_texs],$[patsubst %,$[install_tex_dir]/%,$[notdir $[tex]]]]]

#define build_mats \
  $[forscopes install_mat, \
    $[foreach source,$[SOURCES],$[basename $[source]].mto]]

#define install_mat_dirs $[sort $[forscopes install_mat, $[install_mats_dir]]]
#define installed_mat $[sort $[foreach mat,$[build_mats],$[patsubst %,$[install_mats_dir]/%,$[notdir $[mat]]]]]

#define pal_egg_targets $[sort $[patsubst %,$[pal_egg_dir]/%,$[notdir $[install_pal_eggs]]]]
#define bam_targets $[install_eggs:%.egg=$[bam_dir]/%.bam]

#output Makefile
#format makefile
#### Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE].
################################# DO NOT EDIT ###########################

#define all_targets \
    Makefile \
    tex mat \
    $[texattrib_dir] \
    $[filter_dirs] \
    $[optchar_dirs] \
    egg bam
all : $[all_targets]

tex : $[build_texs]

mat : tex $[build_mats]

egg : $[build_eggs]

flt : $[build_flt_eggs]
blender : $[build_blender_eggs]
lwo : $[build_lwo_eggs]
maya : $[build_maya_eggs]
soft : $[build_soft_eggs]

pal : $[if $[pal_egg_targets],$[pal_egg_dir]] $[pal_egg_targets]

bam : mat $[if $[bam_targets],$[bam_dir]] $[bam_targets]

#map soft_scenes soft_scene_files(soft_char_egg)

unpack-soft : $[soft_scenes]

#define install_bam_targets \
    $[install_egg_dirs] \
    $[if $[INSTALL_EGG_FILES],$[installed_generic_eggs],$[installed_generic_bams] $[installed_language_bams]]
install-bam : $[install_bam_targets]

install-tex : $[install_tex_dirs] $[installed_tex]

install-mat : $[install_mat_dirs] $[installed_mat]

#define install_other_targets \
    $[install_dna_dirs] \
    $[installed_generic_dna] $[installed_language_dna] \
    $[install_other_dirs] \
    $[installed_other]
install-other : $[install_other_targets]

install : all install-other install-tex install-mat install-bam
uninstall : uninstall-other uninstall-tex uninstall-mat uninstall-bam

clean-tex :
#if $[build_texs]
  #foreach f $[build_texs]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
  #end f
#endif

clean-mat :
#if $[build_mats]
  #foreach f $[build_mats]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
  #end f
#endif

clean-bam :
#if $[bam_targets]
$[TAB]$[DEL_CMD] $[osfilename $[bam_dir]]
#endif

clean-pal : clean-bam
#if $[pal_egg_targets]
$[TAB]$[DEL_CMD] $[osfilename $[pal_egg_dir]]
#endif

clean-flt :
#if $[build_flt_eggs]
  #foreach f $[build_flt_eggs]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
  #end f
#endif

clean-blender :
#if $[build_blender_eggs]
  #foreach f $[build_blender_eggs]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
  #end f
#endif

clean-lwo :
#if $[build_lwo_eggs]
  #foreach f $[build_lwo_eggs]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
  #end f
#endif

clean-maya :
#if $[build_maya_eggs]
  #foreach f $[build_maya_eggs]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
  #end f
#endif

clean-soft :
#if $[build_soft_eggs]
  #foreach f $[build_soft_eggs]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
  #end f
#endif

clean-optchar :
#if $[optchar_dirs]
$[TAB]$[DEL_CMD] $[osfilename $[optchar_dirs]]
#endif

clean : clean-pal
#if $[build_eggs]
  #foreach egg $[build_eggs]
$[TAB]$[DEL_CMD] $[osfilename $[egg]]
  #end egg
$[TAB]$[DEL_CMD] *.pt
#endif
#if $[filter_dirs]
$[TAB]$[DEL_CMD] $[osfilename $[filter_dirs]]
#endif

// We need a rule for each directory we might need to make.  This
// loops through the full set of directories and creates a rule to
// make each one, as needed.
#foreach directory $[sort \
    $[filter_dirs] \
    $[if $[pal_egg_targets],$[pal_egg_dir]] \
    $[if $[bam_targets],$[bam_dir]] \
    $[TARGET_DIR(filter_char_egg)] \
    $[texattrib_dir] \
    $[install_egg_dirs] \
    $[install_dna_dirs] \
    $[install_other_dirs] \
    $[install_tex_dirs] \
    $[install_mat_dirs] \
    ]
$[directory] :
#if $[eq $[BUILD_TYPE], nmake]
$[TAB]if not exist $[osfilename $[directory]] mkdir $[osfilename $[directory]]
#else
$[TAB]@test -d $[directory] || echo mkdir -p $[directory]
$[TAB]@test -d $[directory] || mkdir -p $[directory]
#endif

// Sometimes we need a target to depend on the directory existing, without
// being fooled by the directory's modification times.  We use this
// phony timestamp file to achieve that.
$[directory]/stamp :
#if $[eq $[BUILD_TYPE], nmake]
$[TAB]if not exist $[osfilename $[directory]] mkdir $[osfilename $[directory]]
$[TAB]$[TOUCH_CMD] $[osfilename $[directory]/stamp]
#else
$[TAB]@test -d $[directory] || echo mkdir -p $[directory]
$[TAB]@test -d $[directory] || mkdir -p $[directory]
$[TAB]$[TOUCH_CMD] $[directory]/stamp
#endif

#end directory

// Decompressing compressed files.
#forscopes gz
  #foreach gz $[SOURCES]
    #define target $[gz:%.gz=%]
    #define source $[gz]
$[target] : $[source]
$[TAB]$[DEL_CMD] $[osfilename $[target]]
$[TAB]gunzip $[GUNZIP_OPTS] < $[source] > $[target]

  #end gz
#end gz

// TXO file generation from ptex files.
#forscopes install_tex
  #foreach img $[SOURCES]
    #define source $[img]
    #define target $[basename $[source]].txo
// Don't depend on the source.  It has multiple dependencies that we can't
// determine from ppremake, such as the image files.  ptex2txo will figure
// that out for us.
$[target] :
$[TAB]ptex2txo -o $[target] $[source]
  #end img

#end install_tex

// MTO file generation from pmat files.
#forscopes install_mat
  #foreach mat $[SOURCES]
    #define source $[mat]
    #define target $[basename $[source]].mto
$[target] : $[source]
$[TAB]pmat2mto -o $[target] $[source] -i $[TOPDIR]/$[PACKAGE]_index.boo
  #end mat

#end install_mat

// Egg file generation from Flt files.
#forscopes flt_egg
  #foreach flt $[SOURCES]
    #define target $[or $[TARGET],$[patsubst %.flt %.FLT,$[EGG_PREFIX]%$[EGG_SUFFIX].egg,$[flt]]]
    #define source $[flt]
$[target] : $[source]
$[TAB]flt2egg $[FLT2EGG_OPTS] -o $[target] $[source]

  #end flt
#end flt_egg

// Egg file generation from Lightwave files.
#forscopes lwo_egg
  #foreach lwo $[SOURCES]
    #define target $[or $[TARGET],$[patsubst %.lwo %.LWO,$[EGG_PREFIX]%$[EGG_SUFFIX].egg,$[lwo]]]
    #define source $[lwo]
$[target] : $[source]
$[TAB]lwo2egg $[LWO2EGG_OPTS] -o $[target] $[source]

  #end lwo
#end lwo_egg

// Egg file generation from Blender files (for unanimated models).
#forscopes blender_egg
  #foreach blend $[SOURCES]
    #define target $[or $[TARGET],$[patsubst %$[MODEL].blend,$[EGG_PREFIX]%$[EGG_SUFFIX].egg,$[blend]]]
    #define source $[blend]
$[target] : $[source]
$[TAB]blend2egg.py $[BLEND2EGG_OPTS] $[source] $[target]

  #end blend
#end blender_egg

// Egg character model generation from Blender files.
#forscopes blender_char_egg
  #if $[POLY_MODEL]
    #define target $[EGG_PREFIX]$[POLY_MODEL].egg
    #define source $[BLENDER_PREFIX]$[or $[MODEL],$[POLY_MODEL]].blend
$[target] : $[source]
$[TAB]blend2egg.py $[BLEND2EGG_OPTS] --ac model --cn "$[CHAR_NAME]" $[source] $[target]
  #elif $[not $[or $[MODEL], $[POLY_MODEL], $[ANIMS]]]
    #define target $[EGG_PREFIX].egg
    #define source $[BLENDER_PREFIX].blend
$[target] : $[source]
$[TAB]blend2egg.py $[BLEND2EGG_OPTS] --ac model --cn "$[CHAR_NAME]" $[source] $[target]
  #endif

#end blender_char_egg

// Egg animation generation from Blender files.
#forscopes blender_char_egg
  #define anim_dir_prefix $[if $[ANIMS_DIR],$[ANIMS_DIR]/,]
  #foreach anim $[ANIMS]
    #define target $[anim_dir_prefix]$[EGG_PREFIX]$[anim]$[CHAN_SUFFIX].egg
    #define source $[anim_dir_prefix]$[BLENDER_PREFIX]$[anim].blend
    #define begin
    #define end
    #define fps
    #if $[$[CHAR_NAME]_$[anim]_frames]
      #set begin $[word 1,$[$[CHAR_NAME]_$[anim]_frames]]
      #set end $[word 2,$[$[CHAR_NAME]_$[anim]_frames]]
      #set fps $[word 3,$[$[CHAR_NAME]_$[anim]_frames]]
    #elif $[$[anim]_frames]
      #set begin $[word 1,$[$[anim]_frames]]
      #set end $[word 2,$[$[anim]_frames]]
      #set fps $[word 3,$[$[anim]_frames]]
    #endif
$[target] : $[source]
$[TAB]blend2egg.py $[BLEND2EGG_OPTS] --ac chan --cn "$[CHAR_NAME]" $[if $[begin],--sf $[begin]] $[if $[end],--ef $[end]] $[if $[fps],--fps $[fps]] $[source] $[target]
  #end anim
#end blender_char_egg

// Egg file generation from Maya files (for unanimated models).
#forscopes maya_egg
  #foreach maya $[SOURCES]
    #define target $[or $[TARGET],$[patsubst %$[MODEL].ma %$[MODEL].mb,$[EGG_PREFIX]%$[EGG_SUFFIX].egg,$[maya]]]
    #define source $[maya]
$[target] : $[source]
$[TAB]$[MAYA2EGG] $[MAYA2EGG_OPTS] -o $[target] $[source]

  #end maya
#end maya_egg

// Egg character model generation from Maya files.
#forscopes maya_char_egg
  #if $[POLY_MODEL]
    #define target $[EGG_PREFIX]$[POLY_MODEL].egg
    #define source $[MAYA_PREFIX]$[or $[MODEL],$[POLY_MODEL]]$[MAYA_EXTENSION]
$[target] : $[source]
$[TAB]$[MAYA2EGG] $[MAYA2EGG_OPTS] -p -a model -cn "$[CHAR_NAME]" -o $[target] $[source]
  #elif $[NURBS_MODEL]
    #define target $[EGG_PREFIX]$[NURBS_MODEL].egg
    #define source $[MAYA_PREFIX]$[or $[MODEL],$[NURBS_MODEL]]$[MAYA_EXTENSION]
$[target] : $[source]
$[TAB]$[MAYA2EGG] $[MAYA2EGG_OPTS] -a model -cn "$[CHAR_NAME]" -o $[target] $[source]
  #elif $[not $[or $[MODEL], $[POLY_MODEL], $[ANIMS]]]
    #define target $[EGG_PREFIX].egg
    #define source $[MAYA_PREFIX]$[MAYA_EXTENSION]
$[target] : $[source]
$[TAB]$[MAYA2EGG] $[MAYA2EGG_OPTS] -p -a model -cn "$[CHAR_NAME]" -o $[target] $[source]
  #endif

#end maya_char_egg

// Egg animation generation from Maya files.
#forscopes maya_char_egg
  #foreach anim $[ANIMS]
    #define target $[EGG_PREFIX]$[anim]$[CHAN_SUFFIX].egg
    #define source $[MAYA_PREFIX]$[anim]$[MAYA_EXTENSION]
    #define begin 0
    #define end
    #if $[$[CHAR_NAME]_$[anim]_frames]
      #set begin $[word 1,$[$[CHAR_NAME]_$[anim]_frames]]
      #set end $[word 2,$[$[CHAR_NAME]_$[anim]_frames]]
    #elif $[$[anim]_frames]
      #set begin $[word 1,$[$[anim]_frames]]
      #set end $[word 2,$[$[anim]_frames]]
    #endif
$[target] : $[source]
$[TAB]$[MAYA2EGG] $[MAYA2EGG_OPTS] -a chan -cn "$[CHAR_NAME]" -o $[target] -sf $[begin] $[if $[end],-ef $[end]] $[source]
  #end anim
#end maya_char_egg

// Unpack the Soft scene database from its multifile.
#formap scene_file soft_scenes
  #define target $[scene_file]
  #define source $[scene_file:$[DATABASE]/SCENES/%.1-0.dsc=$[DATABASE]/%.mf]
$[target] : $[source]
$[TAB]multify xf $[source] -C $[DATABASE]
#end scene_file

// Egg character model generation from Soft databases.
#forscopes soft_char_egg
  #if $[POLY_MODEL]
    #define target $[EGG_PREFIX]$[POLY_MODEL].egg
    #define scene $[SCENE_PREFIX]$[MODEL].1-0.dsc
    #define source $[DATABASE]/SCENES/$[scene]
$[target] : $[source]
$[TAB]$[SOFT2EGG] $[SOFT2EGG_OPTS] $[if $[SOFTIMAGE_RSRC],-r "$[osfilename $[SOFTIMAGE_RSRC]]"] -p -M $[target] -N $[CHAR_NAME] -d $[DATABASE] -t $[DATABASE]/PICTURES -s $[scene]
  #endif
  #if $[NURBS_MODEL]
    #define target $[EGG_PREFIX]$[NURBS_MODEL].egg
    #define scene $[SCENE_PREFIX]$[MODEL].1-0.dsc
    #define source $[DATABASE]/SCENES/$[scene]
$[target] : $[source]
$[TAB]$[SOFT2EGG] $[SOFT2EGG_OPTS] $[if $[SOFTIMAGE_RSRC],-r "$[osfilename $[SOFTIMAGE_RSRC]]"] -n -M $[target] -N $[CHAR_NAME] -d $[DATABASE] -t $[DATABASE]/PICTURES -s $[scene]
  #endif

#end soft_char_egg

// Egg animation generation from Soft database.
#forscopes soft_char_egg
  #foreach anim $[ANIMS]
    #define target $[EGG_PREFIX]$[anim]$[CHAN_SUFFIX].egg
    #define scene $[SCENE_PREFIX]$[anim].1-0.dsc
    #define source $[DATABASE]/SCENES/$[scene]
    #define begin 1
    #define end
    #if $[$[anim]_frames]
      #set begin $[word 1,$[$[anim]_frames]]
      #set end $[word 2,$[$[anim]_frames]]
    #endif
$[target] : $[source]
$[TAB]$[SOFT2EGG] $[SOFT2EGG_OPTS] $[if $[SOFTIMAGE_RSRC],-r "$[osfilename $[SOFTIMAGE_RSRC]]"] -a -A $[target] -N $[CHAR_NAME] -d $[DATABASE] -s $[scene] $[begin:%=-b%] $[end:%=-e%]
  #end anim
#end soft_char_egg

// Copying egg files from A to B.
#forscopes copy_egg
  #for i 1,$[words $[SOURCES]]
    #define source $[word $[i],$[SOURCES]]
    #define target $[word $[i],$[TARGETS]]
$[target] : $[source]
$[TAB]$[COPY_CMD] $[osfilename $[source]] $[osfilename $[target]]
  #end i
#end copy_egg


// Generic egg filters.
#forscopes filter_egg
  #foreach egg $[SOURCES]
    #define source $[source_prefix]$[egg]
    #define target $[TARGET_DIR]/$[notdir $[egg]]
$[target] : $[source] $[pt] $[TARGET_DIR]/stamp
$[TAB]$[COMMAND]
  #end egg
#end filter_egg

// Generic character egg filter; applies an effect to all models and
// animations of a particular character.
#forscopes filter_char_egg
  #define sources $[SOURCES:%=$[source_prefix]%]
  #define target $[TARGET_DIR]/$[notdir $[firstword $[SOURCES]]]

   // A bunch of rules to make each generated egg file depend on the
   // first one.
  #foreach egg $[notdir $[wordlist 2,9999,$[SOURCES]]]
$[TARGET_DIR]/$[egg] : $[target] $[TARGET_DIR]/stamp
$[TAB]$[TOUCH_CMD] $[osfilename $[TARGET_DIR]/$[egg]]
  #end egg

   // And this is the actual filter pass.
$[target] : $[sources] $[TARGET_DIR]/stamp
  // Write each source filename to a temporary file that will be read by the
  // egg program.  This is done to support long commands.
  #define sources_file eoc.tmp
$[TAB] $[DEL_CMD] $[osfilename $[sources_file]]
  #foreach file $[sources]
$[TAB]echo $[file]>> $[sources_file]
  #end file
$[TAB]$[COMMAND] -inf $[sources_file]
$[TAB]$[DEL_CMD] $[sources_file]
#end filter_char_egg


// Character optimization.
#forscopes optchar_egg
#if $[LIMIT_OPTCHAR]
  // With LIMIT_OPTCHAR enabled, we only want to make local optchar
  // operations, allowing one operation at a time.
  #foreach egg $[SOURCES]
    #define source $[source_prefix]$[egg]
    #define target $[TARGET_DIR]/$[notdir $[egg]]
$[target] : $[source] $[TARGET_DIR]/stamp
$[TAB]egg-optchar -keepall $[OPTCHAR_OPTS] -d $[TARGET_DIR] $[source]
  #end egg

#else
  // In the normal mode, we allow global optchar operations, requiring
  // all egg files to be processed in a single pass.
  #define sources $[SOURCES:%=$[source_prefix]%]
  #define target $[TARGET_DIR]/$[notdir $[firstword $[SOURCES]]]

   // A bunch of rules to make each generated egg file depend on the
   // first one.
  #foreach egg $[notdir $[wordlist 2,9999,$[SOURCES]]]
$[TARGET_DIR]/$[egg] : $[target] $[TARGET_DIR]/stamp
$[TAB]$[TOUCH_CMD] $[osfilename $[TARGET_DIR]/$[egg]]
  #end egg

   // And this is the actual optchar pass.
$[target] : $[sources] $[TARGET_DIR]/stamp
////////////////////////////////
//$[TAB]egg-optchar $[OPTCHAR_OPTS] -d $[TARGET_DIR] $[sources]
///// Handles very long lists of egg files by echoing them //////
///// out to a file then having egg-optchar read in the    //////
///// list from that file.  Comment out four lines below   //////
///// and uncomment line above to revert to the old way.   //////
  #define sources_file eoc.tmp
$[TAB] $[DEL_CMD] $[sources_file]
  #foreach file $[sources]
$[TAB]echo $[file]>> $[sources_file]
  #end file
$[TAB]egg-optchar $[OPTCHAR_OPTS] -d $[TARGET_DIR] -inf $[sources_file]
$[TAB]$[DEL_CMD] $[sources_file]
////////////////////////////////
#endif

#end optchar_egg

// Palettization rules.
#forscopes install_egg
  #foreach egg $[SOURCES]
    #define pt $[egg:%.egg=$[source_prefix]%.pt]
    #define source $[source_prefix]$[egg]
    #define target $[pal_egg_dir]/$[notdir $[egg]]
$[target] : $[source] $[pt] $[pal_egg_dir]/stamp
    #if $[PHASE]
$[TAB]egg-palettize $[PALETTIZE_OPTS] -af $[texattrib_file] -dr $[install_dir] -dm $[install_dir]/%g/maps -ds $[install_dir]/shadow_pal -g phase_$[PHASE] -gdir phase_$[PHASE] -o $[target] $[source]
    #else
$[TAB]egg-palettize $[PALETTIZE_OPTS] -af $[texattrib_file] -dr $[install_dir] -dm $[install_dir]/%g/maps -ds $[install_dir]/shadow_pal -o $[target] $[source]
    #endif

$[pt] :
$[TAB]$[TOUCH_CMD] $[pt]

  #end egg
#end install_egg

// Bam file creation.
#forscopes install_egg
  #foreach egg $[SOURCES]
    #define source $[pal_egg_dir]/$[notdir $[egg]]
    #define target $[bam_dir]/$[notdir $[egg:%.egg=%.bam]]
$[target] : $[source] $[bam_dir]/stamp
$[TAB]egg2bam -pp $[install_dir] -ps rel -pd $[install_dir] -i $[TOPDIR]/$[PACKAGE]_index.boo $[EGG2BAM_OPTS] -o $[target] $[source]
  #end egg

  #foreach egg $[SOURCES_NC]
    #define source $[pal_egg_dir]/$[notdir $[egg]]
    #define target $[bam_dir]/$[notdir $[egg:%.egg=%.bam]]
$[target] : $[source] $[bam_dir]/stamp
$[TAB]egg2bam -pp $[install_dir] -ps rel -pd $[install_dir] -i $[TOPDIR]/$[PACKAGE]_index.boo -NC $[EGG2BAM_OPTS] -o $[target] $[source]
  #end egg

  #foreach egg $[UNPAL_SOURCES]
    #define source $[source_prefix]$[egg]
    #define target $[bam_dir]/$[notdir $[egg:%.egg=%.bam]]
$[target] : $[source] $[bam_dir]/stamp
$[TAB]egg2bam -i $[TOPDIR]/$[PACKAGE]_index.boo $[EGG2BAM_OPTS] -o $[target] $[source]
  #end egg

  #foreach egg $[UNPAL_SOURCES_NC]
    #define source $[source_prefix]$[egg]
    #define target $[bam_dir]/$[notdir $[egg:%.egg=%.bam]]
$[target] : $[source] $[bam_dir]/stamp
$[TAB]egg2bam -i $[TOPDIR]/$[PACKAGE]_index.boo $[EGG2BAM_OPTS] -NC -o $[target] $[source]
  #end egg
#end install_egg

// Bam file installation.
#forscopes install_egg
  #define egglist $[notdir $[install_egg_sources]]
  #foreach egg $[filter-out $[language_egg_filters],$[egglist]]
    #define local $[egg:%.egg=%.bam]
    #define sourcedir $[bam_dir]
    #define dest $[install_model_dir]

    #adddict model_index $[ABSDIR]/$[source_prefix]$[egg],$[dest]/$[local]

$[dest]/$[local] : $[sourcedir]/$[local]
$[TAB]$[DEL_CMD] $[osfilename $[dest]/$[local]]
$[TAB]$[COPY_CMD] $[osfilename $[sourcedir]/$[local]] $[osfilename $[dest]]

  #end egg
  #if $[LANGUAGES]
    // Now look for the eggs of the current language.
    #foreach egg $[filter %_$[DEFAULT_LANGUAGE].egg,$[egglist]]
      #define wantegg $[egg:%_$[DEFAULT_LANGUAGE].egg=%_$[LANGUAGE].egg]
      #if $[filter $[wantegg],$[egglist]]
        // The current language file exists.
        #define local $[wantegg:%.egg=%.bam]
      #else
        //#print Warning: $[wantegg] not listed, using $[egg]
        #define local $[egg:%.egg=%.bam]
      #endif
      #define remote $[egg:%_$[DEFAULT_LANGUAGE].egg=%.bam]
      #define sourcedir $[bam_dir]
      #define dest $[install_model_dir]
      #adddict model_index $[ABSDIR]/$[sourcedir]/$[local],$[dest]/$[remote]
$[dest]/$[remote] : $[sourcedir]/$[local]
//      cd ./$[sourcedir] && $[INSTALL]
$[TAB]$[DEL_CMD] $[osfilename $[dest]/$[remote]]
$[TAB]$[COPY_CMD] $[osfilename $[sourcedir]/$[local]] $[osfilename $[dest]/$[remote]]

    #end egg
  #endif
#end install_egg

// Bam file uninstallation.
uninstall-bam :
#forscopes install_egg
  #define egglist $[notdir $[install_egg_sources]]
  #define generic_egglist $[filter-out $[language_egg_filters],$[egglist]]
  #if $[LANGUAGES]
    #define language_egglist $[patsubst %_$[DEFAULT_LANGUAGE].egg,%.egg,%,,$[egglist]]
  #endif
  #define files $[patsubst %.egg,$[install_model_dir]/%.bam,$[generic_egglist] $[language_egglist]]
  #if $[files]
    #foreach file $[files]
$[TAB]$[DEL_CMD] $[osfilename $[file]]
    #end file
  #endif
#end install_egg


// DNA file installation.
#forscopes install_dna
  #foreach file $[filter-out $[language_dna_filters],$[SOURCES]]
    #define local $[file]
    #define remote $[notdir $[file]]
    #define dest $[install_model_dir]
    #adddict dna_index $[ABSDIR]/$[local],$[dest]/$[remote]
$[dest]/$[remote] : $[local]
//      $[INSTALL]
$[TAB]$[DEL_CMD] $[osfilename $[dest]/$[remote]]
$[TAB]$[COPY_CMD] $[osfilename $[local]] $[osfilename $[dest]]

  #end file
  #if $[LANGUAGES]
    // Now files of the current langauge.
    #foreach file $[filter %_$[DEFAULT_LANGUAGE].dna,$[SOURCES]]
      #define wantfile $[file:%_$[DEFAULT_LANGUAGE].dna=%_$[LANGUAGE].dna]
      #if $[filter $[wantfile],$[SOURCES]]
        // The current language file exists.
        #define local $[wantfile]
      #else
        //#print Warning: $[wantfile] not listed, using $[file]
        #define local $[file]
      #endif
      #define remote $[notdir $[file:%_$[DEFAULT_LANGUAGE].dna=%.dna]]
      #define dest $[install_model_dir]
      #adddict dna_index $[ABSDIR]/$[local],$[dest]/$[remote]
$[dest]/$[remote] : $[local]
$[TAB]$[DEL_CMD] $[osfilename $[dest]/$[remote]]
$[TAB]$[COPY_CMD] $[osfilename $[local]] $[osfilename $[dest]/$[remote]]

    #end file
  #endif
#end install_dna

// DNA file uninstallation.
uninstall-other:
#forscopes install_dna
  #define sources $[notdir $[SOURCES]]
  #define generic_sources $[filter-out $[language_dna_filters],$[sources]]
  #if $[LANGUAGES]
    #define language_sources $[patsubst %_$[DEFAULT_LANGUAGE].dna,%.dna,%,,$[sources]]
  #endif
  #define files $[patsubst %,$[install_model_dir]/%,$[generic_sources] $[language_sources]]
  #if $[files]
    #foreach f $[files]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
    #end f
  #endif
#end install_dna

// TXO file installation.
#forscopes install_tex
  #foreach file $[SOURCES]
    #define local $[basename $[file]].txo
    #define remote $[notdir $[local]]
    #define dest $[install_tex_dir]
    #adddict texture_index $[ABSDIR]/$[file],$[dest]/$[remote]
$[dest]/$[remote] : $[local]
$[TAB]$[DEL_CMD] $[osfilename $[dest]/$[remote]]
$[TAB]$[COPY_CMD] $[osfilename $[local]] $[osfilename $[dest]]
  #end file
#end install_tex

// TXO file uninstallation.
uninstall-tex :
#forscopes install_tex
  #define files \
    $[foreach img,$[SOURCES],$[install_tex_dir]/$[notdir $[basename $[img]].txo]]
  #if $[files]
    #foreach f $[files]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
    #end f
  #endif

#end install_tex

// MTO file installation.
#forscopes install_mat
  #foreach file $[SOURCES]
    #define local $[basename $[file]].mto
    #define remote $[notdir $[local]]
    #define dest $[install_mats_dir]
    #adddict material_index $[ABSDIR]/$[file],$[dest]/$[remote]
$[dest]/$[remote] : $[local]
$[TAB]$[DEL_CMD] $[osfilename $[dest]/$[remote]]
$[TAB]$[COPY_CMD] $[osfilename $[local]] $[osfilename $[dest]]
  #end file
#end install_mat

// MTO file uninstallation.
uninstall-mat :
#forscopes install_mat
  #define files \
    $[foreach mat,$[SOURCES],$[install_mats_dir]/$[notdir $[basename $[mat]].mto]]
  #if $[files]
    #foreach f $[files]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
    #end f
  #endif

#end install_mat

// Miscellaneous file installation.
#forscopes install_audio install_icons install_shader install_misc
  #define dest $[install_model_dir]
  #foreach file $[SOURCES]
    #define local $[file]
    #define remote $[notdir $[file]]
    #adddict misc_index $[ABSDIR]/$[local],$[dest]/$[remote]
$[dest]/$[remote] : $[local]
//      $[INSTALL]
$[TAB]$[DEL_CMD] $[osfilename $[dest]/$[remote]]
$[TAB]$[COPY_CMD] $[osfilename $[local]] $[osfilename $[dest]]

  #end file
#end install_audio install_icons install_shader install_misc

// Miscellaneous file uninstallation.
uninstall-other :
#forscopes install_audio install_icons install_shader install_misc
  #define dest $[install_model_dir]
  #define files $[patsubst %,$[dest]/%,$[SOURCES]]
  #if $[files]
    #foreach f $[files]
$[TAB]$[DEL_CMD] $[osfilename $[f]]
    #end f
  #endif
#end install_audio install_icons install_shader install_misc

// Finally, the rules to freshen the Makefile itself.
Makefile : $[SOURCE_FILENAME] $[EXTRA_PPREMAKE_SOURCE]
$[TAB] ppremake

#end Makefile


//////////////////////////////////////////////////////////////////////
#elif $[eq $[DIR_TYPE], models_group]
//////////////////////////////////////////////////////////////////////

// This is a group directory: a directory above a collection of source
// directories, e.g. $DTOOL/src.  We don't need to output anything in
// this directory.



//////////////////////////////////////////////////////////////////////
#elif $[eq $[DIR_TYPE], models_toplevel]
//////////////////////////////////////////////////////////////////////

// This is the toplevel directory for a models tree, e.g. $TTMODELS.
// Here we build the root makefile.

#map subdirs
// Iterate through all of our known source files.  Each models type
// file gets its corresponding Makefile listed here.
#forscopes */
  #if $[eq $[DIR_TYPE], models]
    #if $[build_directory]
      #addmap subdirs $[DIRNAME]
    #endif
  #endif
#end */

#output Makefile
#format makefile
#### Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[SOURCEFILE].
################################# DO NOT EDIT ###########################

all : Makefile $[PACKAGE]_index.boo tex mat egg pal repal $[subdirs]
install : all $[subdirs:%=install-%]
#define sub_targets \
  tex mat egg flt lwo maya soft blender bam pal clean-tex clean-mat clean-bam \
  clean-pal clean-flt clean-lwo clean-maya clean-soft clean-blender clean-optchar clean \
  cleanall unpack-soft install-tex install-mat install-bam install-other uninstall-tex \
  uninstall-mat uninstall-bam uninstall-other uninstall

// Define the rules to propogate these targets to the Makefile within
// each directory.
#foreach target $[sub_targets]
$[target] : $[subdirs:%=$[target]-%]
#end target
#
# opt-pal : reorder and resize the palettes to be as optimal as
# possible.  This forces a rebuild of all the egg files.
#
opt-pal : pal do-opt-pal install
optimize-palettes : opt-pal
do-opt-pal :
$[TAB]egg-palettize $[PALETTIZE_OPTS] -af $[texattrib_file] -dm $[install_dir]/%g/maps -opt -egg
#
# repal : reexamine the textures.txa file and do whatever needs to be
# done to bring everything up to sync with it.  Also make sure all egg
# files are up-to-date.
#
repal :
$[TAB]egg-palettize $[PALETTIZE_OPTS] -af $[texattrib_file] -dm $[install_dir]/%g/maps -all -egg
re-pal : repal
#
# fix-pal : something has gone wrong with the palettes; rebuild all
# palette images to fix it.
#
fix-pal :
$[TAB]egg-palettize $[PALETTIZE_OPTS] -af $[texattrib_file] -dm $[install_dir]/%g/maps -redo -all -egg
#
# undo-pal : blow away all the palettization information and start fresh.
#
undo-pal : clean-pal
#if $[eq $[BUILD_TYPE], nmake]
$[TAB]$[DEL_CMD] $[osfilename $[texattrib_file:%.txa=%.boo]]
#else
$[TAB]$[DEL_CMD] $[texattrib_file:%.txa=%.boo]
#endif
#
# pi : report the palettization information to standard output for the
# user's perusal.
#
pi :
$[TAB]egg-palettize $[PALETTIZE_OPTS] -af $[texattrib_file] -dm $[install_dir]/%g/maps -pi

.PHONY: pi.txt
pi.txt :
$[TAB]egg-palettize $[PALETTIZE_OPTS] -af $[texattrib_file] -dm $[install_dir]/%g/maps -pi >pi.txt

#
# pal-stats : report palettization statistics to standard output for the
# user's perusal.
#
pal-stats :
$[TAB]egg-palettize $[PALETTIZE_OPTS] -af $[texattrib_file] -dm $[install_dir]/%g/maps -s
stats-pal : pal-stats

// Somehow, something in the cttools confuses some shells, so that
// when we are attached, 'cd foo' doesn't work, but 'cd ./foo' does.
// Weird.  We get around this by putting a ./ in front of each cd
// target below.
#formap dirname subdirs
$[dirname] : $[dirnames $[if $[build_directory],$[DIRNAME]],$[DEPEND_DIRS]]
$[TAB]cd ./$[RELDIR] && $(MAKE) all
#end dirname
// Define the rules to propogate these targets to the Makefile within
// each directory.
#foreach target install $[sub_targets]
  #formap dirname subdirs
$[target]-$[dirname] :
$[TAB]cd ./$[RELDIR] && $(MAKE) $[target]
  #end dirname
#end target

// Define a rule that compiles the index file into a binary format so it is
// quick for the tools to load up.
$[PACKAGE]_index.boo : $[PACKAGE]_index
$[TAB] modindex2boo -o $[PACKAGE]_index.boo $[PACKAGE]_index

// Finally, the rules to freshen the Makefile itself.
Makefile : $[SOURCE_FILENAME] $[EXTRA_PPREMAKE_SOURCE]
$[TAB] ppremake

#end Makefile

//////////////////////////////////////////////////////////////////////
#endif // DIR_TYPE
