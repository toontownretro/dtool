#!/bin/sh

OS=`uname`
export OS

# Setup the initial path
if [ $OS = "Linux" ]; then
  PATH=/var/local/bin:~/bin:.:/usr/sbin:/sbin:/usr/bin:/bin:/usr/bin/X11:/usr/etc:/usr/local/bin
elif [ $OS = "IRIX64" ]; then
  PATH=/var/local/bin:/usr/local/bin/ptools:~/bin:/usr/local/prman/bin:.:/usr/sbin:/usr/bsd:/sbin:/usr/bin:/bin:/usr/bin/X11:/usr/etc:/usr/demos/bin:/usr/local/bin
elif [ $OS = "CYGWIN_98-4.10" ]; then
  PATH=/usr/local/bin:/bin:/CYGNUS/CYGWIN~1/H-I586~1/BIN:/WINDOWS:/WINDOWS:/WINDOWS/COMMAND:/DMI/BIN:/KATANA/UTL/DEV/MAKE:/KATANA/UTL/DEV/HITACHI
else
  PATH=/var/local/bin:/usr/local/bin/ptools:~/bin:/usr/local/prman/bin:.:/usr/sbin:/usr/bsd:/sbin:/usr/bin:/bin:/usr/bin/X11:/usr/etc:/usr/demos/bin:/usr/local/bin
fi

LD_LIBRARY_PATH="."
export LD_LIBRARY_PATH
DYLD_LIBRARY_PATH="."
export DYLD_LIBRARY_PATH
CT_INCLUDE_PATH="."
export CT_INCLUDE_PATH
#cdpath=.
#CDPATH="."
#export CDPATH
DC_PATH="."
export DC_PATH
SSPATH="."
export SSPATH
STKPATH="."
export STKPATH
SHELL_TYPE="sh"
export SHELL_TYPE

if [ -z "$PLAYER" ]; then
  PLAYER=$HOME/player
  export PLAYER
fi

if [ -z "$PPREMAKE_CONFIG" ]; then
  PPREMAKE_CONFIG=$PLAYER/Config.pp
  export PPREMAKE_CONFIG
fi

if [ -z "$CTDEFAULT_FLAV" ]; then
  CTDEFAULT_FLAV="default"
  export CTDEFAULT_FLAV
fi

if [ -z "$CTVSPEC_PATH" ]; then
  CTVSPEC_PATH=$PLAYER/vspec
  export CTVSPEC_PATH
fi

if [ -z ${DTOOL} ]; then
  DTOOL=$PLAYER/dtool
  export DTOOL
fi

if [ -z "$PENV" ]; then
  if [ $OS = "Linux" ]; then
    PENV="Linux"
  elif [ $OS = "IRIX64" ]; then
    PENV="SGI"
  elif [ $OS = "CYGWIN_98-4.10" ]; then
    PENV="WIN32_DREAMCAST"
  else
    PENV="SGI"
  fi
fi
export PENV

if [ -e $DTOOL/built/bin ]; then
  # Use the installed ctattach if we are already built.
  cttools_path=$DTOOL/built/bin
else
  # If we're not already built, use the ctattach from the source tree.
  cttools_path=$DTOOL/src/attach
fi

PATH=$cttools_path:$PATH
export PATH

PYTHONPATH=$cttools_path:$PYTHONPATH
export PYTHONPATH

if [ -z "$1" ]; then
  SETUP_SCRIPT=`$cttools_path/ctattach.py dtool`
else
  SETUP_SCRIPT=`$cttools_path/ctattach.py dtool $1`
fi

if [ -z "$SETUP_SCRIPT" ]; then
  echo "error: ctattach.py returned NULL string for setup_script filename!"
  echo "      'dtool/built/bin/ctattach.py' probably doesn't exist, need to make install on dtool to copy it from dtool/src/attach"
else
  source $SETUP_SCRIPT
fi
