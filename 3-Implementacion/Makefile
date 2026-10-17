ROOT := $(abspath .)

MAIN := main

SRC_DIR     := $(ROOT)/src
INCLUDE_DIR := $(ROOT)/include
TEST_DIR    := $(ROOT)/test
BUILD_DIR   := $(ROOT)/build
GNAT_ADC    := $(ROOT)/gnat.adc

GNATMAKE := sparc-ork-gnatmake
NM       := sparc-ork-nm
SIZE     := sparc-ork-size

BF :=
GF := -g
LF := -k -specs ork_specs -mcpu=cypress

LF_LINK_FILE := -Xlinker -Map -Xlinker $(BUILD_DIR)/$(MAIN).map

SOURCES = $(wildcard $(SRC_DIR)/*.adb) $(wildcard $(INCLUDE_DIR)/*.ads)

TEST_SOURCES = $(wildcard $(TEST_DIR)/*.adb)
TEST_TARGETS = $(patsubst $(TEST_DIR)/%.adb,$(BUILD_DIR)/%,$(TEST_SOURCES))

.PHONY: all clean force

all: $(BUILD_DIR)/$(MAIN) $(TEST_TARGETS)

$(BUILD_DIR)/$(MAIN): $(SOURCES) $(GNAT_ADC) | $(BUILD_DIR)/gnat.adc
	cd $(BUILD_DIR) && $(GNATMAKE) $(SRC_DIR)/$(MAIN).adb \
		-I$(SRC_DIR) -I$(INCLUDE_DIR) -o $(MAIN) \
		-cargs $(GF) -bargs $(BF) -largs $(LF) $(LF_LINK_FILE)
	$(NM) $@ > $@.nm
	$(SIZE) $@

$(BUILD_DIR)/%: $(TEST_DIR)/%.adb $(SOURCES) $(GNAT_ADC) | $(BUILD_DIR)/gnat.adc
	cd $(BUILD_DIR) && $(GNATMAKE) $< \
		-I$(SRC_DIR) -I$(INCLUDE_DIR) -I$(TEST_DIR) -o $(notdir $@) \
		-cargs $(GF) -bargs $(BF) -largs $(LF)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/gnat.adc: $(GNAT_ADC) | $(BUILD_DIR)
	cp $< $@

clean: force
	@rm -rf $(BUILD_DIR)/*.o $(BUILD_DIR)/*.nm $(BUILD_DIR)/*.ali \
		$(BUILD_DIR)/b~*.* $(BUILD_DIR)/*.s $(BUILD_DIR)/*~ \
		$(BUILD_DIR)/$(MAIN) $(BUILD_DIR)/*.map \
		$(BUILD_DIR)/gnat.adc $(TEST_TARGETS) $(BUILD_DIR)/*

force:
