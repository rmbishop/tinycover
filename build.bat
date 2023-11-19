rem set COMPILER=gcc.exe
set COMPILER=cl.exe

if %COMPILER%==cl.exe goto :MSVC
%COMPILER% hexify.c -o hexify.exe
hexify.exe libtinycover.lua libtinycover.c libtinycover_buffer
hexify.exe tinycover_utils.lua tinycover_utils.c tinycover_utils_buffer 
%COMPILER% -DWIN32 tinycover.c -o tinycover -I./lua-5.4.6/src/  ./lua-5.4.6/src/tc_inst_decl.c ./lua-5.4.6/src/lapi.c ./lua-5.4.6/src/lauxlib.c ./lua-5.4.6/src/lbaselib.c ./lua-5.4.6/src/lcode.c ./lua-5.4.6/src/lcorolib.c ./lua-5.4.6/src/lctype.c ./lua-5.4.6/src/ldblib.c ./lua-5.4.6/src/ldebug.c ./lua-5.4.6/src/ldo.c ./lua-5.4.6/src/ldump.c ./lua-5.4.6/src/lfunc.c ./lua-5.4.6/src/lgc.c ./lua-5.4.6/src/linit.c ./lua-5.4.6/src/liolib.c ./lua-5.4.6/src/llex.c ./lua-5.4.6/src/lmathlib.c ./lua-5.4.6/src/lmem.c ./lua-5.4.6/src/loadlib.c ./lua-5.4.6/src/lobject.c ./lua-5.4.6/src/lopcodes.c ./lua-5.4.6/src/loslib.c ./lua-5.4.6/src/lparser.c ./lua-5.4.6/src/lstate.c ./lua-5.4.6/src/lstring.c ./lua-5.4.6/src/lstrlib.c ./lua-5.4.6/src/ltable.c ./lua-5.4.6/src/ltablib.c ./lua-5.4.6/src/ltm.c ./lua-5.4.6/src/lundump.c ./lua-5.4.6/src/lutf8lib.c ./lua-5.4.6/src/lvm.c ./lua-5.4.6/src/lzio.c
goto :END

:MSVC
cl.exe hexify.c /o hexify.exe
hexify.exe libtinycover.lua libtinycover.c libtinycover_buffer 
hexify.exe tinycover_utils.lua tinycover_utils.c tinycover_utils_buffer 
cl.exe /D "WIN32" /D "MSVC" tinycover.c /I./lua-5.4.6/src/  ./lua-5.4.6/src/lapi.c ./lua-5.4.6/src/lauxlib.c ./lua-5.4.6/src/lbaselib.c ./lua-5.4.6/src/lcode.c ./lua-5.4.6/src/lcorolib.c ./lua-5.4.6/src/lctype.c ./lua-5.4.6/src/ldblib.c ./lua-5.4.6/src/ldebug.c ./lua-5.4.6/src/ldo.c ./lua-5.4.6/src/ldump.c ./lua-5.4.6/src/lfunc.c ./lua-5.4.6/src/lgc.c ./lua-5.4.6/src/linit.c ./lua-5.4.6/src/liolib.c ./lua-5.4.6/src/llex.c ./lua-5.4.6/src/lmathlib.c ./lua-5.4.6/src/lmem.c ./lua-5.4.6/src/loadlib.c ./lua-5.4.6/src/lobject.c ./lua-5.4.6/src/lopcodes.c ./lua-5.4.6/src/loslib.c ./lua-5.4.6/src/lparser.c ./lua-5.4.6/src/lstate.c ./lua-5.4.6/src/lstring.c ./lua-5.4.6/src/lstrlib.c ./lua-5.4.6/src/ltable.c ./lua-5.4.6/src/ltablib.c ./lua-5.4.6/src/ltm.c ./lua-5.4.6/src/lundump.c ./lua-5.4.6/src/lutf8lib.c ./lua-5.4.6/src/lvm.c ./lua-5.4.6/src/lzio.c
del *.obj
:END
