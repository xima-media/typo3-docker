# Docker images

This repository provides various docker images used in PHP development.

## PHP + composer

These images are just like the original [composer images](https://hub.docker.com/_/composer), but with pinned PHP version and litte adjustments.

### Changes

* Line 1: Pin PHP version
* Line 42: Install PHP extension `mysqli`

## Ansible

Debian stable image with packages for ansible provisioning.

## Playwright

Playwright image with additional dependencies. When upgrading, the identical version must be used for docker image tag in [./playwright/Dockerfile](./playwright/Dockerfile) and npm package @playwright/test in [./playwright/package.json](./playwright/package.json).

## Playwright ddev

Extends the [Playwright](#playwright) image with the dependencies required by the [ddev-playwright](https://github.com/xima-media/ddev-playwright) add-on, most notably a bundled [KasmVNC](https://github.com/kasmtech/KasmVNC) install. Bundling KasmVNC avoids downloading the deb from GitHub at ddev add-on build time, which is prone to availability issues. The image is tagged with the same Playwright version as the base [./playwright/Dockerfile](./playwright/Dockerfile).
