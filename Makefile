EE_EXT = .elf

EE_BIN = app
EE_BIN_PKD = app_pkd

EE_SRC_DIR = src/
EE_OBJS_DIR = obj/
EE_ASM_DIR = embed/

RESET_IOP ?= 1
DEBUG ?= 0
EE_SIO ?= 0

CLI ?= 0
GRAPHICS ?= 1
AUDIO ?= 1
NETWORK ?= 1
KEYBOARD ?= 1
MOUSE ?= 1
CAMERA ?= 0

EE_LIBS = -L$(PS2SDK)/ports/lib -L$(PS2DEV)/gsKit/lib/ -lmc -lpad -laudsrv -lpatches -ldebug -lmath3d -ljpeg -lfreetype -lgskit_toolkit -lgskit -ldmakit -lpng -lz -lnetman -lps2ip -lcurl -lwolfssl -lkbd -lmouse -lvorbisfile -lvorbis -logg -llzma -lzip -lfileXio -lelf-loader-nocolour -lerl
EE_INCS += -I$(PS2DEV)/gsKit/include -I$(PS2SDK)/ports/include -I$(PS2SDK)/ports/include/freetype2 -I$(PS2SDK)/ports/include/zlib

EE_CFLAGS += -Wno-sign-compare -fno-strict-aliasing -fno-exceptions -fpermissive -DCONFIG_VERSION=\"$(shell cat VERSION)\" -D__TM_GMTOFF=tm_gmtoff -DPATH_MAX=256 -DPS2
ifeq ($(RESET_IOP),1)
  EE_CFLAGS += -DRESET_IOP
endif

ifeq ($(DEBUG),1)
  EE_CFLAGS += -DDEBUG
endif

BIN2S = $(PS2SDK)/bin/bin2c
EE_DVP = dvp-as
EE_VCL = vcl
EE_VCLPP = vclpp

APP_CORE = main.o

IOP_MODULES = iomanx.o filexio.o sio2man.o mcman.o mcserv.o padman.o  \
			  usbd.o bdm.o bdmfs_fatfs.o usbmass_bd.o cdfs.o \
			  ps2dev9.o mtapman.o poweroff.o ps2atad.o \
			  ps2hdd.o ps2fs.o

ifneq ($(EE_SIO), 0)
  EE_BIN := $(EE_BIN)_eesio
  EE_BIN_PKD := $(EE_BIN_PKD)_eesio
  EE_CFLAGS += -D__EESIO_PRINTF
  EE_LIBS += -lsiocookie
endif

EE_OBJS = $(APP_CORE) $(IOP_MODULES)
EE_OBJS := $(EE_OBJS:%=$(EE_OBJS_DIR)%)

EE_BIN := $(EE_BIN)$(EE_EXT)
EE_BIN_PKD := $(EE_BIN_PKD)$(EE_EXT)


#-------------------------- App Content ---------------------------#

all: $(EE_BIN) $(EE_ASM_DIR) $(EE_OBJS_DIR)
	@echo "$$HEADER"

	echo "Building $(EE_BIN)..."
	$(EE_STRIP) $(EE_BIN)
	rm -r build/
	mkdir build/
	mv $(EE_BIN) build/

debug: $(EE_BIN)
	echo "Building $(EE_BIN) with debug symbols..."
	mv $(EE_BIN) build/app_debug.elf

tests: all
	mv build/$(EE_BIN) tests/test_suite.elf

clean:
	echo Cleaning executables...
	rm -f build/$(EE_BIN) build/$(EE_BIN_PKD)
	rm -rf $(EE_OBJS_DIR)
	rm -rf $(EE_ASM_DIR)

rebuild: clean all

include $(PS2SDK)/samples/Makefile.pref
include $(PS2SDK)/samples/Makefile.eeglobal
include embed.make

$(EE_ASM_DIR):
	@mkdir -p $@

$(EE_OBJS_DIR):
	@mkdir -p $@

$(EE_OBJS_DIR)%.o: $(EE_SRC_DIR)%.c | $(EE_OBJS_DIR)
	@echo CC - $<
	$(DIR_GUARD)
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@

$(EE_OBJS_DIR)%.o: $(EE_SRC_DIR)%.vsm | $(EE_OBJS_DIR)
	@echo DVP - $<
	$(DIR_GUARD)
	$(EE_DVP) $< -o $@

$(EE_SRC_DIR)%.vcl: $(EE_SRC_DIR)%.vclpp | $(EE_SRC_DIR)
	@echo VCLPP - $<
	$(DIR_GUARD)
	$(EE_VCLPP) $< $@.vcl
	
$(EE_SRC_DIR)%.vsm: $(EE_SRC_DIR)%.vcl | $(EE_SRC_DIR)
	@echo VCL - $<
	$(DIR_GUARD)
	$(EE_VCL) -Isrc -g -o$@ $<

$(EE_OBJS_DIR)%.o: $(EE_ASM_DIR)%.c | $(EE_OBJS_DIR)
	@echo BIN2C - $<
	$(DIR_GUARD)
	$(EE_CC) $(EE_CFLAGS) $(EE_INCS) -c $< -o $@