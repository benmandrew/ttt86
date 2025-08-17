.PHONY: all clean run test fmt

ASMFLAGS = -f elf64 -W+all
LINKFLAGS = -static -nostdlib
SRC_DIR = src
BUILD_DIR = build
TESTS_DIR = tests
TARGET = $(BUILD_DIR)/main

SOURCES = $(wildcard $(SRC_DIR)/*.s)
OBJECTS = $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(SOURCES))
TESTS := $(wildcard $(TESTS_DIR)/test_*.exp)

all: $(TARGET)

debug: ASMFLAGS += -g -F DWARF
debug: $(TARGET)

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET)
	./$(TARGET)

test: $(TARGET)
	@echo "Running all expect tests..."
	@for t in $(TESTS); do \
		echo "Running $$t..."; \
		expect $$t || { echo "Test $$t FAILED"; exit 1; }; \
	done
	@echo "All tests passed!"

fmt:
	find -name "*.s" -exec naslint -i "{}" \;

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s | $(BUILD_DIR)
	nasm $(ASMFLAGS) -o $@ $<

$(BUILD_DIR)/main: $(OBJECTS) | $(BUILD_DIR)
	ld $(LINKFLAGS) $(OBJECTS) -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
