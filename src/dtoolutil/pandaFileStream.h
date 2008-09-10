// Filename: pandaFileStream.h
// Created by:  drose (08Sep08)
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

#ifndef PANDAFILESTREAM_H
#define PANDAFILESTREAM_H

#include "dtoolbase.h"
#include "pandaFileStreamBuf.h"

////////////////////////////////////////////////////////////////////
//       Class : IFileStream
// Description : Implements a C++ stream object suitable for reading
//               from files on disk.  This is similar to ifstream, but
//               it provides low-level support for Panda's
//               simple-threading implementation (using this interface
//               will block only the current thread, rather than the
//               entire process, on I/O waits).
////////////////////////////////////////////////////////////////////
class EXPCL_DTOOL IFileStream : public istream {
public:
  INLINE IFileStream();
  INLINE IFileStream(const char *filename, ios::openmode mode = ios::in);
  INLINE ~IFileStream();

  INLINE void open(const char *filename, ios::openmode mode = ios::in);
  INLINE void close();

private:
  PandaFileStreamBuf _buf;
};

////////////////////////////////////////////////////////////////////
//       Class : OFileStream
// Description : Implements a C++ stream object suitable for writing
//               to files on disk.  This is similar to ofstream, but
//               it provides low-level support for Panda's
//               simple-threading implementation (using this interface
//               will block only the current thread, rather than the
//               entire process, on I/O waits).
////////////////////////////////////////////////////////////////////
class EXPCL_DTOOL OFileStream : public ostream {
public:
  INLINE OFileStream();
  INLINE OFileStream(const char *filename, ios::openmode mode = ios::out);
  INLINE ~OFileStream();

  INLINE void open(const char *filename, ios::openmode mode = ios::out);
  INLINE void close();

private:
  PandaFileStreamBuf _buf;
};

////////////////////////////////////////////////////////////////////
//       Class : FileStream
// Description : Implements a C++ stream object suitable for reading
//               from and/or writing to files on disk.  This is
//               similar to fstream, but it provides low-level support
//               for Panda's simple-threading implementation (using
//               this interface will block only the current thread,
//               rather than the entire process, on I/O waits).
////////////////////////////////////////////////////////////////////
class EXPCL_DTOOL FileStream : public iostream {
public:
  INLINE FileStream();
  INLINE FileStream(const char *filename, ios::openmode mode = ios::in);
  INLINE ~FileStream();

  INLINE void open(const char *filename, ios::openmode mode = ios::in);
  INLINE void close();

private:
  PandaFileStreamBuf _buf;
};

#include "pandaFileStream.I"

// Not ready for prime time yet.
/*
typedef IFileStream pifstream;
typedef OFileStream pofstream;
typedef FileStream pfstream;
*/

typedef ifstream pifstream;
typedef ofstream pofstream;
typedef fstream pfstream;

#endif
