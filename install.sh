#!/bin/sh

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
    MACOS_VERSION="$(sw_vers -productVersion)"
    MACOS_MAJOR="$(echo $MACOS_VERSION | cut -d'.' -f1)"
    MACOS_MINOR="$(echo $MACOS_VERSION | cut -d'.' -f2)"
    if [ "$MACOS_MAJOR" -gt 10 ] || { [ "$MACOS_MAJOR" -eq 10 ] && [ "$MACOS_MINOR" -gt 13 ]; }; then
        TARGET="apple-universal"
    else
        TARGET="x86_64-apple-darwin"
    fi
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
elif [[ "$TARGET" == "apple-universal" || "$TARGET" == "x86_64-apple-darwin" ]]; then
    DIR_VST3="$HOME/Library/Audio/Plug-Ins/VST3/blepfx"
    DIR_CLAP="$HOME/Library/Audio/Plug-Ins/CLAP/blepfx"
    DIR_TEMP="$TMPDIR"
fi

curl -sfL -m 20 -o "$DIR_TEMP/$PLUGIN-$TARGET.zip" "https://github.com/blepfx/dist/releases/latest/download/$PLUGIN-$TARGET.zip"
if [ $? -ne 0 ]; then
    kill $SPINNER >/dev/null 2>&1
    printf "\nCan't download the plugin :c"
    printf "\nPlease check your connectivity and try again\n"
    exit 1
fi

unzip -oqq -d "$DIR_TEMP/$PLUGIN-$TARGET" "$DIR_TEMP/$PLUGIN-$TARGET.zip"

mkdir -p "$DIR_CLAP"
mkdir -p "$DIR_VST3"

rm -rf "$DIR_VST3/$PLUGIN-$TARGET.vst3"
rm -rf "$DIR_CLAP/$PLUGIN-$TARGET.clap"

mv "$DIR_TEMP/$PLUGIN-$TARGET/$PLUGIN-$TARGET.vst3" "$DIR_VST3/$PLUGIN-$TARGET.vst3"
mv "$DIR_TEMP/$PLUGIN-$TARGET/$PLUGIN-$TARGET.clap" "$DIR_CLAP/$PLUGIN-$TARGET.clap"

rm -d "$DIR_TEMP/$PLUGIN-$TARGET"
rm "$DIR_TEMP/$PLUGIN-$TARGET.zip"

kill $SPINNER >/dev/null 2>&1
printf "\nDone! Thank you for using my plugins <3\n"
