# You can override the CFLAGS and C compiler externally,
# e.g. make PLATFORM=cortex-m3
CFLAGS += -ffreestanding -Os -Wall -Iinclude -Ilibm/common

# Just include all the source files in the build.
LIBCSRC = $(wildcard libc/*.c)

LIBMSRC = $(wildcard libm/common/*.c)
LIBMSRC += $(wildcard libm/complex/*.c)
LIBMSRC += $(wildcard libm/math/*.c)

LIBCOBJS = $(LIBCSRC:.c=.o)
LIBMOBJS = $(LIBMSRC:.c=.o)

# And the files for the test suite
TESTS_CSRC = $(wildcard tests/*_tests.c)
TESTS_OBJS = $(TESTS_CSRC:.c=)

# Some of the files uses "templates", i.e. common pieces
# of code included from multiple files.
CFLAGS += -Ilibc/templates

all: libc.a libm.a

clean:
	$(RM) $(LIBCOBJS) $(LIBMOBJS) $(TESTS_OBJS) libc.a libm.a

libc.a: $(LIBCOBJS)
	$(RM) $@
	$(AR) ru $@ $^

libm.a: $(LIBMOBJS)
	$(RM) $@
	$(AR) ru $@ $^

run_tests: $(TESTS_OBJS)
	$(foreach f,$^,$f)

tests/%: tests/%.c tests/tests_glue.c libc.a
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
