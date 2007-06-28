// Filename: ode.h
// Created by:  drose (27Jun07)
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
/**
 * @file config.h
 * common internal api header.
 */

#ifndef _ODE_CONFIG_H_
#define _ODE_CONFIG_H_

#define dSINGLE 1
#define _MSC_VER 1
#define ODE_PLATFORM_WINDOWS  

#if !defined(ODE_API)
  #define ODE_API
#endif

#endif /* _ODE_CONFIG_H */

/**
 * @file common.h
 * common internal api header.
 */

#ifndef COMMON_H
#define COMMON_H

#endif /* COMMON_H */



/* ODE header stuff */

#ifndef _ODE_COMMON_H_
#define _ODE_COMMON_H_

#if defined(dSINGLE)
typedef float dReal;
#elif defined(dDOUBLE)
typedef double dReal;
#else
#error You must #define dSINGLE or dDOUBLE
#endif

typedef dReal dVector3[4];
typedef dReal dVector4[4];
typedef dReal dMatrix3[4*3];
typedef dReal dMatrix4[4*4];
typedef dReal dMatrix6[8*6];
typedef dReal dQuaternion[4];

struct dxWorld;		/* dynamics world */
struct dxSpace;		/* collision space */
struct dxBody;		/* rigid body (dynamics object) */
struct dxGeom;		/* geometry (collision object) */
struct dxJoint;
struct dxJointNode;
struct dxJointGroup;

typedef struct dxWorld *dWorldID;
typedef struct dxSpace *dSpaceID;
typedef struct dxBody *dBodyID;
typedef struct dxGeom *dGeomID;
typedef struct dxJoint *dJointID;
typedef struct dxJointGroup *dJointGroupID;

typedef struct dJointFeedback {
  dVector3 f1;		/* force applied to body 1 */
  dVector3 t1;		/* torque applied to body 1 */
  dVector3 f2;		/* force applied to body 2 */
  dVector3 t2;		/* torque applied to body 2 */
} dJointFeedback;

typedef struct dSurfaceParameters dSurfaceParameters;
typedef struct dMass dMass;
typedef struct dContact dContact;
typedef struct dContactGeom dContactGeom;
typedef struct dTriMeshDataID dTriMeshDataID;

#endif /* _ODE_COMMON_H_ */