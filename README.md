# Dataloader For Linux
#### An easy to use graphical tool for Linux that helps you to get your data into Salesforce objects

## Build Prerequisites

- Debian/Ubuntu based OS
- JDK (e.g. openjdk-11)
- Maven

## Build

1. Clone repo:
```bash
git clone https://github.com/SoftCreatR/dataloader-for-linux && cd dataloader-for-linux
```

2. Build
```bash
./build.sh
```

Append `--stable` to build the stable release.

## Install (stable)

1. Download the latest version

<!-- download stable start -->
```bash
wget https://github.com/SoftCreatR/dataloader-for-linux/raw/main/release/stable/apex-dataloader-54.0.0-1641908116-8306b1d.deb
```
<!-- download stable end -->

2. Install package

<!-- install stable start -->
```bash
sudo dpkg -i apex-dataloader-54.0.0-1641908116-8306b1d.deb
```
<!-- install stable end -->

## Install (nightly)

1. Download the latest version

<!-- download nightly start -->
```bash
wget https://github.com/SoftCreatR/dataloader-for-linux/raw/main/release/nightly/apex-dataloader-55.0.0-1651018234-fe869ea.deb
```
<!-- download nightly end -->

2. Install package

<!-- install nightly start -->
```bash
sudo dpkg -i apex-dataloader-55.0.0-1651018234-fe869ea.deb
```
<!-- install nightly end -->

## Use

Successful installation provides you 3 binaries:

- dataloader - Dataloader GUI
- dataloader-encrypt - Used to create encryption key, encrypted password, etc. (see https://developer.salesforce.com/docs/atlas.en-us.dataLoader.meta/dataLoader/loader_encryption.htm)
- dataloader-process - The command line tool to import data (see https://developer.salesforce.com/docs/atlas.en-us.dataLoader.meta/dataLoader/loader_operations.htm)

## Additional system requirements for Data Loader

- At least 120 MB of free disk space
- At least 256 MB of available memory (RAM)
- Java Runtime Environment (JRE) version 11 or later such as openjdk-11-jre

## 3rd party licenses included in Data Loader

- [License](https://www.apache.org/licenses/LICENSE-2.0) for [Apache Jakarta Commons BeanUtils](http://jakarta.apache.org/commons/beanutils/)
- [License](https://logging.apache.org/log4j/2.x/license.html) for [Apache Log4J 2.x](https://logging.apache.org/log4j/2.x/index.html)
- [License](http://www.eclipse.org/legal/epl-2.0/) for [Eclipse SWT](http://www.eclipse.org/swt/)
- [License](https://www.apache.org/licenses/LICENSE-2.0) for [Spring Framework](https://spring.io/projects/spring-framework)
