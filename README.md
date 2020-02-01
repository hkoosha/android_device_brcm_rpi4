## LineageOS 16.0 device configuration for [Raspberry Pi 4](https://github.com/02047788a/build-lineageOS-for-raspberry-pi).


### 修正問題
1. lunch lineage_rpi4-userdebug 找不到 device [參考](https://source.android.com/setup/develop/new-device#build-a-product)
2. 修正wifi無法正常運作
3. 修正bluetooth無法正常運作

### 已知問題
1. 重開機後Apps Icon會不見
2. 無法adb連線
> error: device unauthorized. \
This adbd's $ADB_VENDOR_KEYS is not set; try 'adb kill-server' if that seems wrong. \
Otherwise check for a confirmation dialog on your device.
3. 無法root進入系統