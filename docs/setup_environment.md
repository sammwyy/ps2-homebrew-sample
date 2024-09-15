# Setup Environment

## Windows

Windows users can use the [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to setup a Linux environment.

## Linux

### Installing packages

```bash
sudo apt-get install -y bison build-essentials flex gcc git clang clang-format gettext libgsl-dev libgmp3-dev libmpfr-dev libmpc-dev make cmake patch texinfo wget zlib1g-dev
sudo apt-get update
```

### Setup environment variables

Open the file `~/.bashrc` and add the following lines at the end of the file:

```bash
export PS2DEV=/usr/local/ps2dev
export PS2SDK=$PS2DEV/ps2sdk
export GSKIT=$PS2DEV/gsKit
export PATH=$PATH:$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin
```

### Download and install PS2SDK

```bash
# Create PS2DEV directory.
sudo mkdir /usr/local/ps2dev
sudo chmod 777 /usr/local/ps2dev

# Clone and build the ps2toolchain and ps2sdk.
git clone https://github.com/ps2dev/ps2dev.git ps2dev
cd ps2dev
./build-all.sh

# Optional:
./build-extra.sh
```