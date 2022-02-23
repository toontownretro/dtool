#define SELECT_TAU select.tau
#define USE_PACKAGES threads eigen
#if $[HAVE_MIMALLOC]
  #define USE_PACKAGES $[USE_PACKAGES] mimalloc
#endif

#begin lib_target
  #define TARGET dtoolbase

  #define BUILDING_DLL BUILDING_DTOOL_DTOOLBASE

  #if $[HAVE_MIMALLOC]
    #define WIN_SYS_LIBS $[WIN_SYS_LIBS] advapi32.lib Kernel32.lib
  #endif

  #define SOURCES \
    checkPandaVersion.h \
    pandaVersion.h \
    addHash.I addHash.h \
    atomicAdjust.h \
    atomicAdjustDummyImpl.h atomicAdjustDummyImpl.I \
    atomicAdjustGccImpl.h atomicAdjustGccImpl.I \
    atomicAdjustI386Impl.h atomicAdjustI386Impl.I \
    atomicAdjustPosixImpl.h atomicAdjustPosixImpl.I \
    atomicAdjustWin32Impl.h atomicAdjustWin32Impl.I \
    cmath.I cmath.h \
    deletedBufferChain.h deletedBufferChain.I \
    deletedChain.h deletedChain.T \
    dtoolbase.h dtoolbase_cc.h dtoolsymbols.h \
    dtool_platform.h \
    fakestringstream.h \
    indent.I indent.h indent.cxx \
    memoryBase.h \
    memoryHook.h memoryHook.I \
    mutexImpl.h \
    mutexDummyImpl.h mutexDummyImpl.I \
    mutexPosixImpl.h mutexPosixImpl.I \
    mutexWin32Impl.h mutexWin32Impl.I \
    mutexSpinlockImpl.h mutexSpinlockImpl.I \
    nearly_zero.h \
    neverFreeMemory.h neverFreeMemory.I \
    numeric_types.h \
    pdtoa.h pstrtod.h \
    phmap_base.h \
    phmap_bits.h \
    phmap_config.h \
    phmap_dump.h \
    phmap_fwd_decl.h \
    phmap_utils.h \
    phmap.h \
    phmap_include.h \
    register_type.I register_type.h \
    selectThreadImpl.h \
    stl_compares.I stl_compares.h \
    typeHandle.I typeHandle.h \
    typeRegistry.I typeRegistry.h \
    typeRegistryNode.I typeRegistryNode.h \
    typedObject.I typedObject.h \
    pallocator.T pallocator.h \
    patomic.h patomic.I \
    pdeque.h plist.h pmap.h pset.h \
    pvector.h epvector.h \
    lookup3.h lookup3.c \
    btree.h \
    dlmalloc_src.cxx ptmalloc2_smp_src.cxx

 #define COMPOSITE_SOURCES  \
    checkPandaVersion.cxx \
    addHash.cxx \
    atomicAdjustDummyImpl.cxx \
    atomicAdjustI386Impl.cxx \
    atomicAdjustPosixImpl.cxx \
    atomicAdjustWin32Impl.cxx \
    deletedBufferChain.cxx \
    dtoolbase.cxx \
    memoryBase.cxx \
    memoryHook.cxx \
    mutexDummyImpl.cxx \
    mutexPosixImpl.cxx \
    mutexWin32Impl.cxx \
    mutexSpinlockImpl.cxx \
    neverFreeMemory.cxx \
    pdtoa.cxx \
    pstrtod.cxx \
    register_type.cxx \
    typeHandle.cxx \
    typeRegistry.cxx typeRegistryNode.cxx \
    typedObject.cxx

  #define INSTALL_HEADERS \
    checkPandaVersion.h \
    pandaVersion.h \
    addHash.I addHash.h \
    atomicAdjust.h \
    atomicAdjustDummyImpl.h atomicAdjustDummyImpl.I \
    atomicAdjustGccImpl.h atomicAdjustGccImpl.I \
    atomicAdjustI386Impl.h atomicAdjustI386Impl.I \
    atomicAdjustPosixImpl.h atomicAdjustPosixImpl.I \
    atomicAdjustWin32Impl.h atomicAdjustWin32Impl.I \
    cmath.I cmath.h \
    deletedBufferChain.h deletedBufferChain.I \
    deletedChain.h deletedChain.T \
    dtoolbase.h dtoolbase_cc.h dtoolsymbols.h \
    dtool_platform.h \
    fakestringstream.h \
    indent.I indent.h \
    memoryBase.h \
    memoryHook.h memoryHook.I \
    mutexImpl.h \
    mutexDummyImpl.h mutexDummyImpl.I \
    mutexPosixImpl.h mutexPosixImpl.I \
    mutexWin32Impl.h mutexWin32Impl.I \
    mutexSpinlockImpl.h mutexSpinlockImpl.I \
    nearly_zero.h \
    neverFreeMemory.h neverFreeMemory.I \
    numeric_types.h \
    pdtoa.h pstrtod.h \
    phmap_base.h \
    phmap_bits.h \
    phmap_config.h \
    phmap_dump.h \
    phmap_fwd_decl.h \
    phmap_utils.h \
    phmap.h \
    phmap_include.h \
    register_type.I register_type.h \
    selectThreadImpl.h \
    stl_compares.I stl_compares.h \
    typeHandle.I typeHandle.h \
    typeRegistry.I typeRegistry.h \
    typeRegistryNode.I typeRegistryNode.h \
    typedObject.I typedObject.h \
    pallocator.T pallocator.h \
    patomic.h patomic.I \
    pdeque.h plist.h pmap.h pset.h \
    pvector.h epvector.h \
    lookup3.h \
    btree.h

#end lib_target

#begin test_bin_target
  #define TARGET test_strtod
  #define SOURCES test_strtod.cxx pstrtod.cxx pstrtod.h

#end test_bin_target

#begin test_bin_target
  #define LOCAL_LIBS $[LOCAL_LIBS] dtoolbase
  #define TARGET test_pcontainer
  #define SOURCES test_pcontainer.cxx
#end test_bin_target

#include $[THISDIRPREFIX]pandaVersion.h.pp
