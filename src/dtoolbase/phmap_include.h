/**
 * PANDA 3D SOFTWARE
 * Copyright (c) Carnegie Mellon University.  All rights reserved.
 *
 * All use of this software is subject to the terms of the revised BSD
 * license.  You should have received a copy of this license along
 * with this source code in a file named "LICENSE."
 *
 * @file phmap_include.h
 * @author brian
 * @date 2021-09-02
 */

// This just includes phmap but protects it from interrogate.

#ifndef PHMAP_INCLUDE_H
#define PHMAP_INCLUDE_H

#ifndef CPPPARSER
#include "phmap.h"
#include "btree.h"
#else
namespace phmap {
  template <class Key, class Value, class Compare, class Alloc>
  class btree_map {};

  template <class Key, class Value, class Compare, class Alloc>
  class btree_multimap {};

  template <class Key, class Value, class Compare, class Alloc>
  class flat_hash_map {};

  template <class Key, class Value, class Compare, class Alloc>
  class node_hash_map {};

  template <class Key, class Compare, class Alloc>
  class btree_set {};

  template <class Key, class Compare, class Alloc>
  class btree_multiset {};

  template <class Key, class Compare, class Alloc>
  class flat_hash_set {};

  template <class Key, class Compare, class Alloc>
  class node_hash_set {};
};
#endif

#endif // PHMAP_INCLUDE_H
