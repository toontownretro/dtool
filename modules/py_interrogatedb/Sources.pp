#define DIR_TYPE module

// The interrogate code is pre-generated and all we have to do is link it into
// a python module.  Thus, we use python_target instead of python_module_target.
#begin python_target
  #define TARGET panda3d.interrogatedb
  #define LOCAL_LIBS interrogatedb
  #define SOURCES pydtool.cxx
#end python_target
