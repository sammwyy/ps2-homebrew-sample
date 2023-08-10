EE_BIN = ./build/app.elf
EE_OBJS = ./src/main.o
EE_LIBS = -lfont -lpacket -ldma -lgraph -ldraw -lc

all: $(EE_BIN)
	$(EE_STRIP) --strip-all $(EE_BIN)

clean:
	rm -f $(EE_OBJS)

run: $(EE_BIN)
	ps2client execee host:$(EE_BIN)

reset:
	ps2client reset

# Include makefiles
include $(PS2SDK)/samples/Makefile.pref
include $(PS2SDK)/samples/Makefile.eeglobal