FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
SHELL ["/bin/bash", "-c"]

ENV HOME /root

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install git jq bc automake tmux rsync htop \
    curl build-essential pkg-config libffi-dev libgmp-dev \
    libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make \
    g++ wget libncursesw5 libtool autoconf -y

# Install Japanese package
RUN apt-get install language-pack-ja -y
RUN update-locale LANG=ja_JP.UTF-8

RUN mkdir -p ${HOME}/git
WORKDIR ${HOME}/git
RUN git clone https://github.com/input-output-hk/libsodium

WORKDIR ${HOME}/git/libsodium
RUN git checkout 66f017f1
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

WORKDIR ${HOME}
RUN wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
RUN tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
RUN rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig
RUN mkdir -p ${HOME}/.local/bin
RUN mv cabal ${HOME}/.local/bin/

RUN wget https://downloads.haskell.org/ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz
RUN tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz
RUN rm ghc-8.10.2-x86_64-deb9-linux.tar.xz
WORKDIR ${HOME}/ghc-8.10.2
RUN ./configure
RUN make install

RUN echo PATH="${HOME}/.local/bin:$PATH" >> ${HOME}/.bashrc
RUN echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> ${HOME}/.bashrc
RUN echo export NODE_HOME=$HOME/cardano-node >> ${HOME}/.bashrc
RUN echo export NODE_CONFIG=mainnet>> ${HOME}/.bashrc
RUN echo export NODE_BUILD_NUM=$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g') >> ${HOME}/.bashrc
# Env for Japanese
RUN echo 'export LANG=ja_JP.UTF-8' >> ~/.bashrc
RUN source ${HOME}/.bashrc

ENV PATH $PATH:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
ENV NODE_HOME $NODE_HOME:/root/cardano-node

RUN cabal update
RUN cabal -V
RUN ghc -V

WORKDIR ${HOME}/git
RUN git clone https://github.com/input-output-hk/cardano-node.git
WORKDIR ${HOME}/git/cardano-node
RUN git fetch --all --recurse-submodules --tags
RUN git checkout tags/1.25.1
RUN cabal configure -O0 -w ghc-8.10.2

RUN echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
RUN sed -i ${HOME}/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
RUN rm -rf ${HOME}/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.10.2

RUN cabal build cardano-cli cardano-node
RUN cp $(find ${HOME}/git/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
RUN cp $(find ${HOME}/git/cardano-node/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node

RUN mkdir -p ${HOME}/tmp

CMD ["/bin/bash"]