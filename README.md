# Blog: Shiny New Container Tools

## Intent

* Use GraalVM to create a native binary from Java code (see [Oracles GraalVM für „Natives Java“](https://www.innoq.com/de/blog/native-java-graalvm/))
* Use buildah as a multi stage build tool to create an OCI container image
* Use gVisor with its user-space guest kernel to increase isolation

## Requirements

* [GraalVM](https://www.graalvm.org/)
* [Buildah](https://github.com/projectatomic/buildah)
* [gVisor](https://github.com/google/gvisor)

Please follow the dedicated installation instructions of [gVisior](https://github.com/google/gvisor#installation) and [buildah](https://github.com/projectatomic/buildah/blob/master/install.md#installation-instructions)

## Run tl;dr

### Build the OCI Image

Running a multi stage build:

```bash
wget https://github.com/oracle/graal/releases/download/vm-1.0.0-rc1/graalvm-ce-1.0.0-rc1-linux-amd64.tar.gz
sudo ./helloworld-buildah.sh
```

### Hello World

Execute default CMD:

```bash
docker run --rm --runtime=runsc hello-graalvm
```

### Hello World Server

Execute the Hello World server:

```bash
docker run --rm --runtime=runsc -d -p 8080:8080 hello-graalvm helloworldserver
curl -v localhost:8080
```
