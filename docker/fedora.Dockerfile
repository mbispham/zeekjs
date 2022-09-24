FROM fedora:36

# Dependencies required to compile and test ZeekJS on Fedora
RUN dnf install -y \
  cmake \
  diffutils \
  dnf-plugins-core \
  gcc-c++ \
  gdb \
  nodejs-devel \
  v8-devel \
  which \
  clang-tools-extra

RUN dnf config-manager --add-repo https://download.opensuse.org/repositories/security:zeek/Fedora_36/security:zeek.repo

ENV ZEEK_VERSION=5.0.1-1.1

RUN dnf install -y \
  zeek-btest-$ZEEK_VERSION \
  zeek-core-$ZEEK_VERSION  \
  zeek-devel-$ZEEK_VERSION

ENV PATH=/opt/zeek/bin:$PATH

RUN btest --version
RUN zeek --version

# Run the build and compile
WORKDIR /src
COPY . .

RUN make check-clang-format

RUN rm -rf build && ./configure && make && ( cd tests && btest -A -d -c btest.cfg ) && make install

# Run clang-tidy now - this may take a while.
WORKDIR /src
RUN make check-clang-tidy

RUN zeek -N Corelight::ZeekJS
RUN zeek ./examples/hello.js
