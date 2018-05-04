#!/bin/bash -x

# start compile build step
build=`buildah from oraclelinux:7-slim`

GRAALVM_PKG=graalvm-ce-1.0.0-rc1-linux-amd64.tar.gz
buildah config --env JAVA_HOME=/usr/graalvm-1.0.0-rc1/jdk $build
buildah config --env PATH=/usr/graalvm-1.0.0-rc1/bin:$PATH $build

buildah add $build $GRAALVM_PKG /usr/

buildah run $build -- yum -y install gcc
buildah run $build -- yum -y install zlib-devel
buildah run $build -- alternatives --install /usr/bin/java  java  $JAVA_HOME/bin/java  20000
buildah run $build -- alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000
buildah run $build -- alternatives --install /usr/bin/jar   jar   $JAVA_HOME/bin/jar   20000

# building
buildah copy $build *.java /target/
buildah config --workingdir /target/ $build
buildah run $build -- javac *.java
buildah run $build -- native-image HelloWorldServer
buildah run $build -- native-image HelloWorld

# packing minimal container
target=`buildah from scratch`
mount=`buildah mount $build`

buildah copy $target $mount/lib64/libc.so.6 /lib64/libc.so.6
buildah copy $target $mount/lib64/libdl.so.2 /lib64/libdl.so.2
buildah copy $target $mount/lib64/libpthread.so.0 /lib64/libpthread.so.0
buildah copy $target $mount/lib64/libz.so.1 /lib64/libz.so.1
buildah copy $target $mount/lib64/librt.so.1 /lib64/librt.so.1
buildah copy $target $mount/lib64/libcrypt.so.1 /lib64/libcrypt.so.1
buildah copy $target $mount/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
buildah copy $target $mount/lib64/libfreebl3.so /lib64/libfreebl3.so

buildah copy $target $mount/target/helloworld /
buildah copy $target $mount/target/helloworldserver /

buildah config --cmd "/helloworld" $target

imageId=`buildah commit --rm $target hello-graalvm`
buildah push $imageId docker-daemon:hello-graalvm:latest

# cleanup
buildah rm $build
