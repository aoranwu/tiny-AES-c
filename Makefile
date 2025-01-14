#CC           = avr-gcc
#CFLAGS       = -Wall -mmcu=atmega16 -Os -Wl,-Map,test.map
#OBJCOPY      = avr-objcopy
CC           = gcc
LD           = gcc
AR           = ar
ARFLAGS      = rcs
CFLAGS       = -Wall -Os -c
LDFLAGS      = -Wall -Os -Wl,-Map,test.map
ifdef AES192
CFLAGS += -DAES192=1
endif
ifdef AES256
CFLAGS += -DAES256=1
endif

OBJCOPYFLAGS = -j .text -O ihex
OBJCOPY      = objcopy

# include path to AVR library
INCLUDE_PATH = /usr/lib/avr/include
# splint static check
SPLINT       = splint test.c aes.c -I$(INCLUDE_PATH) +charindex -unrecog

default: test.elf

.SILENT:
.PHONY:  lint clean

test.hex : test.elf
	echo copy object-code to new image and format in hex
	$(OBJCOPY) ${OBJCOPYFLAGS} $< $@

get_roofline.o : get_roofline.c aes.h aes.o
	echo [CC] $@ $(CFLAGS)
	$(CC) $(CFLAGS) -o  $@ $<

get_std_roofline.o : get_std_roofline.c aes.h aes.o
	echo [CC] $@ $(CFLAGS)
	$(CC) $(CFLAGS) -o  $@ $<

get_blx_roofline.o : get_blx_roofline.c aes.h aes.o
	echo [CC] $@ $(CFLAGS)
	$(CC) $(CFLAGS) -o  $@ $<

test.o : test.c aes.h aes.o
	echo [CC] $@ $(CFLAGS)
	$(CC) $(CFLAGS) -o  $@ $<

aes.o : aes.c aes.h
	echo [CC] $@ $(CFLAGS)
	$(CC) $(CFLAGS) -o $@ $<

test.elf : aes.o test.o
	echo [LD] $@
	$(LD) $(LDFLAGS) -o $@ $^

get_roofline : aes.o get_roofline.o
	echo [LD] $@
	$(LD) $(LDFLAGS) -o $@ $^

get_std_roofline : aes.o get_std_roofline.o
	echo [LD] $@
	$(LD) $(LDFLAGS) -o $@ $^

get_blx_roofline : aes.o get_blx_roofline.o
	echo [LD] $@
	$(LD) $(LDFLAGS) -o $@ $^

aes.a : aes.o
	echo [AR] $@
	$(AR) $(ARFLAGS) $@ $^

lib : aes.a

roofline: get_roofline

std_roofline: get_std_roofline

blx_roofline: get_blx_roofline


clean:
	rm -f *.OBJ *.LST *.o *.gch *.out *.hex *.map *.elf *.a

test:
	make clean && make && ./test.elf
	make clean && make AES192=1 && ./test.elf
	make clean && make AES256=1 && ./test.elf

lint:
	$(call SPLINT)
