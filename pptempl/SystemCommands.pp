//
// SystemCommands.pp
//
// This file defines variables that translate to OS-specific terminal commands.
//

#if $[WINDOWS_PLATFORM]

// For Windows.

#defun TOUCH_CMD file
  #define osfile $[osfilename $[file]]
  if not exist $[osfile] ( echo|set /p arg="" >> $[osfile] ) else ( copy /b $[osfile] +,, $[osfile] )
#end TOUCH_CMD

#defun COPY_CMD src,dest
  echo F|xcopy /I/Y $[osfilename $[src]] $[osfilename $[dest]]
#end COPY_CMD

#defun COPY_DIR_CMD src,dest
  echo D|xcopy /I/Y $[osfilename $[src]] $[osfilename $[dest]]
#end COPY_DIR_CMD

#defun MOVE_CMD src,dest
  move $[osfilename $[src]] $[osfilename $[dest]]
#end MOVE_CMD

#defun DEL_CMD file
  del /f/s/q $[osfilename $[file]]
#end DEL_CMD

#defun DEL_DIR_CMD dir
  rmdir /s/q $[osfilename $[dir]]
#end DEL_DIR_CMD

#defun MKDIR_CMD directory
  #define directory $[osfilename $[directory]]
  if not exist $[directory] mkdir $[directory]
#end MKDIR_CMD

// Writes a CMD line to echo the given string to the given filename.
// If newline is nonempty, puts a newline in the file after the string,
// otherwise puts a space.
#defun ECHO_TO_FILE str,file,newline
  #if $[newline]
    echo $[str] >> $[osfilename $[file]]
  #else
    echo|set /p arg="$[str] " >> $[osfilename $[file]]
  #endif
#end ECHO_TO_FILE

#else

// For everyone else in the universe.
#defun TOUCH_CMD file
  touch $[file]
#end TOUCH_CMD

#defun COPY_CMD src,dest
  cp $[src] $[dest]
#end COPY_CMD

#defun MOVE_CMD src,dest
  mv $[src] $[dest]
#end MOVE_CMD

#defun DEL_CMD file
  rm -rf $[file]
#end DEL_CMD

#defun DEL_DIR_CMD dir
  rm -rf $[dir]
#end DEL_DIR_CMD

#defun MKDIR_CMD directory
  @test -d $[directory] || mkdir -p $[directory]
#end MKDIR_CMD

// Writes a Bash line to echo the given string to the given filename.
// If newline is nonempty, puts a newline in the file after the string,
// otherwise puts a space.
#defun ECHO_TO_FILE str,file,newline
  #if $[newline]
    echo $[str] >> $[file]
  #else
    echo -n "$[str] " >> $[file]
  #endif
#end ECHO_TO_FILE

#endif // $[WINDOWS_PLATFORM]
