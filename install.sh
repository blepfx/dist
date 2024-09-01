#!/bin/sh

spin() {
    while : ; do for X in '⠟' '⠯' '⠷' '⠾' '⠽' '⠻' ; do echo -en "\b$X" ; sleep 0.1 ; done ; done
}

if [ "$(id -u)" -eq 0 ]; then
    echo "Please don't run me as root :c"
    exit 1
fi

PLUGIN=$1
OS="$(uname -a)"
TARGET="unk"
TARGET_ARCH="unk"
if [[ "$OS" == *"Linux"* ]]; then
    if [[ "$OS" == *"x86_64"* ]]; then
        TARGET="linux"
        TARGET_ARCH="x86_64"
    elif [[ "$OS" == *"x64"* ]]; then
        TARGET="linux"
        TARGET_ARCH="x86_64"
    elif [[ "$OS" == *"aarch64"* ]]; then
        TARGET="linux"
        TARGET_ARCH="aarch64"
    elif [[ "$OS" == *"arm64"* ]]; then
        TARGET="linux"
        TARGET_ARCH="aarch64"
    elif [[ "$OS" == *"armv8"* ]]; then
        TARGET="linux"
        TARGET_ARCH="aarch64"
    fi
elif [[ "$OS" == *"Darwin"* ]]; then
    TARGET="macos"
fi

if [ "$PLUGIN" == "" ]; then
    echo "No arguments specified :c"
    exit 1
fi

echo -n "Installing $PLUGIN  "
spin&
SPINNER=$!

if [[ "$TARGET" == "linux" ]]; then
    DIR_VST3="$HOME/.vst3/blepfx"
    DIR_CLAP="$HOME/.clap/blepfx"

    mkdir -p "$DIR_CLAP"
    mkdir -p "$DIR_VST3"

    curl -sSL -o "$DIR_CLAP/$PLUGIN.clap" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN-$TARGET_ARCH-unknown-linux-gnu.clap"
    curl -sSL -o "$DIR_VST3/$PLUGIN.vst3.zip" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN-$TARGET_ARCH-unknown-linux-gnu.vst3.zip"

    unzip -oqq -d "$DIR_VST3/$PLUGIN.vst3.temp" "$DIR_VST3/$PLUGIN.vst3.zip"
    rm -rf "$DIR_VST3/$PLUGIN.vst3"
    mv "$DIR_VST3/$PLUGIN.vst3.temp/$PLUGIN-$TARGET_ARCH-unknown-linux-gnu.vst3" "$DIR_VST3/$PLUGIN.vst3"
    rm -f "$DIR_VST3/$PLUGIN.vst3.zip"
    rmdir "$DIR_VST3/$PLUGIN.vst3.temp"
elif [[ "$TARGET" == "macos" ]]; then
    DIR_VST3="$HOME/Library/Audio/Plug-Ins/VST3/blepfx"
    DIR_CLAP="$HOME/Library/Audio/Plug-Ins/CLAP/blepfx"

    mkdir -p "$DIR_CLAP"
    mkdir -p "$DIR_VST3"

    curl -sSL -o "$DIR_CLAP/$PLUGIN.clap.zip" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN-apple-universal.clap.zip"
    curl -sSL -o "$DIR_VST3/$PLUGIN.vst3.zip" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN-apple-universal.vst3.zip"

    unzip -oqq -d "$DIR_CLAP/$PLUGIN.clap.temp" "$DIR_CLAP/$PLUGIN.clap.zip"
    rm -rf "$DIR_CLAP/$PLUGIN.clap"
    mv "$DIR_CLAP/$PLUGIN.clap.temp/$PLUGIN-apple-universal.clap" "$DIR_CLAP/$PLUGIN.clap"
    rm -f "$DIR_CLAP/$PLUGIN.clap.zip"
    rmdir "$DIR_CLAP/$PLUGIN.clap.temp"

    unzip -oqq -d "$DIR_VST3/$PLUGIN.vst3.temp" "$DIR_VST3/$PLUGIN.vst3.zip"
    rm -rf "$DIR_VST3/$PLUGIN.vst3"
    mv "$DIR_VST3/$PLUGIN.vst3.temp/$PLUGIN-apple-universal.vst3" "$DIR_VST3/$PLUGIN.vst3"
    rm -f "$DIR_VST3/$PLUGIN.vst3.zip"
    rmdir "$DIR_VST3/$PLUGIN.vst3.temp"
else
    echo "Unknown OS, this installer only supports Linux and MacOS PCs :c"
    exit 1
fi

kill $SPINNER >/dev/null 2>&1
echo "Done! Thank you for using my plugins <3"
