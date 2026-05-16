#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

if [ -z "${PS2DEV:-}" ]; then
    for dir in /usr/local/ps2dev /opt/ps2dev /ps2dev; do
        if [ -d "$dir/ps2sdk" ]; then
            PS2DEV=$dir
            break
        fi
    done
fi

if [ -z "${PS2DEV:-}" ]; then
    echo "PS2DEV is not set and ps2dev was not found in a standard location." >&2
    echo "Install ps2dev or export PS2DEV before running this script." >&2
    exit 1
fi

PS2SDK=${PS2SDK:-"$PS2DEV/ps2sdk"}
GSKIT=${GSKIT:-"$PS2DEV/gsKit"}
export PS2DEV PS2SDK GSKIT
export PATH="$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin:$PATH"

if [ ! -f "$PS2SDK/samples/Makefile.pref" ]; then
    echo "PS2SDK was not found at $PS2SDK." >&2
    echo "Set PS2SDK or PS2DEV to a valid ps2dev installation." >&2
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    echo "GNU Make was not found in PATH." >&2
    exit 1
fi

if [ -z "${JOBS:-}" ]; then
    if command -v nproc >/dev/null 2>&1; then
        JOBS=$(nproc)
    elif command -v sysctl >/dev/null 2>&1; then
        JOBS=$(sysctl -n hw.ncpu)
    else
        JOBS=4
    fi
fi

if [ "$#" -eq 0 ]; then
    mkdir -p build
    exec make all -j"$JOBS"
fi

mkdir -p build
exec make "$@"
