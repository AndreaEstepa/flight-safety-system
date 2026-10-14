MAIN = main
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
TEST_DIR = test

GNATMAKE = sparc-ork-gnatmake
SIZE = sparc-ork-size
NM = sparc-ork-nm

GF = -g
BF =
LF = -k -specs ork_specs -mcpu=cypress

MAIN_SRC = $(SRC_DIR)/$(MAIN).adb
TARGET = $(BUILD_DIR)/$(MAIN)
MAP_FILE = $(BUILD_DIR)/$(MAIN).map
NM_FILE = $(BUILD_DIR)/$(MAIN).nm
GNAT_ADC = gnat.adc

.PHONY: all clean force

all: $(TARGET)

$(TARGET): \
	$(wildcard $(SRC_DIR)/*.adb) \
	$(wildcard $(INCLUDE_DIR)/*.ads) \
	$(wildcard $(TEST_DIR)/*.adb) \
	$(GNAT_ADC) | $(BUILD_DIR)
	$(GNATMAKE) $(MAIN_SRC) -I$(SRC_DIR) -I$(INCLUDE_DIR) -D $(BUILD_DIR) -o $(TARGET) -cargs $(GF) -bargs $(BF) -largs $(LF) -Xlinker -Map -Xlinker $(MAP_FILE)
	$(NM) $(TARGET) > $(NM_FILE)
	$(SIZE) $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean: force
	@rm -f $(BUILD_DIR)

force:
