#define BUILD_DIRECTORY $[HAVE_INTERROGATE]

#define LOCAL_LIBS dtoolutil dtoolbase
#define YACC_PREFIX cppyy

#begin static_lib_target
  #define TARGET cppParser

  #define SOURCES \
     cppAttributeList.h \
     cppArrayType.h cppBison.yxx cppBisonDefs.h  \
     cppClassTemplateParameter.h cppCommentBlock.h \
     cppClosureType.h cppConstType.h  \
     cppDeclaration.h cppEnumType.h cppExpression.h  \
     cppExpressionParser.h cppExtensionType.h cppFile.h  \
     cppFunctionGroup.h cppFunctionType.h cppGlobals.h  \
     cppIdentifier.h cppInstance.h cppInstanceIdentifier.h  \
     cppMakeProperty.h cppMakeSeq.h cppManifest.h \
     cppNameComponent.h cppNamespace.h  \
     cppParameterList.h cppParser.h cppPointerType.h  \
     cppPreprocessor.h cppReferenceType.h cppScope.h  \
     cppSimpleType.h cppStructType.h cppTBDType.h  \
     cppTemplateParameterList.h cppTemplateScope.h cppToken.h  \
     cppType.h cppTypeDeclaration.h cppTypeParser.h  \
     cppTypeProxy.h cppTypedefType.h cppUsing.h cppVisibility.h

  #define COMPOSITE_SOURCES  \
     cppAttributeList.cxx \
     cppArrayType.cxx \
     cppClassTemplateParameter.cxx  \
     cppCommentBlock.cxx cppClosureType.cxx cppConstType.cxx cppDeclaration.cxx  \
     cppEnumType.cxx cppExpression.cxx cppExpressionParser.cxx  \
     cppExtensionType.cxx cppFile.cxx cppFunctionGroup.cxx  \
     cppFunctionType.cxx cppGlobals.cxx cppIdentifier.cxx  \
     cppInstance.cxx cppInstanceIdentifier.cxx \
     cppMakeProperty.cxx cppMakeSeq.cxx cppManifest.cxx  \
     cppNameComponent.cxx cppNamespace.cxx cppParameterList.cxx  \
     cppParser.cxx cppPointerType.cxx cppPreprocessor.cxx  \
     cppReferenceType.cxx cppScope.cxx cppSimpleType.cxx  \
     cppStructType.cxx cppTBDType.cxx  \
     cppTemplateParameterList.cxx cppTemplateScope.cxx  \
     cppToken.cxx cppType.cxx cppTypeDeclaration.cxx  \
     cppTypeParser.cxx cppTypeProxy.cxx cppTypedefType.cxx  \
     cppUsing.cxx cppVisibility.cxx

#end static_lib_target
