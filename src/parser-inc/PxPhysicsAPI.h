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
  class PxRaycastHit;
  class PxRaycastBuffer;
  class PxErrorCode {
  public:
    class Enum;
  };
  class PxQueryHitType {
  public:
    class Enum;
  };
  class PxQueryHit;
  class PxFilterFlags;
  class PxFilterObjectAttributes;
  class PxFilterData;
  class PxReal;
  class PxU32;
  class PxVec3;
  class PxExtendedVec3;
  class PxQuat;
  class PxTriggerPair;
  class PxConstraintInfo;
  class PxContactPairHeader;
  class PxContactPair;
  class PxContactPairPoint;
  class PxTransform;
  class PxJoint;
  class PxFixedJoint;
  class PxSphericalJoint;
  class PxRevoluteJoint;
  class PxD6Joint;
  class PxPrismaticJoint;
  class PxDistanceJoint;
  class PxJointLimitParameters;
  class PxJointLimitCone;
  class PxJointAngularLimitPair;
  class PxJointLinearLimitPair;
  class PxJointLimitPyramid;
  class PxSpring;
  class PxConvexMesh;
  class PxConvexMeshGeometry;
  class PxAggregate;
  class PxArticulation;
  class PxArticulationLink;
  class PxSimulationFilterCallback;
  class PxQueryFilterCallback;
  class PxController;
  class PxBoxController;
  class PxBoxControllerDesc;
  class PxCapsuleController;
  class PxCapsuleControllerDesc;
  class PxControllerDesc;
  class PxControllerManager;
}

#endif
