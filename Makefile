.PHONY: all clean run

ASMFLAGS = -f elf64 -W+all
LINKFLAGS = -static
SRC_DIR = src
BUILD_DIR = build

SOURCES = $(wildcard $(SRC_DIR)/*.s)
OBJECTS = $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(SOURCES))

all: $(BUILD_DIR)/main

debug: ASMFLAGS += -g -F DWARF
debug: $(BUILD_DIR)/main

clean:
	rm -rf $(BUILD_DIR)

run: $(BUILD_DIR)/main
	./$(BUILD_DIR)/main

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s | $(BUILD_DIR)
	nasm $(ASMFLAGS) -o $@ $<

$(BUILD_DIR)/main: $(OBJECTS) | $(BUILD_DIR)
	ld $(LINKFLAGS) $(OBJECTS) -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
