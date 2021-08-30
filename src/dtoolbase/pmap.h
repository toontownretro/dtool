/**
 * PANDA 3D SOFTWARE
 * Copyright (c) Carnegie Mellon University.  All rights reserved.
 *
 * All use of this software is subject to the terms of the revised BSD
 * license.  You should have received a copy of this license along
 * with this source code in a file named "LICENSE."
 *
 * @file pmap.h
 * @author drose
 * @date 2001-06-05
 */

#ifndef PMAP_H
#define PMAP_H

#include "dtoolbase.h"
#include "pallocator.h"
#include "stl_compares.h"
#include "register_type.h"

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
};
#endif

#include <map>
#ifdef HAVE_STL_HASH
#include <unordered_map>
#endif

#if !defined(USE_STL_ALLOCATOR) || defined(CPPPARSER)
// If we're not using custom allocators, just use the standard class
// definition.
#define pmap std::map
#define pmultimap std::multimap
#define pnode_map std::map
#define pnode_multimap std::multimap

#ifdef HAVE_STL_HASH
#define phash_map std::unordered_map
#define pnode_hash_map std::unordered_map
#define phash_multimap std::unordered_multimap
#else  // HAVE_STL_HASH
#define phash_map map
#define pnode_hash_map map
#define phash_multimap multimap
#endif  // HAVE_STL_HASH

#else  // USE_STL_ALLOCATOR

/**
 * This is our own Panda specialization on the parallel-hashmap btree_map.  It
 * hooks into our allocator.  Note that this map does not guarantee
 * pointer/iterator stability.  If you need that, use pnode_map instead.
 */
template<class Key, class Value, class Compare = std::less<Key> >
class pmap : public phmap::btree_map<Key, Value, Compare, pallocator_array<std::pair<const Key, Value> > > {
public:
  typedef pallocator_array<std::pair<const Key, Value> > allocator;
  typedef phmap::btree_map<Key, Value, Compare, allocator> base_class;

  pmap(TypeHandle type_handle = pmap_type_handle) : base_class({}, Compare(), allocator(type_handle)) { }
  pmap(const Compare &comp, TypeHandle type_handle = pmap_type_handle) : base_class({}, comp, allocator(type_handle)) { }
};

/**
 * Use this map if you need pointer/iterator stability.  It just uses the
 * default STL map.
 */
template<class Key, class Value, class Compare = std::less<Key> >
class pnode_map : public std::map<Key, Value, Compare, pallocator_single<std::pair<const Key, Value> > > {
public:
  typedef pallocator_single<std::pair<const Key, Value> > allocator;
  typedef std::map<Key, Value, Compare, allocator> base_class;

  pnode_map(TypeHandle type_handle = pmap_type_handle) : base_class(Compare(), allocator(type_handle)) { }
  pnode_map(const Compare &comp, TypeHandle type_handle = pmap_type_handle) : base_class(comp, allocator(type_handle)) { }
};

/**
 * This is our own Panda specialization on the parallel-hashmap btree_multimap.
 * Its main purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.  This version does not guarantee pointer/iterator
 * stability.  Use pnode_multimap if you need pointer/iterator stability.
 */
template<class Key, class Value, class Compare = phmap::Less<Key> >
class pmultimap : public phmap::btree_multimap<Key, Value, Compare, pallocator_array<std::pair<const Key, Value> > > {
public:
  typedef pallocator_array<std::pair<const Key, Value> > allocator;
  pmultimap(TypeHandle type_handle = pmap_type_handle) :
    phmap::btree_multimap<Key, Value, Compare, allocator>({}, Compare(), allocator(type_handle)) { }
  pmultimap(const Compare &comp, TypeHandle type_handle = pmap_type_handle) :
    phmap::btree_multimap<Key, Value, Compare, allocator>({}, comp, allocator(type_handle)) { }
};

/**
 * Use this multimap if you need pointer/iterator stability.
 */
template<class Key, class Value, class Compare = std::less<Key> >
class pnode_multimap : public std::multimap<Key, Value, Compare, pallocator_single<std::pair<const Key, Value> > > {
public:
  typedef pallocator_single<std::pair<const Key, Value> > allocator;
  pnode_multimap(TypeHandle type_handle = pmap_type_handle) : std::multimap<Key, Value, Compare, allocator>(Compare(), allocator(type_handle)) { }
  pnode_multimap(const Compare &comp, TypeHandle type_handle = pmap_type_handle) : std::multimap<Key, Value, Compare, allocator>(comp, allocator(type_handle)) { }
};

#ifdef HAVE_STL_HASH
/**
 * This is our own Panda specialization on the default STL unordered_map.
 * Its main purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 */
template<class Key, class Value, class Compare = method_hash<Key, std::less<Key> > >
class phash_map : public phmap::flat_hash_map<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > > {
public:
  typedef pallocator_array<std::pair<const Key, Value>> allocator;
  phash_map() :
    phmap::flat_hash_map<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > >() { }
  //phash_map(const Compare &comp) :
  //  phmap::flat_hash_map<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > >(comp) { }
};

/**
 * This is our own Panda specialization on the default STL unordered_map.
 * Its main purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 */
template<class Key, class Value, class Compare = method_hash<Key, std::less<Key> > >
class pnode_hash_map : public phmap::node_hash_map<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > > {
public:
  typedef pallocator_array<std::pair<const Key, Value>> allocator;
  pnode_hash_map() :
    phmap::node_hash_map<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > >() { }
  //phash_map(const Compare &comp) :
  //  phmap::node_hash_map<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > >(comp) { }
};

/**
 * This is our own Panda specialization on the default STL unordered_multimap.
 * Its main purpose is to call the hooks for MemoryUsage to properly track STL-
 * allocated memory.
 */
template<class Key, class Value, class Compare = method_hash<Key, std::less<Key> > >
class phash_multimap : public std::unordered_multimap<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > > {
public:
  phash_multimap() : std::unordered_multimap<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > >() { }
  phash_multimap(const Compare &comp) : std::unordered_multimap<Key, Value, Compare, internal_stl_equals<Key, Compare>, pallocator_array<std::pair<const Key, Value> > >(comp) { }
};

#else // HAVE_STL_HASH
#define phash_map pmap
#define phash_multimap pmultimap
#endif  // HAVE_STL_HASH

#endif  // USE_STL_ALLOCATOR
#endif
