# Docker images

This repository provides various docker images used in PHP development.

## PHP + composer

These images are just like the original [composer images](https://hub.docker.com/_/composer), but with pinned PHP version and litte adjustments.

### Changes

* Line 1: Pin PHP version
* Line 42: Install PHP extension `mysqli`

## Ansible

Debian stable image with packages for ansible provisioning.

## Sitepackage-req-checker

Ensure TYPO3 site package requirement list is complete.
