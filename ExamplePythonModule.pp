panda/
  src/
    pgraph/
    putil/
    gobj/
  metalibs/
    panda/
    pandabullet/
    pandaphysics/
  modules/
    core/
    physics/
    bullet/
    ode/

src - individual component libraries
metalibs - library containing component libraries
modules - python module containing interrogated code + extensions of component libraries

To build a python module:

#begin python_module_target
  #define TARGET panda3d.core
  #define LIBS \
    p3pgraph p3gobj p3putil p3linmath p3mathutil
    ...


#end python_module_target
