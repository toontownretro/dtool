#define LOCAL_LIBS p3dtoolutil p3dtoolbase
#define USE_PACKAGES openssl

#begin lib_target
  #define TARGET p3prc

  #define BUILDING_DLL BUILDING_DTOOL_PRC

  #define ANDROID_SYS_LIBS log

  #define SOURCES \
    androidLogStream.h \
    bigEndian.h \
    config_prc.h \
    configDeclaration.I configDeclaration.h \
    configFlags.I configFlags.h \
    configPage.I configPage.h \
    configPageManager.I configPageManager.h \
    configVariable.I configVariable.h \
    configVariableBase.I configVariableBase.h \
    configVariableBool.I configVariableBool.h \
    configVariableCore.I configVariableCore.h \
    configVariableDouble.I configVariableDouble.h \
    configVariableEnum.I configVariableEnum.h \
    configVariableFilename.I configVariableFilename.h \
    configVariableInt.I configVariableInt.h \
    configVariableInt64.I configVariableInt64.h \
    configVariableList.I configVariableList.h \
    configVariableManager.I configVariableManager.h \
    configVariableSearchPath.I configVariableSearchPath.h \
    configVariableString.I configVariableString.h \
    encryptStreamBuf.h encryptStreamBuf.I encryptStream.h encryptStream.I \
    littleEndian.h \
    nativeNumericData.I nativeNumericData.h \
    pnotify.I pnotify.h \
    notifyCategory.I notifyCategory.h \
    notifyCategoryProxy.I notifyCategoryProxy.h \
    notifySeverity.h \
    prcKeyRegistry.h prcKeyRegistry.I \
    reversedNumericData.I reversedNumericData.h \
    streamReader.I streamReader.h \
    streamWrapper.I streamWrapper.h \
    streamWriter.I streamWriter.h \
    prc_parameters.h // generated file

  #define COMPOSITE_SOURCES \
    $[if $[eq $[PLATFORM], Android], androidLogStream.cxx] \
    config_prc.cxx \
    configDeclaration.cxx \
    configFlags.cxx \
    configPage.cxx \
    configPageManager.cxx \
    configVariable.cxx \
    configVariableBase.cxx \
    configVariableBool.cxx \
    configVariableCore.cxx \
    configVariableDouble.cxx \
    configVariableEnum.cxx \
    configVariableFilename.cxx \
    configVariableInt.cxx \
    configVariableInt64.cxx \
    configVariableList.cxx \
    configVariableManager.cxx \
    configVariableSearchPath.cxx \
    configVariableString.cxx \
    $[if $[HAVE_OPENSSL], encryptStreamBuf.cxx encryptStream.cxx] \
    nativeNumericData.cxx \
    notify.cxx \
    notifyCategory.cxx \
    notifySeverity.cxx \
    prcKeyRegistry.cxx \
    reversedNumericData.cxx \
    streamReader.cxx streamWrapper.cxx streamWriter.cxx

  #define INSTALL_HEADERS \
    androidLogStream.h \
    bigEndian.h \
    config_prc.h \
    configDeclaration.I configDeclaration.h \
    configFlags.I configFlags.h \
    configPage.I configPage.h \
    configPageManager.I configPageManager.h \
    configVariable.I configVariable.h \
    configVariableBase.I configVariableBase.h \
    configVariableBool.I configVariableBool.h \
    configVariableCore.I configVariableCore.h \
    configVariableDouble.I configVariableDouble.h \
    configVariableEnum.I configVariableEnum.h \
    configVariableFilename.I configVariableFilename.h \
    configVariableInt.I configVariableInt.h \
    configVariableInt64.I configVariableInt64.h \
    configVariableList.I configVariableList.h \
    configVariableManager.I configVariableManager.h \
    configVariableSearchPath.I configVariableSearchPath.h \
    configVariableString.I configVariableString.h \
    encryptStreamBuf.h encryptStreamBuf.I encryptStream.h encryptStream.I \
    littleEndian.h \
    nativeNumericData.I nativeNumericData.h \
    pnotify.I pnotify.h \
    notifyCategory.I notifyCategory.h \
    notifyCategoryProxy.I notifyCategoryProxy.h \
    notifySeverity.h \
    prcKeyRegistry.I prcKeyRegistry.h \
    reversedNumericData.I reversedNumericData.h \
    streamReader.I streamReader.h \
    streamWrapper.I streamWrapper.h \
    streamWriter.I streamWriter.h

  #define IGATESCAN all

  #define IGATEEXT \
    streamReader_ext.cxx \
    streamReader_ext.h \
    streamWriter_ext.cxx \
    streamWriter_ext.h

#end lib_target

#include $[THISDIRPREFIX]prc_parameters.h.pp
