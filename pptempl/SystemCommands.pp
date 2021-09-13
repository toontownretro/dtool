//
// SystemCommands.pp
//
// This file defines variables that translate to OS-specific terminal commands.
//

#if $[WINDOWS_PLATFORM]

// For Windows.
#define TOUCH_CMD echo.>>
#define COPY_CMD xcopy /I/Y
#define DEL_CMD del /f/s/q
#define DEL_DIR_CMD rmdir /s/q

#else

// For everyone else in the universe.
#define TOUCH_CMD touch
#define COPY_CMD cp
#define DEL_CMD rm -rf
#define DEL_DIR_CMD rm -rf

#endif // $[WINDOWS_PLATFORM]
