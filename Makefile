VPATH = src

# Common source files
ASM_SRCS = cstartup.s
C_SRCS = pff.c diskio.c sdc.c

MODEL =
LIB_MODEL = lc-sd

INCLUDE = -I ../Calypsi-6502-Foenix/include

# Object files
OBJS = $(ASM_SRCS:%.s=obj/%.o) $(C_SRCS:%.c=obj/%.o)
OBJS_DEBUG = $(ASM_SRCS:%.s=obj/%-debug.o) $(C_SRCS:%.c=obj/%-debug.o)

obj/%.o: %.s
	as6502 --core=65c02 $(MODEL) --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%.o: %.c
	cc6502 --core=65c02 $(MODEL) $(INCLUDE) -O2 --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%-debug.o: %.s
	as6502 --core=65c02 $(MODEL) --debug --list-file=$(@:%.o=%.lst) -o $@ $<

obj/%-debug.o: %.c
	cc6502 --core=65c02 $(MODEL) $(INCLUDE) --debug --list-file=$(@:%.o=%.lst) -o $@ $<

petit-fatfs.raw:  $(OBJS)
	ln6502 -o $@ $^ linker.scm clib-65c02.a --output-format=raw --list-file=petit-fatfs.lst --cross-reference --rtattr printf=reduced --rtattr cstartup=\"petit-fatfs\"

petit-fatfs.elf: $(OBJS_DEBUG)
	ln6502 --debug -o $@ $^ linker.scm clib-65c02.a --list-file=petit-fatfs-debug.lst --cross-reference --rtattr printf=reduced --semi-hosted

clean:
	-rm $(OBJS) $(OBJS:%.o=%.lst) $(OBJS_DEBUG) $(OBJS_DEBUG:%.o=%.lst)
	-rm petit-fatfs.elf petit-fatfs.raw petit-fatfs-debug.lst petit-fatfs.lst
	-(cd $(FOENIX) ; make clean)
