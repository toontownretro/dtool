// Filename: atomicAdjustI386Impl.h
// Created by:  drose (01Apr06)
//
////////////////////////////////////////////////////////////////////
//
// PANDA 3D SOFTWARE
// Copyright (c) Carnegie Mellon University.  All rights reserved.
//
// All use of this software is subject to the terms of the revised BSD
// license.  You should have received a copy of this license along
// with this source code in a file named "LICENSE."
//
////////////////////////////////////////////////////////////////////

#ifndef ATOMICADJUSTI386IMPL_H
#define ATOMICADJUSTI386IMPL_H

#include "dtoolbase.h"
#include "selectThreadImpl.h"

#if defined(__i386__) || defined(_M_IX86)

#include "numeric_types.h"

////////////////////////////////////////////////////////////////////
//       Class : AtomicAdjustI386Impl
// Description : Uses assembly-language calls to atomically increment
//               and decrement.  Although this class is named i386, it
//               actually uses instructions that are specific to 486
//               and higher.
////////////////////////////////////////////////////////////////////
class EXPCL_DTOOL AtomicAdjustI386Impl {
public:
  typedef PN_int32 Integer;

  INLINE static void inc(TVOLATILE Integer &var);
  INLINE static bool dec(TVOLATILE Integer &var);
  INLINE static void add(TVOLATILE Integer &var, Integer delta);
  INLINE static Integer set(TVOLATILE Integer &var, Integer new_value);
  INLINE static Integer get(const TVOLATILE Integer &var);

  INLINE static void *set_ptr(void * TVOLATILE &var, void *new_value);
  INLINE static void *get_ptr(void * const TVOLATILE &var);

  INLINE static Integer compare_and_exchange(TVOLATILE Integer &mem, 
                                              Integer old_value,
                                              Integer new_value);

  INLINE static void *compare_and_exchange_ptr(void * TVOLATILE &mem, 
                                               void *old_value,
                                               void *new_value);
};

#include "atomicAdjustI386Impl.I"

#endif  // __i386__

#endif
