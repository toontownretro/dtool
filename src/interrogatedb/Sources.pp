#begin lib_target
  #define TARGET interrogatedb

  #define LOCAL_LIBS dconfig prc dtoolbase dtoolutil

  #define BUILDING_DLL BUILDING_INTERROGATEDB

  #define SOURCES \
    config_interrogatedb.h indexRemapper.h interrogateComponent.I  \
    interrogateComponent.h interrogateDatabase.I  \
    interrogateDatabase.h interrogateElement.I  \
    interrogateElement.h interrogateFunction.I  \
    interrogateFunction.h interrogateFunctionWrapper.I  \
    interrogateFunctionWrapper.h \
    interrogateMakeSeq.I interrogateMakeSeq.h \
    interrogateManifest.I interrogateManifest.h \
    interrogateType.I interrogateType.h  \
    interrogate_datafile.I interrogate_datafile.h  \
    interrogate_interface.h interrogate_request.h  \
    extension.h

 #define COMPOSITE_SOURCES  \
    config_interrogatedb.cxx \
    indexRemapper.cxx  \
    interrogateComponent.cxx interrogateDatabase.cxx  \
    interrogateElement.cxx interrogateFunction.cxx  \
    interrogateFunctionWrapper.cxx \
    interrogateMakeSeq.cxx  \
    interrogateManifest.cxx  \
    interrogateType.cxx interrogate_datafile.cxx  \
    interrogate_interface.cxx interrogate_request.cxx

  #define INSTALL_HEADERS \
    interrogate_interface.h interrogate_request.h \
    config_interrogatedb.h \
    py_panda.h \
    py_panda.I py_compat.h \
    py_wrappers.h \
    extension.h

#end lib_target
