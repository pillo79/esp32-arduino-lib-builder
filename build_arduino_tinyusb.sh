#/bin/bash

if ! idf.py --version >& /dev/null ; then
       cat > /dev/stderr << EOF
ERROR: This script requires a full Espressif IDF install.
Suggested use:

	sudo docker run -it --rm -v \$PWD:/project -w /project espressif/idf:v4.4 $0

EOF
	exit 1
fi

source ./tools/config.sh

TINYUSB_REPO_URL="https://github.com/hathach/tinyusb.git"
TINYUSB_REPO_DIR="$AR_COMPS/arduino_tinyusb/tinyusb"

#
# CLONE/UPDATE TINYUSB
#
echo "Updating TinyUSB..."
if [ ! -d $TINYUSB_REPO_DIR ]; then
	git clone $TINYUSB_REPO_URL $TINYUSB_REPO_DIR
else
	git -C $TINYUSB_REPO_DIR fetch && \
	git -C $TINYUSB_REPO_DIR pull --ff-only
fi
if [ $? -ne 0 ]; then exit 1; fi

# generate ninja files
./build.sh -t esp32s3 -b reconfigure -s

# compile and extract library
TINYUSB_LIB_FILE=esp-idf/arduino_tinyusb/libarduino_tinyusb.a
(cd build && ninja $TINYUSB_LIB_FILE && cp $TINYUSB_LIB_FILE ..)
