#!/bin/bash
echo "$1 $2 $3 $4"
TARGET_PRODUCT=$1
PRODUCT_OUT=$2
TARGET_BOARD_PLATFORM=$3
TARGET_ROCKCHIP_PCBATEST=$4

PCBA_PATH=external/rk-pcba-test

############################################################################################
#rk recovery contents
############################################################################################
cp -f device/rockchip/common/bin/sdtool $PRODUCT_OUT/recovery/root/sbin/
cp -f device/rockchip/common/bin/busybox $PRODUCT_OUT/recovery/root/sbin/

if [ $TARGET_ROCKCHIP_PCBATEST = "true" ];then
cp -f $PRODUCT_OUT/obj/EXECUTABLES/codec_test_intermediates/codec_test $PRODUCT_OUT/recovery/root/sbin/
cp -f $PRODUCT_OUT/obj/EXECUTABLES/pcba_core_intermediates/pcba_core $PRODUCT_OUT/recovery/root/sbin/

cp -rf $PCBA_PATH/bin/* $PRODUCT_OUT/recovery/root/sbin/
cp -rf $PCBA_PATH/res/* $PRODUCT_OUT/recovery/root/res/

echo "rk-pcba-test/res.sh $TARGET_PRODUCT $PRODUCT_OUT $TARGET_BOARD_PLATFORM"
$PCBA_PATH/res.sh $TARGET_PRODUCT $PRODUCT_OUT $TARGET_BOARD_PLATFORM
fi

