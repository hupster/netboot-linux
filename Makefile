BUILD_DIR = target

all: linux

linux:
	sudo ./setup.sh

install:
	sudo ./install.sh

clean:
	sudo rm -rf $(BUILD_DIR)

.PHONY: linux all clean
