// Filename: prcKeyRegistry.h
// Created by:  drose (19Oct04)
//
////////////////////////////////////////////////////////////////////
//
// PANDA 3D SOFTWARE
// Copyright (c) 2001 - 2004, Disney Enterprises, Inc.  All rights reserved
//
// All use of this software is subject to the terms of the Panda 3d
// Software license.  You should have received a copy of this license
// along with this source code; you will also find a current copy of
// the license at http://etc.cmu.edu/panda3d/docs/license/ .
//
// To contact the maintainers of this program write to
// panda3d-general@lists.sourceforge.net .
//
////////////////////////////////////////////////////////////////////

#ifndef PRCKEYREGISTRY_H
#define PRCKEYREGISTRY_H

#include "dtoolbase.h"

// This file requires OpenSSL to compile, because we use routines in
// the OpenSSL library to manage keys and to sign and validate
// signatures.

#ifdef HAVE_OPENSSL

#include <vector>
#include "openssl/evp.h"

// Some versions of OpenSSL appear to define this as a macro.  Yucky.
#undef set_key

////////////////////////////////////////////////////////////////////
//       Class : PrcKeyRegistry
// Description : This class records the set of public keys used to
//               verify the signature on a prc file.  The actual
//               public keys themselves are generated by the
//               make-prc-key utility; the output of this utility is a
//               .cxx file which should be named by the
//               PRC_PUBLIC_KEYS_FILENAME variable in Config.pp.
//
//               This class requires the OpenSSL library.
////////////////////////////////////////////////////////////////////
class EXPCL_DTOOLCONFIG PrcKeyRegistry {
protected:
  PrcKeyRegistry();
  ~PrcKeyRegistry();

public:
  struct KeyDef {
    const char *_data;
    size_t _length;
    time_t _generated_time;
  };

  void record_keys(const KeyDef *key_def, int num_keys);
  void set_key(int n, EVP_PKEY *pkey, time_t generated_time);

  int get_num_keys() const;
  EVP_PKEY *get_key(int n) const;
  time_t get_generated_time(int n) const;

  static PrcKeyRegistry *get_global_ptr();

private:

  class Key {
  public:
    const KeyDef *_def;
    EVP_PKEY *_pkey;
    time_t _generated_time;
  };

  typedef vector<Key> Keys;
  Keys _keys;

  static PrcKeyRegistry *_global_ptr;
};

#include "prcKeyRegistry.I"

#endif  // HAVE_OPENSSL

#endif

    
  
  

