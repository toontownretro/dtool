# dtool

This is the `dtool` tree of the Player, originally derived from the `dtool` directory of the main [Panda3D](https://github.com/panda3d/panda3d) repository.

DTOOL contains low-level utilities, the config system, and `interrogate`, the Python binding generator.

## How to build
Assumes you have already set up the development environment and have built and installed the trees required by DTOOL.
#### Windows
```
cta dtool
cd %DTOOL%
ppremake
nmake/jom install OR msbuild panda.sln -t:install
```
#### Unix
```
cta dtool
cd $DTOOL
ppremake
make install
```
See the [Wiki](https://github.com/toontownretro/documentation/wiki) for instructions on setting up the development environment and the entire project as a whole.
