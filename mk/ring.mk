# Copyright 2015 Brian Smith.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND BRIAN SMITH AND THE AUTHORS DISCLAIM
# ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL BRIAN SMITH OR THE AUTHORS
# BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
# DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
# AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

RING_PREFIX ?= ring/

RING_CPPFLAGS = $(RING_THREAD_FLAGS) -I$(RING_PREFIX)include -I$(GENERATED_CODE_DIR) -D_XOPEN_SOURCE=700

RING_LDLIBS = $(RING_THREAD_FLAGS) -L$(dir $(RING_LIB)) -lring-core

RING_SRCS = $(addprefix $(RING_PREFIX), \
  crypto/aes/aes.c \
  crypto/bn/add.c \
  crypto/bn/bn.c \
  crypto/bn/bn_asn1.c \
  crypto/bn/cmp.c \
  crypto/bn/convert.c \
  crypto/bn/ctx.c \
  crypto/bn/div.c \
  crypto/bn/exponentiation.c \
  crypto/bn/gcd.c \
  crypto/bn/generic.c \
  crypto/bn/montgomery.c \
  crypto/bn/mul.c \
  crypto/bn/prime.c \
  crypto/bn/random.c \
  crypto/bn/rsaz_exp.c \
  crypto/bn/shift.c \
  crypto/bytestring/cbb.c \
  crypto/bytestring/cbs.c \
  crypto/chacha/chacha.c \
  crypto/cipher/e_aes.c \
  crypto/cpu-arm.c \
  crypto/cpu-intel.c \
  crypto/crypto.c \
  crypto/curve25519/curve25519.c \
  crypto/curve25519/x25519-x86_64.c \
  crypto/ec/ec.c \
  crypto/ec/ec_curves.c \
  crypto/ec/ec_key.c \
  crypto/ec/ec_montgomery.c \
  crypto/ec/oct.c \
  crypto/ec/p256-64.c \
  crypto/ec/p256-x86_64.c \
  crypto/ec/simple.c \
  crypto/ec/util-64.c \
  crypto/ec/wnaf.c \
  crypto/ecdh/ecdh.c \
  crypto/ecdsa/ecdsa.c \
  crypto/ecdsa/ecdsa_asn1.c \
  crypto/mem.c \
  crypto/modes/gcm.c \
  crypto/poly1305/poly1305.c \
  crypto/rand/rand.c \
  crypto/rand/urandom.c \
  crypto/rsa/blinding.c \
  crypto/rsa/padding.c \
  crypto/rsa/rsa.c \
  crypto/rsa/rsa_asn1.c \
  crypto/rsa/rsa_impl.c \
  crypto/sha/sha1.c \
  crypto/sha/sha256.c \
  crypto/sha/sha512.c \
  $(NULL))

# TODO: make all .a files depend on these too.
RING_x86_SRCS = $(addprefix $(RING_PREFIX), \
  crypto/aes/asm/aes-586.pl \
  crypto/aes/asm/aesni-x86.pl \
  crypto/aes/asm/vpaes-x86.pl \
  crypto/bn/asm/x86-mont.pl \
  crypto/modes/asm/ghash-x86.pl \
  crypto/poly1305/asm/poly1305-x86.pl \
  crypto/sha/asm/sha256-586.pl \
  crypto/sha/asm/sha512-586.pl \
  $(NULL))

RING_x86_64_SRCS = $(addprefix $(RING_PREFIX), \
  crypto/aes/asm/aes-x86_64.pl \
  crypto/aes/asm/aesni-x86_64.pl \
  crypto/aes/asm/bsaes-x86_64.pl \
  crypto/aes/asm/vpaes-x86_64.pl \
  crypto/bn/asm/rsaz-avx2.pl \
  crypto/bn/asm/x86_64-mont.pl \
  crypto/bn/asm/x86_64-mont5.pl \
  crypto/chacha/asm/chacha-x86_64.pl \
  crypto/curve25519/asm/x25519-asm-x86_64.S \
  crypto/ec/asm/p256-x86_64-asm.pl \
  crypto/modes/asm/aesni-gcm-x86_64.pl \
  crypto/modes/asm/ghash-x86_64.pl \
  crypto/poly1305/asm/poly1305-x86_64.pl \
  crypto/rand/asm/rdrand-x86_64.pl \
  crypto/sha/asm/sha256-x86_64.pl \
  crypto/sha/asm/sha512-x86_64.pl \
  $(NULL))

RING_ARM_SHARED_SRCS = \
  crypto/aes/asm/aesv8-armx.pl \
  crypto/cpu-arm-asm.S \
  $(NULL)

RING_arm_SRCS = $(addprefix $(RING_PREFIX), \
  crypto/aes/asm/aes-armv4.pl \
  crypto/aes/asm/bsaes-armv7.pl \
  crypto/bn/asm/armv4-mont.pl \
  crypto/chacha/asm/chacha-armv4.pl \
  crypto/curve25519/asm/x25519-asm-arm.S \
  crypto/modes/asm/ghash-armv4.pl \
  crypto/poly1305/asm/poly1305-armv4.pl \
  crypto/sha/asm/sha256-armv4.pl \
  crypto/sha/asm/sha512-armv4.pl \
  $(RING_ARM_SHARED_SRCS) \
  $(NULL))

RING_aarch64_SRCS = $(addprefix $(RING_PREFIX), \
  crypto/bn/asm/armv8-mont.pl \
  crypto/chacha/asm/chacha-armv8.pl \
  crypto/modes/asm/ghashv8-armx.pl \
  crypto/poly1305/asm/poly1305-armv8.pl \
  crypto/sha/asm/sha256-armv8.pl \
  crypto/sha/asm/sha512-armv8.pl \
  $(RING_ARM_SHARED_SRCS) \
  $(NULL))

