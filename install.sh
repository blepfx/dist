#!/bin/sh

spin() {
    while : ; do for X in '⠟' '⠯' '⠷' '⠾' '⠽' '⠻' ; do printf "\b$X" ; sleep 0.1 ; done ; done
}

if [ "$(id -u)" -eq 0 ]; then
    printf "Please don't run me as root :c\n"
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
    printf "No arguments specified :c\n"
    exit 1
fi

printf "Installing $PLUGIN  "
spin&
SPINNER=$!

if [[ "$TARGET" == "linux" ]]; then
    DIR_VST3="$HOME/.vst3/blepfx"
    DIR_CLAP="$HOME/.clap/blepfx"
    PLUGIN_FILE="$PLUGIN-$TARGET_ARCH-unknown-linux-gnu"

    mkdir -p "$DIR_CLAP"
    mkdir -p "$DIR_VST3"

    curl -sSL -o "$DIR_CLAP/$PLUGIN_FILE.clap" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN_FILE.clap"
    curl -sSL -o "$DIR_VST3/$PLUGIN_FILE.vst3.zip" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN_FILE.vst3.zip"

    unzip -oqq -d "$DIR_VST3/$PLUGIN_FILE.vst3.temp" "$DIR_VST3/$PLUGIN_FILE.vst3.zip"
    rm -rf "$DIR_VST3/$PLUGIN_FILE.vst3"
    mv "$DIR_VST3/$PLUGIN_FILE.vst3.temp/$PLUGIN_FILE.vst3" "$DIR_VST3/$PLUGIN_FILE.vst3"
    rm -f "$DIR_VST3/$PLUGIN_FILE.vst3.zip"
    rmdir "$DIR_VST3/$PLUGIN_FILE.vst3.temp"
elif [[ "$TARGET" == "macos" ]]; then
    DIR_VST3="$HOME/Library/Audio/Plug-Ins/VST3/blepfx"
    DIR_CLAP="$HOME/Library/Audio/Plug-Ins/CLAP/blepfx"
    PLUGIN_FILE="$PLUGIN-apple-universal"

    mkdir -p "$DIR_CLAP"
    mkdir -p "$DIR_VST3"

    curl -sSL -o "$DIR_CLAP/$PLUGIN_FILE.clap.zip" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN_FILE.clap.zip"
    curl -sSL -o "$DIR_VST3/$PLUGIN_FILE.vst3.zip" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN_FILE.vst3.zip"

    unzip -oqq -d "$DIR_CLAP/$PLUGIN_FILE.clap.temp" "$DIR_CLAP/$PLUGIN_FILE.clap.zip"
    rm -rf "$DIR_CLAP/$PLUGIN_FILE.clap"
    mv "$DIR_CLAP/$PLUGIN_FILE.clap.temp/$PLUGIN_FILE.clap" "$DIR_CLAP/$PLUGIN_FILE.clap"
    rm -f "$DIR_CLAP/$PLUGIN_FILE.clap.zip"
    rmdir "$DIR_CLAP/$PLUGIN_FILE.clap.temp"

    unzip -oqq -d "$DIR_VST3/$PLUGIN_FILE.vst3.temp" "$DIR_VST3/$PLUGIN_FILE.vst3.zip"
    rm -rf "$DIR_VST3/$PLUGIN_FILE.vst3"
    mv "$DIR_VST3/$PLUGIN_FILE.vst3.temp/$PLUGIN_FILE.vst3" "$DIR_VST3/$PLUGIN_FILE.vst3"
    rm -f "$DIR_VST3/$PLUGIN_FILE.vst3.zip"
    rmdir "$DIR_VST3/$PLUGIN_FILE.vst3.temp"
else
    printf "\nUnknown OS, this installer only supports Linux and MacOS PCs :c\n"
    exit 1
fi

kill $SPINNER >/dev/null 2>&1
printf "\nDone! Thank you for using my plugins <3\n"
