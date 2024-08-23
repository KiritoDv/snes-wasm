
CC = emcc

CFLAGS = -O3 -I ./snes -I ./zip -sUSE_SDL=2 -sEXPORTED_FUNCTIONS=_loadRawRom,_main,_malloc,_free -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,print,addRunDependency,removeRunDependency,emAsmAddr --pre-js web/joystick-pre.js -sALLOW_MEMORY_GROWTH -sFORCE_FILESYSTEM=1 --preload-file web/gamecontrollerdb.txt

WINDRES = windres

execname = web/snesweb.html

appname = LakeSnes.app
appexecname = lakesnes_app
appsdlflags = -framework SDL2 -F sdl2 -rpath @executable_path/../Frameworks

winexecname = snesweb.exe

cfiles = snes/spc.c snes/dsp.c snes/apu.c snes/cpu.c snes/dma.c snes/ppu.c snes/cart.c snes/cx4.c snes/input.c snes/statehandler.c snes/snes.c snes/snes_other.c \
 zip/zip.c tracing.c main.c
hfiles = snes/spc.h snes/dsp.h snes/apu.h snes/cpu.h snes/dma.h snes/ppu.h snes/cart.h snes/cx4.h snes/input.h snes/statehandler.h snes/snes.h \
 zip/zip.h zip/miniz.h tracing.h

.PHONY: all clean

all: $(execname)

$(execname): $(cfiles) $(hfiles)
	$(CC) $(CFLAGS) -o $@ $(cfiles)

$(appexecname): $(cfiles) $(hfiles)
	$(CC) $(CFLAGS) -o $@ $(cfiles) $(appsdlflags) -D SDL2SUBDIR

$(appname): $(appexecname)
	rm -rf $(appname)
	mkdir -p $(appname)/Contents/MacOS
	mkdir -p $(appname)/Contents/Frameworks
	mkdir -p $(appname)/Contents/Resources
	cp -R sdl2/SDL2.framework $(appname)/Contents/Frameworks/
	cp $(appexecname) $(appname)/Contents/MacOS/$(appexecname)
	cp resources/appicon.icns $(appname)/Contents/Resources/
	cp resources/PkgInfo $(appname)/Contents/
	cp resources/Info.plist $(appname)/Contents/

$(winexecname): $(cfiles) $(hfiles)
	$(WINDRES) resources/win.rc -O coff -o win.res
	$(CC) $(CFLAGS) -o $@ $(cfiles) win.res $(sdlflags)

clean:
	rm -f $(execname) $(appexecname) $(winexecname) win.res
	rm -rf $(appname)
