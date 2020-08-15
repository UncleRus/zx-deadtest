BUILDDIR = build
TARGET = tester48
ROMSIZE = 16384
SRC_MAIN = deadtest.S
SRCS := const.S deadtest.S

PREFIX = z80-unknown-coff-

AS = $(PREFIX)as
OBJCOPY = $(PREFIX)objcopy
OBJDUMP = $(PREFIX)objdump
FUSE = fuse-gtk

ASFLAGS = -z80 -I. -ignore-unportable-instructions
OBJCOPY_FLAGS = -O binary
OBJDUMP_FLAGS = -d -mz80
FUSE_FLAGS = -g hq3x

ELF := $(BUILDDIR)/$(TARGET).elf
BIN := $(BUILDDIR)/$(TARGET).bin
ROM := $(BUILDDIR)/$(TARGET).rom
LSS := $(BUILDDIR)/$(TARGET).lss

.PHONY: all clean fuse

all: $(BIN) $(ROM) $(LSS)

clean:
	@rm -rf $(BUILDDIR)/*

$(BUILDDIR):
	@mkdir $(BUILDDIR)
	
$(ELF): $(BUILDDIR) $(SRCS)
	$(AS) $(ASFLAGS) $(SRC_MAIN) -o $(ELF)

$(BIN): $(ELF)
	$(OBJCOPY) $(ELF) $(OBJCOPY_FLAGS) $(BIN)
	
$(ROM): $(BIN)
	$(eval filesize := $(shell stat -c "%s" $(BIN)))
	@echo Binary size: $(filesize)
	@cp $(BIN) $(ROM)
	@dd if=/dev/zero ibs=1 count="$$(($(ROMSIZE) - $(filesize)))" 2>/dev/null | tr "\000" "\377" >> $(ROM)

$(LSS): $(ELF)
	$(OBJDUMP) $(OBJDUMP_FLAGS) $(ELF) > $(LSS)

fuse: $(ROM)
	$(FUSE) $(FUSE_FLAGS) --rom-48 $(ROM)
