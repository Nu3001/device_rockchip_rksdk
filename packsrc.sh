#!/bin/bash

# file   : packsrc.sh
# usage  : packsrc.sh -p [rk2928,rk3066,rk3168,rk3188] [-r]
#           -r - for recover files
# author : Cody Xie
# modify : 2013-03-29 created.
#          2013-04-01 tested on rk2928 android 4.2 sdk
# TODO   : test for 4.1 and other platform, add support bin

# tar all source code exclude prebuilt libraries
which git > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "git does not exist"
    exit 1
fi

which sed > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "sed does not exist"
    exit 1
fi

which tar > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "tar does not exist"
    exit 1
fi

RECOVER_ONLY=0
# check all parameters
if [ $# -lt 1 ] ; then
    echo "usage : $0 -p [rk2928,rk3066,rk3026,rk3168,rk3188] [-r]"
    echo "        -r - for recover files"
    exit 1
else
    while getopts "p:rv:" arg
    do
        case $arg in
        p)
        TARGET_PLATFORM=$OPTARG
        ;;
#        v)
#        TARGET_VERSION=$OPTARG
#        ;;
        r)
        RECOVER_ONLY=1
        ;;
        \?)
        echo "usage : $0 -p [rk2928,rk3066,rk3026,rk3168,rk3188] [-r]"
        echo "        -r - for recover files"
        exit 1
        ;;
        esac
    done
    case $TARGET_PLATFORM in
    "rk3188")
    TARGET_PRODUCT=rk30sdk
    TARGET_BOARD=rk30board
    ;;
    "rk3066")
    TARGET_PRODUCT=rk30sdk
    TARGET_BOARD=rk30board
    ;;
    "rk3026")
    TARGET_PRODUCT=rk30sdk
    TARGET_BOARD=rk30board
    ;;
    "rk3168")
    TARGET_PRODUCT=rk30sdk
    TARGET_BOARD=rk30board
    ;;
    "rk2928")
    TARGET_PRODUCT=rk2928sdk
    TARGET_BOARD=rk2928board
    ;;
	*)
	echo "usage : $0 -p [rk2928,rk3066,rk3026,rk3168,rk3188] [-r]"
    echo "        -r - for recover files"
    exit 1
    ;;
    esac
fi

echo "======================================================"
echo "patching $TARGET_PRODUCT $TARGET_BOARD $TARGET_VERSION"
echo "======================================================"

TOPDIR=$PWD
TARGET_OUT=out/target/product/$TARGET_PRODUCT
COMMON_PATH=device/rockchip/common

source $TOPDIR/build/envsetup.sh > /dev/null 2>&1

LIBSRCDIRS=(
hardware/rk29/hwcomposer_rga
hardware/rk29/libgralloc_ump
hardware/rk29/libyuvtorgb
frameworks/base/libs/hwui
frameworks/native/libs/gui
frameworks/av/libvideoeditor
frameworks/base/media/jni/mediaeditor
)

OUTLIBPATHS=(
system/lib
)

AUTOMKDIRS=(
$COMMON_PATH/proprietary/lib
$COMMON_PATH/proprietary/bin
)

EXCLUDEDIRS=(.git .repo)

