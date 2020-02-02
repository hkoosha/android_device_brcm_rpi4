## LineageOS 16.0 device configuration for [Raspberry Pi 4](https://github.com/02047788a/build-lineageOS-for-raspberry-pi).

### 說明
這是LineageOS 16.0 使用 Raspberry Pi 4 的編譯設定環境，相關說明和操作[參考](https://github.com/02047788a/build-lineageOS-for-raspberry-pi)

### **操作說明文件**
+ [如何下載LineageOS程式碼](./documents/sync-lineageos-code.md)
  + 執行腳本輸入提示
    - branch: **lineage-16.0**
    - device name: **rpi4**
  ```bash
  #自動化下載腳本
  $ wget https://raw.githubusercontent.com/02047788a/build-lineageOS-rpi3/master/scripts/sync-lineageos-code.sh -O sync-lineageos-code.sh
  # 執行腳本輸入提示
  # Please entry lineageOS checkout folder : /home/Downlaods/LineageOS-16.0  (your source folder)
  # Please entry checkout lineageOS branch : lineage-16.0 
  # Please entry build device name(ex:,rpi3,rpi4) : rpi4
  ```
  > 輸入的變數都存在~/.profile 裡面 (**$LINEAGE_SRC, $LINEAGE_BRANCH, $DEVICE_NAME**)

+ [如何編譯LineageOS程式碼](./documents/build-lineageos-code.md)
    ```bash
    # 下載腳本到程式碼目錄
    $ wget https://raw.githubusercontent.com/02047788a/build-lineageOS-rpi3/master/scripts/build-lineageos-code.sh -O build-lineageos-code.sh
    $ sudo ./build-lineageos-code.sh #編譯全部映像kernel ramdisk systemimage vendorimage
    ```
    > 編譯後產生可安裝的image路徑: \$LINEAGE_SRC/out/target/product/rpi4/*lineage-16.0-20200201-rpi4.img**
+ 燒錄映像到SD卡
    ```bash
    $ sudo dd if=lineage-16.0-20200201-rpi4.img of=/dev/sdX status=progress bs=4M
    ```
    > /dev/sdX 是你SD卡的路徑，注意要改阿!!!

### 修正問題
1. lunch lineage_rpi4-userdebug 找不到 device [參考官方](https://source.android.com/setup/develop/new-device#build-a-product) 
   - 新增[AndroidProducts.mk](AndroidProducts.mk)檔案定義**COMMON_LUNCH_CHOICES**
2. bootloader 無法載入zImage (linux kernel)
   - 修改[config.txt](boot/config.txt)不要用位址的方式去定位zImage
3. 修正wifi無法正常運作
   - 修改[rpi4.mk](rpi4.mk) 編譯時指定wifi需要用到的packages
       ``` bash
       # WIFI
       PRODUCT_PACKAGES += \
        android.hardware.wifi@1.0-service \
        hostapd \
        wpa_supplicant
        ```
   - 修改[init.rpi4.rc](ramdisk/init.rpi4.rc) 啟動wpa_supplicant 參數
        ```bash
        service wpa_supplicant /vendor/bin/hw/wpa_supplicant \
            -O/data/vendor/wifi/wpa/sockets \
            -g@android:wpa_wlan0
            interface android.hardware.wifi.supplicant@1.0::ISupplicant default
            interface android.hardware.wifi.supplicant@1.1::ISupplicant default
            class main
            socket wpa_wlan0 dgram 660 wifi wifi
            disabled
            oneshot
        ``` 
   - 修改[manifest.xml](manifest.xml) 載入wifi相關packages
        ```xml
        <hal format="hidl">
                <name>android.hardware.wifi</name>
                <transport>hwbinder</transport>
                <version>1.2</version>
                <interface>
                    <name>IWifi</name>
                    <instance>default</instance>
                </interface>
            </hal>
            <hal format="hidl">
                <name>android.hardware.wifi.hostapd</name>
                <transport>hwbinder</transport>
                <version>1.0</version>
                <interface>
                    <name>IHostapd</name>
                    <instance>default</instance>
                </interface>
            </hal>
            <hal format="hidl">
                <name>android.hardware.wifi.supplicant</name>
                <transport>hwbinder</transport>
                <version>1.1</version>
                <interface>
                    <name>ISupplicant</name>
                    <instance>default</instance>
                </interface>
            </hal>
        ```
4. 修正bluetooth無法正常運作
   - 使用[KonstaKANG](https://konstakang.com/devices/rpi4/LineageOS16.0/)提供的lieageOS-16.0映像，提取可以用的[bluetooth 1.0服務](prebuilt/vendor/bin/hw/android.hardware.bluetooth%401.0-service.rpi4)
   - 新增bluetooth 1.0 啟動服務檔案 [bluetooth@1.0-service.rpi4.rc](prebuilt/vendor/etc/init/android.hardware.bluetooth@1.0-service.rpi4.rc)
   - 修改[manifest.xml](manifest.xml) 載入bluetooth相關packages
    ```xml
        <hal format="hidl">
            <name>android.hardware.bluetooth</name>
            <transport>hwbinder</transport>
            <version>1.0</version>
            <interface>
                <name>IBluetoothHci</name>
                <instance>default</instance>
            </interface>
        </hal>
    ```
5. 修正health服務無法正常啟動 *(無法正常進入Android)*
    - 使用[KonstaKANG](https://konstakang.com/devices/rpi4/LineageOS16.0/)提供的lieageOS-16.0映像，提取可以用的[health 2.0服務](prebuilt/vendor/bin/hw/android.hardware.health@2.0-service.rpi4)
    - 新增health 2.0啟動服務檔案 [health@2.0-service.rpi4.rc](prebuilt/vendor/etc/init/android.hardware.health@2.0-service.rpi4.rc)
    - 修改[manifest.xml](manifest.xml) 載入health相關packages
        ```xml
        <hal format="hidl">
            <name>android.hardware.health</name>
            <transport>hwbinder</transport>
            <version>2.0</version>
            <interface>
                <name>IHealth</name>
                <instance>default</instance>
            </interface>
        </hal>
        ```
6. 修正DRM服務無法正常啟動
    - 修改[rpi4.mk](rpi4.mk) 編譯時指定wifi需要用到的packages
        ``` bash
        # DRM
        PRODUCT_PACKAGES += \
        android.hardware.drm@1.0-impl \
        android.hardware.drm@1.0-service
        ``` 
    - 修改[manifest.xml](manifest.xml) 載入health相關packages
        ```xml
        <hal format="hidl">
            <name>android.hardware.drm</name>
            <transport>hwbinder</transport>
            <version>1.0</version>
            <interface>
                <name>ICryptoFactory</name>
                <instance>widevine</instance>
                <instance>default</instance>
            </interface>
            <interface>
                <name>IDrmFactory</name>
                <instance>widevine</instance>
                <instance>default</instance>
            </interface>
        </hal>
    ```
7. 修正configstore服務無法正常啟動
   - 修改[rpi4.mk](rpi4.mk) 編譯時指定wifi需要用到的packages
        ``` bash
        # configstore
        PRODUCT_PACKAGES += \
            android.hardware.configstore@1.1-service
        ``` 
    - 修改[manifest.xml](manifest.xml) 載入health相關packages
        ```xml
        <hal format="hidl">
            <name>android.hardware.configstore</name>
            <transport>hwbinder</transport>
            <version>1.1</version>
            <interface>
                <name>ISurfaceFlingerConfigs</name>
                <instance>default</instance>
            </interface>
        </hal>
        ```
### 已知問題
1. 重開機後Apps Icon會不見
2. 無法adb連線
    > error: device unauthorized. \
    This adbd's $ADB_VENDOR_KEYS is not set; try 'adb kill-server' if that seems wrong. \
    Otherwise check for a confirmation dialog on your device.
3. 無法root進入系統
4. 未整併TFT LCD觸控螢幕
5. 未整併Pi Camera
