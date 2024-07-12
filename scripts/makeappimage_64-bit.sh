#!/usr/bin/env bash

if [ ! -f appimagetool-x86_64.AppImage ]; then
	APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')
	wget -q "$APPIMAGETOOL" -O ./appimagetool-x86_64.AppImage
    chmod +x appimagetool-x86_64.AppImage
fi

mkdir ./AppDir/
mkdir ./AppDir/usr/
mkdir ./AppDir/usr/bin/
mkdir ./AppDir/usr/share/
mkdir ./AppDir/usr/share/applications/
mkdir ./AppDir/usr/share/icons/
mkdir ./AppDir/usr/share/icons/hicolor/
mkdir ./AppDir/usr/share/icons/hicolor/256x256/
mkdir ./AppDir/usr/share/icons/hicolor/256x256/apps/

cp ./../SDL/PPSSPPSDL.desktop ./AppDir/
cp ./../SDL/PPSSPPSDL.desktop ./AppDir/usr/share/applications/
cp ./../build/PPSSPPSDL ./AppDir/usr/bin/
cp -R ./../build/assets ./AppDir/usr/bin/
cp ./../icons/hicolor/256x256/apps/ppsspp.png ./AppDir/usr/share/icons/hicolor/256x256/apps/

DESTDIR=AppDir make install
chmod +x AppDir/AppRun
./appimagetool-x86_64.AppImage --appimage-extract-and-run -s deploy AppDir/usr/share/applications/*.desktop

rm AppDir/ppsspp.png
pushd AppDir
ln -s usr/share/icons/hicolor/256x256/apps/ppsspp.png
popd
ARCH=x86_64 VERSION=$(./AppDir/AppRun --version) ./appimagetool-x86_64.AppImage --appimage-extract-and-run AppDir
