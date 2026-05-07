.PHONY: all clean run test fmt coverage badge

ASMFLAGS = -f elf64 -W+all
LINKFLAGS = -static -nostdlib
SRC_DIR = src
BUILD_DIR = build
TESTS_DIR = tests
TARGET = $(BUILD_DIR)/main

SOURCES = $(wildcard $(SRC_DIR)/*.s)
OBJECTS = $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(SOURCES))
TESTS := $(wildcard $(TESTS_DIR)/test_*.exp)

COVERAGE_DIR = $(BUILD_DIR)/coverage
COVERAGE_OBJECTS = $(patsubst $(SRC_DIR)/%.s,$(COVERAGE_DIR)/%.o,$(SOURCES))
COVERAGE_TARGET = $(COVERAGE_DIR)/main

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

coverage: build/coverage.json docs/coverage.svg

build/coverage.json: $(COVERAGE_TARGET)
	docs/coverage.sh $(COVERAGE_TARGET) $@

docs/coverage.svg: build/coverage.json
	@PCT=$$(grep -o '"message":"[^"]*"' build/coverage.json | grep -oE '[0-9]+' | head -1); \
	 if   [ "$$PCT" -lt 60 ]; then COLOR="#e05d44"; \
	 elif [ "$$PCT" -lt 80 ]; then COLOR="#dfb317"; \
	 elif [ "$$PCT" -lt 90 ]; then COLOR="#a4a61d"; \
	 else COLOR="#97CA00"; fi; \
	 sed -e "s/{{PCT}}/$$PCT/g" -e "s/{{COLOR}}/$$COLOR/g" \
	     docs/coverage.svg.tmpl > docs/coverage.svg
	@echo "Badge: docs/coverage.svg"

$(COVERAGE_DIR)/%.o: $(SRC_DIR)/%.s | $(COVERAGE_DIR)
	nasm $(ASMFLAGS) -g -F DWARF -o $@ $<

$(COVERAGE_TARGET): $(COVERAGE_OBJECTS) | $(COVERAGE_DIR)
	ld $(LINKFLAGS) $(COVERAGE_OBJECTS) -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s | $(BUILD_DIR)
	nasm $(ASMFLAGS) -o $@ $<

$(BUILD_DIR)/main: $(OBJECTS) | $(BUILD_DIR)
	ld $(LINKFLAGS) $(OBJECTS) -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(COVERAGE_DIR):
	mkdir -p $(COVERAGE_DIR)
