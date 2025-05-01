# old-linux-vscode

Starting from VSCode 1.99, it is no longer possible to connect to older Linux distributions using Remote-Containers.  
This repository provides Docker images of legacy Linux environments (Ubuntu 16.04, Ubuntu 18.04) that are still compatible with VSCode Remote-Containers.

## Usage

Replace the following line in your `Dockerfile`:

```dockerfile
FROM ubuntu:16.04
````

with:

```dockerfile
FROM ghcr.io/naitaku/old-linux-vscode:ubuntu-16.04
```

## How it works

This image includes a custom `sysroot` built using [crosstool-ng](https://crosstool-ng.github.io/),
following the guidelines described in the official VSCode documentation:
[https://aka.ms/vscode-remote/faq/old-linux](https://aka.ms/vscode-remote/faq/old-linux)

## License

SPDX-License-Identifier: MIT
