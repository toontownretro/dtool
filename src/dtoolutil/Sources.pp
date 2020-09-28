#begin lib_target
  #define TARGET p3dtoolutil
  #define LOCAL_LIBS p3dtoolbase
  #if $[ne $[PLATFORM], FreeBSD]
    #define UNIX_SYS_LIBS dl
  #endif
  #define WIN_SYS_LIBS shell32.lib
  #define OSX_SYS_FRAMEWORKS Foundation $[if $[not $[BUILD_IPHONE]],AppKit]

  #define BUILDING_DLL BUILDING_DTOOL_DTOOLUTIL

  // Needed by filename and executionEnvironment
  //#define C++FLAGS \
  //  -DHAVE_GLOBAL_ARGV \
  //  -DPROTOTYPE_GLOBAL_ARGV \
  //  -DGLOBAL_ARGV \
  //  -DGLOBAL_ARGC \
  //  -DHAVE_PROC_CURPROC_CMDLINE \
  //  -DHAVE_PROC_CURPROC_FILE \
  //  -DHAVE_PROC_SELF_CMDLINE \
  //  -DHAVE_PROC_CURPROC_MAP \
  //  -DHAVE_PROC_SELF_ENVIRON \
  //  -DHAVE_PROC_SELF_EXE \
  //  -DHAVE_PROC_SELF_MAPS \
  //  -DSTATIC_INIT_GETENV \
  //  -DHAVE_IOS_BINARY \
  //  -DPHAVE_DIRENT_H \
  //  -DPHAVE_GLOB_G \
  //  -DPHAVE_LOCKF \
  //  -DPHAVE_UTIME_H

  #define SOURCES \
    config_dtoolutil.h \
    dSearchPath.I dSearchPath.h \
    executionEnvironment.I executionEnvironment.h filename.I  \
    filename.h \
    $[if $[IS_OSX],filename_assist.mm filename_assist.h,] \
    globPattern.I globPattern.h \
    lineStream.I lineStream.h \
    lineStreamBuf.I lineStreamBuf.h \
    load_dso.h \
    pandaFileStream.h pandaFileStream.I \
    pandaFileStreamBuf.h \
    pandaSystem.h \
    panda_getopt.h panda_getopt_long.h panda_getopt_impl.h \
    pfstream.h pfstream.I pfstreamBuf.h \
    preprocess_argv.h \
    string_utils.h string_utils.I \
    stringDecoder.h stringDecoder.I \
    textEncoder.h textEncoder.I \
    unicodeLatinMap.h \
    vector_double.h \
    vector_float.h \
    vector_int.h \
    vector_stdfloat.h \
    vector_string.h \
    vector_uchar.h \
    vector_src.h \
    win32ArgParser.h

  #define COMPOSITE_SOURCES \
    config_dtoolutil.cxx \
    dSearchPath.cxx \
    executionEnvironment.cxx filename.cxx \
    globPattern.cxx \
    lineStream.cxx lineStreamBuf.cxx \
    load_dso.cxx  \
    pandaFileStream.cxx pandaFileStreamBuf.cxx \
    pandaSystem.cxx \
    panda_getopt_impl.cxx \
    pfstreamBuf.cxx pfstream.cxx \
    preprocess_argv.cxx \
    string_utils.cxx \
    stringDecoder.cxx \
    textEncoder.cxx \
    unicodeLatinMap.cxx \
    vector_double.cxx \
    vector_float.cxx \
    vector_int.cxx \
    vector_string.cxx \
    vector_uchar.cxx \
    win32ArgParser.cxx

  #define INSTALL_HEADERS \
    config_dtoolutil.h \
    dSearchPath.I dSearchPath.h \
    executionEnvironment.I executionEnvironment.h filename.I \
    filename.h \
    globPattern.I globPattern.h \
    lineStream.I lineStream.h \
    lineStreamBuf.I lineStreamBuf.h \
    load_dso.h \
    pandaFileStream.h pandaFileStream.I \
    pandaFileStreamBuf.h \
    pandaSystem.h pandaVersion.h \
    panda_getopt.h panda_getopt_long.h panda_getopt_impl.h \
    pfstream.h pfstream.I pfstreamBuf.h \
    preprocess_argv.h \
    string_utils.h string_utils.I \
    stringDecoder.h stringDecoder.I \
    textEncoder.h textEncoder.I \
    unicodeLatinMap.h \
    vector_string.h \
    vector_src.cxx vector_src.h \
    win32ArgParser.h

  #define IGATESCAN all

  #define IGATEEXT \
    filename_ext.h \
    filename_ext.cxx \
    globPattern_ext.cxx \
    globPattern_ext.h \
    iostream_ext.cxx \
    iostream_ext.h \
    textEncoder_ext.cxx \
    textEncoder_ext.h

#end lib_target

#begin test_bin_target
  #define TARGET test_pfstream
  #define LOCAL_LIBS p3dtoolbase p3dtoolutil

  #define SOURCES test_pfstream.cxx
#end test_bin_target

#begin test_bin_target
  #define TARGET test_touch
  #define LOCAL_LIBS p3dtoolbase p3dtoolutil

  #define SOURCES test_touch.cxx
#end test_bin_target
