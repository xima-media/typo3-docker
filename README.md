# Docker images

This repository provides various docker images used in PHP development.

## PHP + composer

These images are just like the original [composer images](https://hub.docker.com/_/composer), but with pinned PHP version and litte adjustments.

## Ansible

Debian stable image with packages for ansible provisioning.

### Changes

* Line 1: Pin PHP version
* Line 42: Install PHP extension `mysqli`
* Build docker image for Ansible
