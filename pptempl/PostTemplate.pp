//
// PostTemplate.pp
//
// This file is read in after all of the template scripts have been executed
// in each directory.  It can perform certain operations from the information
// gathered in the various template scripts.
//


// Only do this for a model tree.
#if $[eq $[dirnames $[DIR_TYPE], top], models_toplevel]

// Output a file that maps source files to their built versions.  This is
// helpful to tools like egg2bam that need to remap the texture pathnames to
// their installed versions.
#output $[PACKAGE]_index notouch
#format collapse
$[DOUBLESLASH] Generated automatically by $[PPREMAKE] $[PPREMAKE_VERSION] from $[DOLLAR]$[upcase $[PACKAGE]].
$[DOUBLESLASH] DO NOT EDIT
$[DOUBLESLASH]
$[DOUBLESLASH] This file defines an index into all assets in the model tree by type.  Each
$[DOUBLESLASH] asset of a given type is identified by its basename, and the asset itself
$[DOUBLESLASH] contains a mapping of the source file to the built and installed counterpart.
$[DOUBLESLASH] This can be used to look up the source or built version of any asset by name.
$[DOUBLESLASH] It is utilized by tools like the Egg loader that needs to locate materials and
$[DOUBLESLASH] textures from the name of the EggMaterial or basename of the EggTexture file.
$[DOUBLESLASH] It is also utilized by egg2bam to remap the material and/or texture pathnames
$[DOUBLESLASH] from the source versions to the built versions.
$[DOUBLESLASH]

tree $[PACKAGE]

src_dir "$[TOPDIR]/src"
install_dir "$[$[upcase $[PACKAGE]]_INSTALL]"

textures
{
#fordict key texture_index
  "$[key]"
  {
    src   "$[key]"
    built "$[texture_index $[key]]"
  }
#end key
}

materials
{
#fordict key material_index
  "$[key]"
  {
    src   "$[key]"
    built "$[material_index $[key]]"
  }
#end key
}

models
{
#fordict key model_index
  "$[basename $[notdir $[key]]]"
  {
    src   "$[key]"
    built "$[model_index $[key]]"
  }
#end key
}

dna
{
#fordict key dna_index
  "$[basename $[notdir $[key]]]"
  {
    src   "$[key]"
    built "$[dna_index $[key]]"
  }
#end key
}

misc
{
#fordict key misc_index
  "$[basename $[notdir $[key]]]"
  {
    src   "$[key]"
    built "$[misc_index $[key]]"
  }
#end key
}
#end $[PACKAGE]_index

#endif
