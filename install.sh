#!/usr/bin/env bash

PID=$$
spin() {
    while ps -p $PID > /dev/null; do for X in '⠟' '⠯' '⠷' '⠾' '⠽' '⠻' ; do printf "\b$X" ; sleep 0.1 ; done ; done
}

if [ "$(id -u)" -eq 0 ]; then
    printf "Please don't run me as root :c\n"
    exit 1
fi

PLUGIN=$1
OS="$(uname -a)"
TARGET="unknown"
if [[ "$OS" == *"Linux"* ]]; then
    if [[ "$OS" == *"x86_64"* ]]; then
        TARGET="x86_64-unknown-linux-gnu"
    elif [[ "$OS" == *"x64"* ]]; then
        TARGET="x86_64-unknown-linux-gnu"
    elif [[ "$OS" == *"aarch64"* ]]; then
        TARGET="aarch64-unknown-linux-gnu"
    elif [[ "$OS" == *"arm64"* ]]; then
        TARGET="aarch64-unknown-linux-gnu"
    elif [[ "$OS" == *"armv8"* ]]; then
        TARGET="aarch64-unknown-linux-gnu"
    fi
elif [[ "$OS" == *"Darwin"* ]]; then
    TARGET="universal2-apple-darwin"
fi

if [ "$TARGET" == "unknown" ]; then
    printf "\nUnknown OS, this installer only supports Linux and MacOS PCs :c\n"
    exit 1
fi

if [ "$PLUGIN" == "" ]; then
    printf "No arguments specified :c\n"
    exit 1
fi

printf "Installing $PLUGIN  "
spin&
SPINNER=$!

if [[ "$TARGET" == "aarch64-unknown-linux-gnu" || "$TARGET" == "x86_64-unknown-linux-gnu" ]]; then
    DIR_VST3="$HOME/.vst3/blepfx"
    DIR_CLAP="$HOME/.clap/blepfx"
    DIR_TEMP="/tmp"
elif [[ "$TARGET" == "universal2-apple-darwin" ]]; then
    DIR_VST3="$HOME/Library/Audio/Plug-Ins/VST3/blepfx"
    DIR_CLAP="$HOME/Library/Audio/Plug-Ins/CLAP/blepfx"
    DIR_AUV2="$HOME/Library/Audio/Plug-Ins/Components"
    DIR_TEMP="$TMPDIR"
fi

curl -sfL -m 40 -o "$DIR_TEMP/$PLUGIN-$TARGET.zip" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN-$TARGET.zip"
if [ $? -ne 0 ]; then
    kill $SPINNER >/dev/null 2>&1
    printf "\nCan't download the plugin :c"
    printf "\nPlease check your connectivity and try again\n"
    exit 1
fi

unzip -oqq -d "$DIR_TEMP/$PLUGIN-$TARGET" "$DIR_TEMP/$PLUGIN-$TARGET.zip"

mkdir -p "$DIR_CLAP"
rm -rf "$DIR_CLAP/$PLUGIN-$TARGET.clap"
mv "$DIR_TEMP/$PLUGIN-$TARGET/$PLUGIN-$TARGET.clap" "$DIR_CLAP/$PLUGIN-$TARGET.clap"

mkdir -p "$DIR_VST3"
rm -rf "$DIR_VST3/$PLUGIN-$TARGET.vst3"
mv "$DIR_TEMP/$PLUGIN-$TARGET/$PLUGIN-$TARGET.vst3" "$DIR_VST3/$PLUGIN-$TARGET.vst3"

if [[ "$TARGET" == "universal2-apple-darwin" ]]; then
    mkdir -p "$DIR_AUV2"
    rm -rf "$DIR_AUV2/blepfx-$PLUGIN-$TARGET.component"
    mv "$DIR_TEMP/$PLUGIN-$TARGET/$PLUGIN-$TARGET.component" "$DIR_AUV2/blepfx-$PLUGIN-$TARGET.component"

    killall -9 AudioComponentRegistrar &> /dev/null

    # remove old versions before the rename
    rm -rf "$DIR_VST3/$PLUGIN-apple-universal.vst3" &> /dev/null
    rm -rf "$DIR_CLAP/$PLUGIN-apple-universal.clap" &> /dev/null
fi

rm -d "$DIR_TEMP/$PLUGIN-$TARGET"
rm "$DIR_TEMP/$PLUGIN-$TARGET.zip"

kill $SPINNER >/dev/null 2>&1
printf "\nDone! Thank you for using my plugins <3\n"
