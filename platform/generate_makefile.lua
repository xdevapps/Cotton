local module = {}

function module.generate_makefile(arch_str)
    local mkfile_str = [[
# Modified GNU Make project makefile autogenerated by Lua

ifndef config
  config=debug
endif

ifndef verbose
  SILENT = @
endif

.PHONY: clean prebuild

SHELLTYPE := posix
ifeq (.exe,$(findstring .exe,$(ComSpec)))
	SHELLTYPE := msdos
endif

# Configurations
# #############################################

define POSTBUILDCMDS
	@echo Amalgamating generated source files...
	../scripts/amalgamate_embedded_files.py %arch% embed
	@echo Generated embed/context__%arch%.c
endef

# File sets
# #############################################

TARGETDIR := embed obj

TARGET :=
TARGET += embed/get_context__%arch%.c
TARGET += embed/set_context__%arch%.c
TARGET += embed/swap_context__%arch%.c

# Rules
# #############################################

all: $(TARGETDIR) $(TARGET)
	@:
	@$(POSTBUILDCMDS)

$(TARGETDIR):
	@echo Creating $(TARGETDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(TARGETDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(TARGETDIR))
endif

clean:
	@echo Cleaning ContextEmbedded
ifeq (posix,$(SHELLTYPE))
	$(SILENT) rm -rf $(TARGETDIR)
else
	$(SILENT) rmdir /S /Q $(subst /,\\,$(TARGETDIR))
endif


# File Rules
# #############################################

embed/get_context__%arch%.c: get_context__%arch%.S
	@echo Compiling get_context__%arch%.S
	$(SILENT) gcc -x assembler-with-cpp -o "obj/get_context__%arch%.obj" -c "get_context__%arch%.S"
	$(SILENT) ../scripts/extract_objdump_from_file.py obj/get_context__%arch%.obj get_context__%arch% --strip-symbol
embed/set_context__%arch%.c: set_context__%arch%.S
	@echo Compiling set_context__%arch%.S
	$(SILENT) gcc -x assembler-with-cpp -o "obj/set_context__%arch%.obj" -c "set_context__%arch%.S"
	$(SILENT) ../scripts/extract_objdump_from_file.py obj/set_context__%arch%.obj set_context__%arch% --strip-symbol
embed/swap_context__%arch%.c: swap_context__%arch%.S
	@echo Compiling swap_context__%arch%.S
	$(SILENT) gcc -x assembler-with-cpp -o "obj/swap_context__%arch%.obj" -c "swap_context__%arch%.S"
	$(SILENT) ../scripts/extract_objdump_from_file.py obj/swap_context__%arch%.obj swap_context__%arch% --strip-symbol
]]

    return mkfile_str:gsub("%%arch%%", arch_str)
end

return module