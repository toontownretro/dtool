/**
 * PANDA 3D SOFTWARE
 * Copyright (c) Carnegie Mellon University.  All rights reserved.
 *
 * All use of this software is subject to the terms of the revised BSD
 * license.  You should have received a copy of this license along
 * with this source code in a file named "LICENSE."
 *
 * @file pset.h
 * @author drose
 * @date 2001-06-05
 */

#ifndef PSET_H
#define PSET_H

#include "dtoolbase.h"
#include "pallocator.h"
#include "stl_compares.h"
#include "register_type.h"

#ifndef CPPPARSER
#include "phmap.h"
#include "btree.h"
#else
namespace phmap {
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

#include <set>
#ifdef HAVE_STL_HASH
#include <unordered_set>
#endif

#include <initializer_list>

#if !defined(USE_STL_ALLOCATOR) || defined(CPPPARSER)
// If we're not using custom allocators, just use the standard class
// definition.
#define pset std::set
#define pnode_set std::set
#define pmultiset std::multiset
#define pnode_multiset std::multiset

#ifdef HAVE_STL_HASH
#define phash_set std::unordered_set
#define pnode_hash_set std::unordered_set
#define phash_multiset std::unordered_multiset
#else  // HAVE_STL_HASH
#define phash_set std::set
#define pnode_hash_set std::set
#define phash_multiset std::multiset
#endif  // HAVE_STL_HASH

#else  // USE_STL_ALLOCATOR

/**
 * This is our own Panda specialization on the default STL set.  Its main
 * purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 */
template<class Key, class Compare = std::less<Key> >
class pset : public phmap::btree_set<Key, Compare, pallocator_array<Key> > {
public:
  typedef pallocator_array<Key> allocator;
  typedef phmap::btree_set<Key, Compare, allocator> base_class;
  pset(TypeHandle type_handle = pset_type_handle) : base_class({}, Compare(), allocator(type_handle)) { }
  pset(const Compare &comp, TypeHandle type_handle = pset_type_handle) : base_class({}, comp, allocator(type_handle)) { }
  pset(std::initializer_list<Key> init, TypeHandle type_handle = pset_type_handle) : base_class(std::move(init), Compare(), allocator(type_handle)) { }
};

/**
 * This is our own Panda specialization on the default STL set.  Its main
 * purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 *
 * Use this version if you need pointer/iterator stability.
 */
template<class Key, class Compare = std::less<Key> >
class pnode_set : public std::set<Key, Compare, pallocator_single<Key> > {
public:
  typedef pallocator_single<Key> allocator;
  typedef std::set<Key, Compare, allocator> base_class;
  pnode_set(TypeHandle type_handle = pset_type_handle) : base_class(Compare(), allocator(type_handle)) { }
  pnode_set(const Compare &comp, TypeHandle type_handle = pset_type_handle) : base_class(comp, type_handle) { }
  pnode_set(std::initializer_list<Key> init, TypeHandle type_handle = pset_type_handle) : base_class(std::move(init), allocator(type_handle)) { }
};

/**
 * This is our own Panda specialization on the default STL multiset.  Its main
 * purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 */
template<class Key, class Compare = std::less<Key> >
class pmultiset : public phmap::btree_multiset<Key, Compare, pallocator_array<Key> > {
public:
  typedef pallocator_array<Key> allocator;
  pmultiset(TypeHandle type_handle = pset_type_handle) :
    phmap::btree_multiset<Key, Compare, allocator>({}, Compare(), allocator(type_handle)) { }
  pmultiset(const Compare &comp, TypeHandle type_handle = pset_type_handle) :
    phmap::btree_multiset<Key, Compare, allocator>({}, comp, allocator(type_handle)) { }
  pmultiset(std::initializer_list<Key> init, TypeHandle type_handle = pset_type_handle) :
    phmap::btree_multiset<Key, Compare, allocator>(std::move(init), Compare(), allocator(type_handle)) { }
};

/**
 * This is our own Panda specialization on the default STL multiset.  Its main
 * purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 *
 * Use this version if you need pointer/iterator stability.
 */
template<class Key, class Compare = std::less<Key> >
class pnode_multiset : public std::multiset<Key, Compare, pallocator_single<Key> > {
public:
  typedef pallocator_single<Key> allocator;
  pnode_multiset(TypeHandle type_handle = pset_type_handle) : std::multiset<Key, Compare, allocator>(Compare(), allocator(type_handle)) { }
  pnode_multiset(const Compare &comp, TypeHandle type_handle = pset_type_handle) : std::multiset<Key, Compare, allocator>(comp, type_handle) { }
  pnode_multiset(std::initializer_list<Key> init, TypeHandle type_handle = pset_type_handle) : std::multiset<Key, Compare, allocator>(std::move(init), allocator(type_handle)) { }
};

#ifdef HAVE_STL_HASH
/**
 * This is our own Panda specialization on the default STL hash_set.  Its main
 * purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 */
template<class Key, class Compare = method_hash<Key, std::less<Key> > >
class phash_set : public phmap::flat_hash_set<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> > {
public:
  phash_set() : phmap::flat_hash_set<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> >() { }
  //phash_set(const Compare &comp) : phmap::flat_hash_set<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> >(comp) { }
};

/**
 * This is our own Panda specialization on the default STL hash_set.  Its main
 * purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 */
template<class Key, class Compare = method_hash<Key, std::less<Key> > >
class pnode_hash_set : public phmap::node_hash_set<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> > {
public:
  pnode_hash_set() : phmap::node_hash_set<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> >() { }
  //phash_set(const Compare &comp) : phmap::flat_hash_set<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> >(comp) { }
};

/**
 * This is our own Panda specialization on the default STL hash_multiset.  Its
 * main purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 */
template<class Key, class Compare = method_hash<Key, std::less<Key> > >
class phash_multiset : public std::unordered_multiset<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> > {
public:
  phash_multiset() : std::unordered_multiset<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> >() { }
  phash_multiset(const Compare &comp) : std::unordered_multiset<Key, Compare, internal_stl_equals<Key, Compare>, pallocator_array<Key> >(comp) { }
};

#else // HAVE_STL_HASH
#define phash_set pset
#define phash_multiset pmultiset
#endif  // HAVE_STL_HASH

#endif  // USE_STL_ALLOCATOR
#endif
