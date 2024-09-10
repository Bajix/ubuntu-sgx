# See Intel® SGX Software Installation Guide for more information
# https://download.01.org/intel-sgx/latest/linux-latest/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf

FROM ubuntu:23.10

# Prerequisites from Intel® SGX Software Installation Guide, DCAP Driver Installation
RUN apt-get update \
  && apt-get install -y build-essential ocaml automake autoconf libtool wget python-is-python3 libssl-dev dkms \ 
  && apt-get clean

# § 1b.II) Add the following repository to sources:
RUN echo 'deb [trusted=yes signed-by=/etc/apt/keyrings/intel-sgx-keyring.asc arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu mantic main' | sudo tee /etc/apt/sources.list.d/intel-sgx.list

# § 1d.II) Get the Debian repo public key and add it to the list of trusted keys that are used by apt to authenticate packages
RUN mkdir -m 0755 -p /etc/apt/keyrings \
  && wget -q -O - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | tee /etc/apt/keyrings/intel-sgx-keyring.asc > /dev/null

# § 1e) Update apt and install the following packages:
RUN apt-get update \
  && apt-get install -y libsgx-epid libsgx-quote-ex libsgx-dcap-ql \
  && apt-get clean

# § 1f) (Optional) To debug with sgx-gdb, install the debug symbol package.
RUN apt-get update \
  && apt-get install -y libsgx-urts-dbgsym libsgx-enclave-common-dbgsym libsgx-dcap-ql-dbgsym libsgx-dcap-default-qpl-dbgsym \
  && apt-get clean

# § 2.II) Install the DCAP QPL package
RUN apt-get update \
  && apt-get install -y libsgx-dcap-default-qpl \
  && apt-get clean

# Latest from  https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu23.10-server/
ARG SGX_URL=https://download.01.org/intel-sgx/sgx-linux/2.24/distro/ubuntu23.10-server/sgx_linux_x64_sdk_2.24.100.3.bin

# § 2a-c) Download the Intel® SGX SDK and install it
RUN wget -O sgx.bin "${SGX_URL}" \
  && chmod +x ./sgx.bin \
  && ./sgx.bin --prefix=/opt/intel \
  && rm ./sgx.bin

# Additional dependencies
RUN  apt-get update \
  && apt-get install -y \
    git libclang-14-dev nano zsh \
  && apt-get clean \
  && rm -r /var/lib/apt/lists

# Install oh-my-zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

# Install rust
RUN wget --output-document - --quiet https://sh.rustup.rs | sh -s -- -y

RUN echo "[ -f /opt/intel/sgxsdk/environment ] && . /opt/intel/sgxsdk/environment" >> ~/.zshenv
