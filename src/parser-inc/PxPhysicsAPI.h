#ifndef PXPHYSICSAPI_H
#define PXPHYSICSAPI_H

namespace physx {
  class PxScene;
  class PxMaterial;
  class PxGeometry;
  class PxSphereGeometry;
  class PxCapsuleGeometry;
  class PxBoxGeometry;
  class PxPlaneGeometry;
  class PxShape;
  class PxActor;
  class PxRigidActor;
  class PxRigidBody;
  class PxRigidDynamic;
  class PxRigidStatic;
  class PxPvd;
  class PxCpuDispatcher;
  class PxPhysics;
  class PxFoundation;
  class PxCooking;
  class PxTolerancesScale;

  struct PxErrorCode {
    enum Enum {
      BLAH,
    };
  };

  typedef float PxReal;
}

#endif
