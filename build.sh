black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
brown='\033[0;33m'
blue='\033[0;34m'
purple='\033[1;35m'
cyan='\033[0;36m'
nc='\033[0m'


#Directories
KERNEL_DIR=$PWD
PRODUCT_DIR=$KERNEL_DIR/../Output
KERN_IMG=$PRODUCT_DIR/build/out/arch/arm64/boot/Image.gz-dtb
DTB=$PRODUCT_DIR/build/out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-vince.dtb
ZIP_DIR=$PRODUCT_DIR/Zipper
CONFIG_DIR=$KERNEL_DIR/arch/arm64/configs
LOG_DIR=$PRODUCT_DIR/log
OUT_DIR=$PRODUCT_DIR/build/out

#Setup directories
if [ ! -d "$PRODUCT_DIR" ]; then
  mkdir $PRODUCT_DIR
  mkdir $PRODUCT_DIR/build
  mkdir $PRODUCT_DIR/prev
  mkdir $PRODUCT_DIR/Zipper
fi

#Setup toolchains
#if [ ! -d "$TOOL_DIR" ]; then
 # mkdir $TOOL_DIR
#  git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 ../toolchains/aarch64-linux-android-4.9
 # git clone git://github.com/krasCGQ/aarch64-linux-android -b opt-gnu-8.x --depth=1 ../toolchains/#aarch64-linux-android-8.x
#fi   

cd $KERNEL_DIR

#Export
export CROSS_COMPILE_ARM32=/home/optimized_travel_planner/arm-eabi-4.7/bin/arm-eabi-
export CROSS_COMPILE=/home/optimized_travel_planner/aarch64-linux-android-8.x/bin/aarch64-opt-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="YRAHATE"
export KBUILD_BUILD_HOST="RYZEN"

#Misc
CONFIG=yr_defconfig
THREAD="-j18"

#begin functions
makekornel()
{
  BUILD_START=$(date +"%s")
  DATE=`date`
  echo -e "$brown(i) Build started at $DATE$nc"
  rm -rf $LOG_DIR
  rm -rf $KERN_IMG
  mkdir $LOG_DIR
  git log -n 100 > $LOG_DIR/Changelog.txt
  make O=$OUT_DIR $CONFIG $THREAD &>/dev/null \						     
  make O=$OUT_DIR $THREAD &>$LOG_DIR/Buildlog.txt & pid=$! \

  spin[0]="$blue-"
  spin[1]="\\"
  spin[2]="|"
  spin[3]="/$nc"

  echo -ne "$blue[Please wait...] ${spin[0]}$nc"
  while kill -0 $pid &>/dev/null
  do
    for i in "${spin[@]}"
    do
          echo -ne "\b$i"
          sleep 0.1
    done
  done
  if ! [ -a $KERN_IMG ]; then
    echo -e "\n$red(!) Kernel compilation failed, See buildlog to fix errors $nc"
    echo -e "$red#######################################################################$nc"
    #Cause i m lazy af and geenome iz goooooddd
    code $LOG_DIR/Buildlog.txt
  fi
  $DTBTOOL -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/ &>/dev/null &>/dev/null

  BUILD_END=$(date +"%s")
  DIFF=$(($BUILD_END - $BUILD_START))
  echo -e "\n$brown(i)Image-dtb compiled successfully.$nc"
  echo -e "$cyan#######################################################################$nc"
  echo -e "$purple(i) Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nc"
  echo -e "$cyan#######################################################################$nc"
}

regen_def()
{
  make O=$OUT_DIR  $CONFIG
  cp $OUT_DIR/.config $CONFIG_DIR/$CONFIG
  echo -e "$purple(i) Defconfig generated.$nc"
}

clean_sauce()
{
  rm -rf $OUT_DIR
  rm $ZIP_DIR/zImage
  rm $ZIP_DIR/UPDATE-AnyKernel3.zip
  echo -e "$purple(i) Kernel source cleaned up.$nc"
}

make_zip()
{
  cd $ZIP_DIR
  cp $KERN_IMG $ZIP_DIR/zImage
  zip -r9 UPDATE-AnyKernel3.zip *
  echo -e "$purple(i) Flashable zip generated under $ZIP_DIR.$nc"
}


#Main script
while true; do
echo -e "\n$green[1] Build Kernel"
echo -e "[2] Regenerate defconfig"
echo -e "$red[3] Source cleanup"
echo -e "$green[4] Create flashable zip"
echo -e "$green[5] Exit"
echo -ne "\n$brown(i) Please enter a choice[1-6]:$nc "

read choice

if [ "$choice" == "1" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  makekornel
fi

if [ "$choice" == "2" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  regen_def
  echo -e "$cyan#######################################################################$nc"
fi

if [ "$choice" == "3" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  clean_sauce
  echo -e "$cyan#######################################################################$nc"
fi


if [ "$choice" == "4" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  make_zip
  echo -e "$cyan#######################################################################$nc"
fi

if [ "$choice" == "5" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  exit
  echo -e "$cyan#######################################################################$nc"
fi
done
