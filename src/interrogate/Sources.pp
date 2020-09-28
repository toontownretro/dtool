#define BUILD_DIRECTORY $[HAVE_INTERROGATE]

#define LOCAL_LIBS p3cppParser p3interrogatedb
#define USE_PACKAGES openssl

#begin bin_target
  #define TARGET interrogate

  #define SOURCES \
     functionRemap.h \
     functionWriter.h \
     functionWriterPtrFromPython.h functionWriterPtrToPython.h \
     functionWriters.h \
     interfaceMaker.h \
     interfaceMakerC.h \
     interfaceMakerPython.h interfaceMakerPythonObj.h \
     interfaceMakerPythonSimple.h \
     interfaceMakerPythonNative.h \
     interrogate.h interrogateBuilder.h parameterRemap.I  \
     parameterRemap.h \
     parameterRemapBasicStringPtrToString.h  \
     parameterRemapBasicStringRefToString.h  \
     parameterRemapBasicStringToString.h  \
     parameterRemapCharStarToString.h  \
     parameterRemapConcreteToPointer.h  \
     parameterRemapConstToNonConst.h parameterRemapEnumToInt.h  \
     parameterRemapPTToPointer.h  \
     parameterRemapReferenceToConcrete.h  \
     parameterRemapReferenceToPointer.h parameterRemapThis.h  \
     parameterRemapToString.h \
     parameterRemapHandleToInt.h \
     parameterRemapUnchanged.h  \
     typeManager.h \
     interrogate_preamble_python_native.cxx // generated below

  #define COMPOSITE_SOURCES  \
     functionRemap.cxx \
     functionWriter.cxx \
     functionWriterPtrFromPython.cxx functionWriterPtrToPython.cxx \
     functionWriters.cxx \
     interfaceMaker.cxx \
     interfaceMakerC.cxx \
     interfaceMakerPython.cxx interfaceMakerPythonObj.cxx \
     interfaceMakerPythonSimple.cxx \
     interfaceMakerPythonNative.cxx \
     interrogate.cxx interrogateBuilder.cxx parameterRemap.cxx  \
     parameterRemapBasicStringPtrToString.cxx  \
     parameterRemapBasicStringRefToString.cxx  \
     parameterRemapBasicStringToString.cxx  \
     parameterRemapCharStarToString.cxx  \
     parameterRemapConcreteToPointer.cxx  \
     parameterRemapConstToNonConst.cxx  \
     parameterRemapEnumToInt.cxx parameterRemapPTToPointer.cxx  \
     parameterRemapReferenceToConcrete.cxx  \
     parameterRemapReferenceToPointer.cxx parameterRemapThis.cxx  \
     parameterRemapToString.cxx \
     parameterRemapHandleToInt.cxx \
     parameterRemapUnchanged.cxx  \
     typeManager.cxx

#end bin_target

#begin bin_target
  #define TARGET parse_file
  #define SOURCES parse_file.cxx
#end bin_target

#begin bin_target
  #define TARGET interrogate_module
  #define SOURCES \
    interrogate_module.cxx \
    interrogate_preamble_python_native.cxx
#end bin_target

#define INTERROGATE_PREAMBLE_PYTHON_NATIVE \
  $[PATH]/../interrogatedb/py_panda.cxx \
  $[PATH]/../interrogatedb/py_compat.cxx \
  $[PATH]/../interrogatedb/py_wrappers.cxx \
  $[PATH]/../interrogatedb/dtool_super_base.cxx

#concatcxx $[PATH]/interrogate_preamble_python_native.cxx, \
  interrogate_preamble_python_native, $[INTERROGATE_PREAMBLE_PYTHON_NATIVE]
