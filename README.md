# Dataloader For Linux
#### An easy to use graphical tool for Linux that helps you to get your data into Salesforce objects

![image](https://user-images.githubusercontent.com/81188/199914116-3f717c18-e40d-4828-8042-16f51f20b7ed.png)


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
wget https://github.com/SoftCreatR/dataloader-for-linux/raw/main/release/stable/apex-dataloader-56.0.6-1667494316-b7e1b77.deb
```
<!-- download stable end -->

2. Install package

<!-- install stable start -->
```bash
sudo dpkg -i apex-dataloader-56.0.6-1667494316-b7e1b77.deb
```
<!-- install stable end -->

## Install (nightly)

1. Download the latest version

<!-- download nightly start -->
```bash
wget https://github.com/SoftCreatR/dataloader-for-linux/raw/main/release/nightly/apex-dataloader-56.0.6-1670803719-95ed3ed.deb
```
<!-- download nightly end -->

2. Install package

<!-- install nightly start -->
```bash
sudo dpkg -i apex-dataloader-56.0.6-1670803719-95ed3ed.deb
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

## Troubleshooting

> Exception in thread "main" java.lang.UnsatisfiedLinkError: Could not load SWT library.

While SWT is shipped with dataloader, it is possible that your OS is looking for another version of it's libraries. In this case, you may just install it system-wide:

```bash
sudo apt install libswt-gtk-4-java
```

## 3rd party licenses included in Data Loader

* [License](http://www.apache.org/licenses/LICENSE-2.0) for [Apache Commons DBCP 2.x](https://commons.apache.org/proper/commons-dbcp/), [Apache Commons IO 2.x](https://commons.apache.org/proper/commons-io/), [Apache HttpComponents 4.x](https://hc.apache.org/)
* [License](https://logging.apache.org/log4j/2.x/license.html) for [Apache Log4J 2.x](https://logging.apache.org/log4j/2.x/index.html)
* [License](http://www.eclipse.org/legal/epl-2.0/) for [Eclipse SWT 4.x](http://www.eclipse.org/swt/), [Eclipse JFace 3.x](https://wiki.eclipse.org/JFace)
* [License](https://www.apache.org/licenses/LICENSE-2.0) for [Spring Framework Core Technologies - spring-context 5.x](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html)
