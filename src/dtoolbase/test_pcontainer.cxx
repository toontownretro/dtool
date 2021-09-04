/**
 * PANDA 3D SOFTWARE
 * Copyright (c) Carnegie Mellon University.  All rights reserved.
 *
 * All use of this software is subject to the terms of the revised BSD
 * license.  You should have received a copy of this license along
 * with this source code in a file named "LICENSE."
 *
 * @file test_pcontainer.cxx
 * @author brian
 * @date 2021-08-28
 */

#ifndef _WIN32
#pragma error("Must be on windows to compile test_pcontainer");
#endif

#include "pmap.h"
#include "pset.h"
#include "stl_compares.h"

#include <Windows.h>

constexpr int COUNT = 1000000;

int
main(int argc, char *argv[]) {

  std::string *numbers = new std::string[COUNT];
  for (int i = 0; i < COUNT; i++) {
    std::ostringstream ss;
    ss << "Hello " << i;
    numbers[i] = ss.str();
  }

  pmap<std::string, int> amap;
  for (int i = 0; i < COUNT; i++) {
    amap[numbers[i]] = i;
  }

  phash_map<std::string, int, string_hash> hmap;
  for (int i = 0; i < COUNT; i++) {
    hmap[numbers[i]] = i;
  }

  double map_total = 0.0;
  double hmap_total = 0.0;

  for (int i = 0; i < COUNT; i++) {
    LARGE_INTEGER start;
    QueryPerformanceCounter(&start);

    auto it = amap.find(numbers[i]);

    LARGE_INTEGER end;
    QueryPerformanceCounter(&end);

    map_total += (end.QuadPart - start.QuadPart);

    (*it).second++;
  }

  double map_avg = map_total / COUNT;

  for (int i = 0; i < COUNT; i++) {
    LARGE_INTEGER start;
    QueryPerformanceCounter(&start);

    auto it = hmap.find(numbers[i]);

    LARGE_INTEGER end;
    QueryPerformanceCounter(&end);

    hmap_total += (end.QuadPart - start.QuadPart);

    (*it).second++;
  }

  double hmap_avg = hmap_total / COUNT;

  std::cerr << "pmap find avg: " << map_avg << "\n";
  std::cerr << "phash_map find avg: " << hmap_avg << "\n";

  map_total = 0.0;
  hmap_total = 0.0;

  LARGE_INTEGER start;
  QueryPerformanceCounter(&start);

  for (auto it = amap.begin(); it != amap.end(); ++it) {
    (*it).second = 0;
  }

  LARGE_INTEGER end;
  QueryPerformanceCounter(&end);

  map_total = end.QuadPart - start.QuadPart;


  QueryPerformanceCounter(&start);
  for (auto it = hmap.begin(); it != hmap.end(); ++it) {
    (*it).second = 0;
  }
  QueryPerformanceCounter(&end);

  hmap_total = end.QuadPart - start.QuadPart;

  std::cerr << "pmap iter " << map_total << "\n";
  std::cerr << "phash_map itr " << hmap_total << "\n";
}
