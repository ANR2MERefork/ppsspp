#!/bin/sh

LDID=/usr/local/bin/ldid
# Assuming we're at the ppsspp (repo's root) directory
mkdir -p build # For the final IPA & DEB file
mkdir -p build-ios
cd build-ios
# It seems xcodebuild is looking for "git-version.cpp" file inside "build-ios" directory instead of at repo's root dir.
echo "const char *PPSSPP_GIT_VERSION = \"$(git describe --always --tags)\";" > git-version.cpp
echo "#define PPSSPP_GIT_VERSION_NO_UPDATE 1" >> git-version.cpp
# Generate exportOptions.plist for xcodebuild
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>method</key>
   <string>development</string>
</dict>
</plist>' > exportOptions.plist

cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchains/ios.cmake -GXcode ..
#xcodebuild clean build -project PPSSPP.xcodeproj CODE_SIGNING_ALLOWED=NO -sdk iphoneos -configuration Release
xcodebuild -project PPSSPP.xcodeproj -scheme PPSSPP -sdk iphoneos -configuration Release clean archive -archivePath ./build/PPSSPP.xcarchive CODE_SIGNING_ALLOWED=NO #CODE_SIGN_IDENTITY="iPhone Distribution: Your NAME / Company (TeamID)" PROVISIONING_PROFILE="xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
xcodebuild -exportArchive -archivePath ./build/PPSSPP.xcarchive -exportPath ./build -exportOptionsPlist exportOptions.plist
cp ../ext/vulkan/iOS/Frameworks/libMoltenVK.dylib Payload/PPSSPP.app/Frameworks
ln -s ./ Payload
#cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchains/ios.cmake ..
#make -j4
#cp ../ext/vulkan/iOS/Frameworks/libMoltenVK.dylib PPSSPP.app/Frameworks
#ln -s ./ Payload
#${LDID} -w -S -IlibMoltenVK -K../../certificate.p12 -Upassword PPSSPP.app/Frameworks/libMoltenVK.dylib
ldid -S -IlibMoltenVK PPSSPP.app/Frameworks/libMoltenVK.dylib
#cp -a assets/icon_regular_72.png Payload/PPSSPP.app/AppIcon.png


echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>platform-application</key>
    <true/>
    <key>com.apple.private.security.no-container</key>
    <true/>
    <key>com.apple.security.iokit-user-client-class</key>
    <array>
        <string>AGXDeviceUserClient</string>
        <string>IOMobileFramebufferUserClient</string>
        <string>IOSurfaceRootUserClient</string>
    </array>
    <key>get-task-allow</key>
    <true/>
</dict>
</plist>' > ent.xml
#ldid -S ent.xml Payload/PPSSPP.app/PPSSPP
#${LDID} -w -Sent.xml -K../../certificate.p12 -Upassword PPSSPP.app
ldid -Sent.xml PPSSPP.app/PPSSPP
version_number=`echo "$(git describe --tags --match="v*" | sed -e 's@-\([^-]*\)-\([^-]*\)$@-\1-\2@;s@^v@@;s@%@~@g')"`
echo ${version_number} > PPSSPP.app/Version.txt
sudo -S chown -R 1004:3 Payload
echo "Making ipa..."
zip -r9 ../build/PPSSPP_v${version_number}.ipa Payload/PPSSPP.app
echo "IPA DONE :)"
echo "Making deb..."

package_name="org.ppsspp.ppsspp-dev-latest_v${version_number}_iphoneos-arm"
mkdir $package_name
mkdir ${package_name}/DEBIAN
echo "Package: org.ppsspp.ppsspp-dev-latest
Name: PPSSPP (Dev-Latest)
Architecture: iphoneos-arm
Description: A PSP emulator 
Icon: file:///Library/PPSSPPRepoIcons/org.ppsspp.ppsspp-dev-latest.png
Homepage: https://build.ppsspp.org/
Conflicts: com.myrepospace.theavenger.PPSSPP, net.angelxwind.ppsspp, net.angelxwind.ppsspp-testing, org.ppsspp.ppsspp, org.ppsspp.ppsspp-dev-working
Provides: com.myrepospace.theavenger.PPSSPP, net.angelxwind.ppsspp, net.angelxwind.ppsspp-testing
Replaces: com.myrepospace.theavenger.PPSSPP, net.angelxwind.ppsspp, net.angelxwind.ppsspp-testing
Depiction: https://cydia.ppsspp.org/?page/org.ppsspp.ppsspp-dev-latest
Maintainer: Henrik Rydgård
Author: Henrik Rydgårdq
Section: Games
Version: 0v${version_number}
" > ${package_name}/DEBIAN/control
chmod 0755 ${package_name}/DEBIAN/control
mkdir ${package_name}/Library
mkdir ${package_name}/Library/PPSSPPRepoIcons
cp ../../org.ppsspp.ppsspp.png ${package_name}/Library/PPSSPPRepoIcons/org.ppsspp.ppsspp-dev-latest.png
mkdir ${package_name}/Library/PreferenceLoader
cp -a ../../Preferences ${package_name}/Library/PreferenceLoader/
chmod 0755 ${package_name}/Library/PPSSPPRepoIcons/org.ppsspp.ppsspp-dev-latest.png
mkdir ${package_name}/Applications
cp -a PPSSPP.app ${package_name}/Applications/PPSSPP.app
sudo -S chown -R 1004:3 ${package_name}
sudo -S dpkg -b ${package_name} ../build/${package_name}.deb
sudo -S rm -r ${package_name}
echo "User = $USER"
sudo -S chown $USER ../build/${package_name}.deb
echo "Done, you should get the ipa and deb now :)"
