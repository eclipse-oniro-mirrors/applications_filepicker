@echo off


"%JAVA_HOME%\bin\java" -jar "hapsigntoolv2.jar" sign -mode localjks -privatekey "OpenHarmony Application Release" -inputFile C:\My\Applications\filepicker\product\phone\build\default\outputs\default\phone-default-signed.hap -outputFile FilePicker-phone-signed.hap -keystore "OpenHarmony.p12" -keystorepasswd 123456 -keyaliaspasswd 123456 -signAlg SHA256withECDSA -profile "filepicker.p7b" -certpath "OpenHarmonyApplication.pem"

rem @for /f "skip=1 tokens=1" %%i in ('adb devices -l') do (
rem    echo %%i
rem    adb -s %%i shell bm set --debugmode enable
rem    adb -s %%i push entry-debug-signed.hap /data/
rem    adb -s %%i shell bm install -r -p /data/entry-debug-signed.hap
rem )
rem if "%1" == "" (
rem     for /f "skip=1 tokens=1" %%i in ('adb devices -l') do (
rem     adb -s %%i shell bm set --debugmode enable
rem     adb -s %%i push entry-debug-signed.hap /data/
rem     adb -s %%i shell bm install -p /data/entry-debug-signed.hap
rem     )
rem )
rem hdc file send ./entry-debug-signed.hap /data
rem echo .
rem echo install done
rem pause
