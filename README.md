This is a sample project for building application images using S2I provided by OpenShift. Follow the below steps to build and use the S2I sample provided.

1) Create a packs folder inside the root project directory and download and add the packs/jdk-8u221-linux-x64.tar.gz

2) Building the builder image
docker build -t msa-ubuntu-builder .

3) s2i build <source code path/URL> ubuntu-basic-builder <application image>
eg:
s2i build https://github.com/ajanthanblog/greeting.git msa-ubuntu-builder msa-ubuntu-builder-appimage

4) You can then run the resulting image via:
docker run <application image>
eg:
docker run -d -p 8097:8097 msa-ubuntu-builder-appimage