function get_soarray () {
    if [ ${#LIBSRCDIRS[*]} -eq 0 ] ; then 
        return 1
    fi
    [ ! -e _tmp ] || rm -f _tmp
    for d in ${LIBSRCDIRS[*]}
    do
        pushd $d > /dev/null 2>&1
        grep BUILD_SHARED_LIBRARY * -rl | xargs grep LOCAL_MODULE[^_] -r >> $TOPDIR/_tmp
        popd > /dev/null 2>&1 
    done

    sed -i "s/\$(TARGET_BOARD_HARDWARE)/"$TARGET_BOARD"/g" $TOPDIR/_tmp
    sed -i 's/.*=//g' $TOPDIR/_tmp
    sed -i 's/^[ ]*//g' $TOPDIR/_tmp
    sed -i 's/*[ ]$//g' $TOPDIR/_tmp
    sed -i 's/$/.so/g' $TOPDIR/_tmp

    echo `cat $TOPDIR/_tmp`
    rm -f _tmp
}

function get_binarray () {
    if [ ${#LIBSRCDIRS[*]} -eq 0 ] ; then
        return 1
    fi
    [ ! -e _tmp ] || rm -f _tmp
    for d in ${LIBSRCDIRS[*]}
    do
        pushd $d > /dev/null 2>&1
        grep BUILD_SHARED_LIBRARY * -rl | xargs grep LOCAL_MODULE[^_] -r >> $TOPDIR/_tmp
        popd > /dev/null 2>&1
    done

    sed -i "s/\$(TARGET_BOARD_HARDWARE)/"$TARGET_BOARD"/g" $TOPDIR/_tmp
    sed -i 's/.*=//g' $TOPDIR/_tmp
    sed -i 's/^[ ]*//g' $TOPDIR/_tmp
    sed -i 's/*[ ]$//g' $TOPDIR/_tmp
    sed -i 's/$/.so/g' $TOPDIR/_tmp

    echo `cat $TOPDIR/_tmp`
    rm -f _tmp
}

function checkout_file () {
    echo "checking out files..."
    for d in ${LIBSRCDIRS[*]}
    do
        pushd $d > /dev/null
        git checkout -f
        popd > /dev/null
    done
}

function rebuild_files () {
    local dedicated=$1

    if [ "$dedicated" == "dedicated" ] ; then
        sed -i '/BOARD_USE_LCDC_COMPOSER/c BOARD_USE_LCDC_COMPOSER ?= true' device/rockchip/$TARGET_PRODUCT/BoardConfig.mk
        for d in ${LIBSRCDIRS[*]}
        do
            pushd $d
            mm -B
            popd
        done
    else
        sed -i '/BOARD_USE_LCDC_COMPOSER/c BOARD_USE_LCDC_COMPOSER ?= false' device/rockchip/$TARGET_PRODUCT/BoardConfig.mk
        for d in ${LIBSRCDIRS[*]}
        do
            pushd $d
            mm -B
            popd
        done
    fi

}

function get_so_outpath () {
    local libs=(`echo $@`)
    cd $TARGET_OUT > /dev/null 2>&1
    for lib in ${libs[*]}
    do
        for d in $OUTLIBPATHS
        do
            pushd $TOPDIR/$TARGET_OUT/$d > /dev/null 2>&1
            echo $d`find -name $lib | sed -e 's/^\.//g'` | grep $lib
            popd > /dev/null 2>&1
        done
    done
    cd - > /dev/null 2>&1
}

function make_dir () {
    [ -d $COMMON_PATH/proprietary/lib/osmem ] || mkdir -p $COMMON_PATH/proprietary/lib/osmem
    [ -d $COMMON_PATH/proprietary/lib/dedicated ] || mkdir -p $COMMON_PATH/proprietary/lib/dedicated
    [ -d $COMMON_PATH/proprietary/bin ] || mkdir -p $COMMON_PATH/proprietary/bin
}

function copy_libs () {
    local dedicated=$1
    shift
    local so_libs=(`echo $@`)

    make_dir

    for so in ${so_libs[*]}
    do
        if [ "$dedicated" != "dedicated" ] ; then
            cp -f $TARGET_OUT/$so $COMMON_PATH/proprietary/lib/osmem
        else
            cp -f $TARGET_OUT/$so $COMMON_PATH/proprietary/lib/dedicated
        fi
    done
}

function generate_mk () {
    local dedicated1=$1
    shift
    local so_paths=(`echo $@`)

    echo "# File   : AUTO GENERATED MAKE FILE"
    echo "# Date   : `date`"
    echo "# Author : `whoami`"
    echo "# ==============================================="

    echo "LOCAL_PATH := \$(call my-dir)"
    if [ "$dedicated1" == "dedicated" ] ; then
        echo "ifeq (\$(strip \$(BOARD_USE_LCDC_COMPOSER)), true)"
    else
        echo "ifeq (\$(strip \$(BOARD_USE_LCDC_COMPOSER)), false)"
    fi
    local i=0
    for so in ${so_paths[*]}
    do
        echo ""
        echo "include \$(CLEAR_VARS)"
        echo "LOCAL_PREBUILT_LIBS := `basename ${so_paths[$i]}`"
        echo "LOCAL_MODULE_PATH := \$(PRODUCT_OUT)/`dirname ${so_paths[$i]}`"
        echo "LOCAL_MODULE_TAGS := optional"
        echo "include \$(BUILD_MULTI_PREBUILT)"
        echo ""
        i=$(($i+1))
    done
    echo "endif"
    echo ""
}

function generate_copy_mk () {
    local so_libs2=(`echo $@ | sed -e 's/system.*\.so//g'`)

    for arg in $@
    do
        echo $arg | grep "system"
    done > tmp
    local so_paths=(`cat tmp`)
    rm -f tmp

    echo "# File   : AUTO GENERATED MAKE FILE"
    echo "# Date   : `date`"
    echo "# Author : `whoami`"
    echo "# ==============================================="

    echo "ifeq (\$(strip \$(BOARD_USE_LCDC_COMPOSER)), true)"
    echo "PRODUCT_COPY_FILES += \\"
    i=0
    for so in ${so_libs2[*]}
    do
        echo "${so_paths[$i]}" | grep -q "$so"
        if [ $? -eq 0 ] ; then
            if [ $i -lt $((${#so_libs2[*]} - 1)) ] ; then
            echo "  $COMMON_PATH/proprietary/lib/dedicated/$so:${so_paths[$i]}    \\"
            else
            echo "  $COMMON_PATH/proprietary/lib/dedicated/$so:${so_paths[$i]}"
            fi
        else
            echo "$COMMON_PATH/proprietary/lib/dedicated/$so does not exist!!!"
        fi
        i=$(($i + 1))
    done
    echo ""
    echo "else"
    echo "PRODUCT_COPY_FILES += \\"
    i=0
    for so in ${so_libs2[*]}
    do
        echo "${so_paths[$i]}" | grep -q "$so"
        if [ $? -eq 0 ] ; then
            if [ $i -lt $((${#so_libs2[*]} - 1)) ] ; then
            echo "  $COMMON_PATH/proprietary/lib/osmem/$so:${so_paths[$i]}    \\"
            else
            echo "  $COMMON_PATH/proprietary/lib/osmem/$so:${so_paths[$i]}"
            fi
        else
            echo "$COMMON_PATH/proprietary/lib/osmem/$so does not exist!!!"
        fi
        i=$(($i + 1))
    done
    echo "endif"
    echo ""
}

function modify_device_mk () {
    local mk=$1

    sed -i '/rk_proprietary/d' $mk
    sed -i '$a\include '$COMMON_PATH'\/proprietary\/rk_proprietary\.mk' $mk
}

function recover_files () {
    rm -f _tmp
    rm -rf $COMMON_PATH/proprietary/
    sed -i '/rk_proprietary/d' $TOPDIR/device/rockchip/$TARGET_PRODUCT/device.mk
    [ -d out ] || mv ../rkTmpOut out
    checkout_file
}

function tar_all () {
    set -x

    cd $TOPDIR/kernel
    ./pack-kernel.sh $TARGET_PLATFORM
    cd $TOPDIR

    .repo/repo/repo manifest -r -o version-tag.xml

    mv out ../rkTmpOut
    mv kernel ../rkTmpKernel
    tar zxvf kernel.tar.gz kernel/
    mv kernel.tar* ../

    for d in ${LIBSRCDIRS[*]}
    do
        pushd $d
        find -regex '.*\.\(c\|cpp\|cxx\|mk\)' | xargs rm -f
        popd
    done

    rm -f ../_tmp
    for d in ${EXCLUDEDIRS[*]}
    do
        echo "--exclude=$d " >> ../_tmp
    done
    local excludes=(`cat ../_tmp`)
    tar -zcf ../"$TARGET_PLATFORM"_release.tar ${excludes[*]} --exclude=device/rockchip/rk29sdk/asound-for-rt5625.conf.bak  ../`basename $TOPDIR`
    rm -f ../_tmp

    rm -r kernel
    mv ../rkTmpOut out
    mv ../rkTmpKernel kernel
    set +x
}


function my_main () {
    recover_files
    if [ $RECOVER_ONLY -eq 1 ] ; then
        exit;
    fi

    so_array=(`get_soarray`)
    if [ $? -eq 1 ] ; then
        echo "no file"
        exit 1
    fi
    so_paths=(`get_so_outpath ${so_array[*]}`)

    local original=`sed -n "/BOARD_USE_LCDC_COMPOSER/p" device/rockchip/$TARGET_PRODUCT/BoardConfig.mk`
    echo "ORIGNAL is $original"
#   TODO : add support bin
    if [ "$TARGET_PLATFORM" == "rk3188" ] ; then
        rebuild_files "dedicated"
        copy_libs "dedicated" ${so_paths[*]}
    fi
    rebuild_files "osmem"
    copy_libs "osmem" ${so_paths[*]}
    sed -i "/BOARD_USE_LCDC_COMPOSER/c $original" device/rockchip/$TARGET_PRODUCT/BoardConfig.mk

    generate_copy_mk ${so_array[*]} ${so_paths[*]} > $COMMON_PATH/proprietary/rk_proprietary.mk

    if [ "$TARGET_PLATFORM" == "rk3188" ] ; then
        #generate_mk "dedicated" ${so_array[*]} > $COMMON_PATH/proprietary/lib/dedicated/Android.mk
        generate_mk "dedicated" ${so_paths[*]} > $COMMON_PATH/proprietary/lib/dedicated/Android.mk
    fi
    #generate_mk "osmem" ${so_array[*]} > $COMMON_PATH/proprietary/lib/osmem/Android.mk
    generate_mk "osmem" ${so_paths[*]} > $COMMON_PATH/proprietary/lib/osmem/Android.mk

    modify_device_mk $TOPDIR/device/rockchip/$TARGET_PRODUCT/device.mk

    tar_all
}


my_main

