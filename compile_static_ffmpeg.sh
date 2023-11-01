
sudo apt-get update -qq 

sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  meson \
  ninja-build \
  pkg-config \
  texinfo \
  wget \
  yasm \
  zlib1g-dev \
  libass-dev \
  libfreetype6-dev

mkdir -p ~/ffmpeg_sources ~/bin


#NASM
cd ~/ffmpeg_sources
wget https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/nasm-2.16.01.tar.bz2
tar xjvf nasm-2.16.01.tar.bz2
cd nasm-2.16.01
./autogen.sh
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install

#libx264
cd ~/ffmpeg_sources
git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --enable-pic
PATH="$HOME/bin:$PATH" make
make install

#libx265
sudo apt-get install libnuma-dev
cd ~/ffmpeg_sources
wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2
tar xjvf x265.tar.bz2
cd multicoreware*/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off ../../source
PATH="$HOME/bin:$PATH" make
make install

#libvpx
cd ~/ffmpeg_sources
git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
PATH="$HOME/bin:$PATH" make
make install


#libsvtav1
cd ~/ffmpeg_sources && \
git -C SVT-AV1 pull 2> /dev/null || git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
mkdir -p SVT-AV1/build && \
cd SVT-AV1/build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF .. && \
PATH="$HOME/bin:$PATH" make && \
make install

#libaom
cd ~/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom && \
PATH="$HOME/bin:$PATH" make && \
make install

#libdav1d
sudo apt-get install libdav1d-dev

#libfdk-aac
sudo apt-get install libfdk-aac-dev


#ffmpeg
cd ~/ffmpeg_sources
git clone https://github.com/immersiveinc/FFmpeg.git
cd FFmpeg
git checkout release/5.1 
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --ld="g++" \
  --bindir="$HOME/bin" \
  --enable-static\
  --enable-gpl \
  --enable-libfdk-aac \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libaom \
  --enable-libsvtav1 \
  --enable-libdav1d \
  --enable-libass \
  --enable-libfreetype \
  --enable-nonfree 
PATH="$HOME/bin:$PATH" make -j8
make install
./ffmpeg
