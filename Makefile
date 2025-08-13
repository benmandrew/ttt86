.PHONY: all clean

ASMFLAGS = -f elf64 -W+all
LINKFLAGS =
BUILD_DIR = build

all: $(BUILD_DIR)/main

$(BUILD_DIR)/main.o: main.s | $(BUILD_DIR)
	nasm $(ASMFLAGS) -o $@ main.s

$(BUILD_DIR)/main: $(BUILD_DIR)/main.o | $(BUILD_DIR)
	ld $(LINKFLAGS) $< -o $(BUILD_DIR)/main

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)