ifeq ($(TARGET_SYS),none)
RING_THREAD_FLAGS += -DOPENSSL_TRUSTY=1 -DOPENSSL_NO_THREADS=1
RING_SRCS += $(addprefix $(RING_PREFIX), crypto/thread_none.c)
else
RING_THREAD_FLAGS += -pthread
RING_SRCS += $(addprefix $(RING_PREFIX), crypto/thread_pthread.c)
endif

RING_ASM_OBJS = \
  $(addprefix $(OBJ_PREFIX), \
    $(patsubst %.pl, %.o, \
      $(patsubst %.S, %.o, $(RING_$(TARGET_ARCH_NORMAL)_SRCS))))

$(RING_ASM_OBJS): CPPFLAGS += -I$(RING_PREFIX)crypto

RING_OBJS = $(addprefix $(OBJ_PREFIX), $(patsubst %.c, %.o, $(RING_SRCS)))

ifeq ($(NO_ASM),)
RING_OBJS += $(RING_ASM_OBJS)
else
RING_CPPFLAGS += -DOPENSSL_NO_ASM=1
endif

RING_LIB = $(LIB_PREFIX)libring-core.a

# Recent versions of Linux have the D flag for deterministic builds, but Darwin
# (at least) doesn't. Accroding to Debian's documentation, binutils is built
# with --enable-determnistic-archives by default and we shouldn't need to
# worry about it.
$(RING_LIB): ARFLAGS = crs
$(RING_LIB): $(RING_OBJS) $(RING_PREFIX)mk/ring.mk
	$(RM) $@
	$(AR) $(ARFLAGS) $@ $(filter-out $(RING_PREFIX)mk/ring.mk, $^)

RING_TEST_LIB_SRCS = \
  crypto/test/bn_test_convert.c \
  crypto/test/bn_test_lib.c \
  crypto/test/file_test.cc \
  crypto/test/malloc.cc \
  crypto/test/test_util.cc \
  $(NULL)

RING_TEST_LIB_OBJS = $(addprefix $(OBJ_PREFIX), \
  $(patsubst %.c, %.o, \
  $(patsubst %.cc, %.o, \
  $(RING_TEST_LIB_SRCS))))

RING_TEST_MAIN_SRCS = $(addprefix $(RING_PREFIX), \
  crypto/aes/aes_test.cc \
  crypto/bn/bn_test.cc \
  crypto/bytestring/bytestring_test.cc \
  crypto/chacha/chacha_test.cc \
  crypto/constant_time_test.c \
  crypto/ecdsa/ecdsa_test.cc \
  crypto/poly1305/poly1305_test.cc \
  crypto/rsa/rsa_test.cc \
  crypto/thread_test.c \
  $(NULL))

RING_TEST_MAIN_OBJS = $(addprefix $(OBJ_PREFIX), \
  $(patsubst %.c, %.o, \
  $(patsubst %.cc, %.o, \
  $(RING_TEST_MAIN_SRCS))))

RING_TEST_EXES = $(RING_TEST_MAIN_OBJS:$(OBJ_PREFIX)%.o=$(EXE_PREFIX)%)

ifeq ($(TARGET_SYS),none)
$(RING_TEST_EXES): LDLIBS += --specs=rdimon.specs
endif
$(RING_TEST_EXES): LDLIBS += $(RING_LDLIBS)
$(RING_TEST_EXES): $(EXE_PREFIX)% : \
  $(OBJ_PREFIX)%.o \
  $(RING_LIB) \
  $(RING_TEST_LIB_OBJS) \
  $(NULL)
	$(CXX) $(filter-out $(RING_LIB),$^) $(LDFLAGS) $(LDLIBS) $(TARGET_ARCH) -o $@

# TODO: Fix the code so -Wno- overrides are not needed.
$(RING_OBJS) \
$(RING_TEST_LIB_OBJS) \
$(RING_TEST_MAIN_OBJS) \
$(NULL): CPPFLAGS += $(RING_CPPFLAGS) \
                     -DBORINGSSL_IMPLEMENTATION \
                     -fno-strict-aliasing \
                     -fvisibility=hidden \
                     -Wno-cast-align \
                     $(NULL)

PERLASM_LIB_SRCS = $(addprefix $(RING_PREFIX), \
  crypto/perlasm/arm-xlate.pl \
  crypto/perlasm/x86asm.pl \
  crypto/perlasm/x86gas.pl \
  crypto/perlasm/x86masm.pl \
  crypto/perlasm/x86nasm.pl \
  crypto/perlasm/x86_64-xlate.pl \
  $(NULL))

PERL_EXECUTABLE ?= perl

# The British spelling "flavour" is used for consistency with perlasm's code.
ifeq ($(findstring darwin,$(TARGET_SYS)),darwin)
PERLASM_FLAVOUR ?= macosx
else ifeq ($(TARGET_ARCH_NORMAL),aarch64)
PERLASM_FLAVOUR ?= linux64
else ifeq ($(TARGET_ARCH_NORMAL),arm)
PERLASM_FLAVOUR ?= linux32
else
PERLASM_FLAVOUR ?= elf
endif

PERLASM_x86_ARGS = -fPIC -DOPENSSL_IA32_SSE2
PERLASM_ARGS = $(PERLASM_FLAVOUR) $(PERLASM_$(TARGET_ARCH_NORMAL)_ARGS)

$(OBJ_PREFIX)%.S: %.pl $(PERLASM_LIB_SRCS)
	${PERL_EXECUTABLE} $< $(PERLASM_ARGS) > $@
