<p align="center">
  <p align="center">
   <img width="150" height="150" src="/PhotosProcessor/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png" alt="Logo">
  </p>
	<h1 align="center"><b>PhotosProcessor</b></h1>
	<p align="center">
		Beautiful, multi-functional picture processor software
    <br />
    <!-- <a href="https://cap.so"><strong>cap.so »</strong></a> -->
    <!-- <br /> -->
    <br />
    <b>Download for </b>
		macOS
    <br />
    <i>~ Links will be added once a release is available. ~</i>
  </p>
</p>

<br />

> NOTE: PhotosProcessor is currently in development and not yet ready for production use. You can help us by testing it and reporting issues, or even contributing to the project.

![screen](./Resources/screen.avif)

[![GitHub release](https://img.shields.io/github/v/release/wibus-wee/PhotosProcessor?color=orange&label=latest%20release&sort=semver&style=flat-square)](https://github.com/wibus-wee/PhotosProcessor/releases/latest)
[![GitHub Workflow Status (with branch)](https://img.shields.io/github/actions/workflow/status/wibus-wee/PhotosProcessor/build.yml?style=flat-square)](https://github.com/wibus-wee/PhotosProcessor/actions/workflows/build.yml)
[![GitHub Repo stars](https://img.shields.io/github/stars/wibus-wee/PhotosProcessor?style=flat-square)](https://github.com/wibus-wee/PhotosProcessor/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/wibus-wee/PhotosProcessor?style=flat-square)](https://github.com/wibus-wee/PhotosProcessor/forks)

## Roadmap

### Core Features

> The core features are the most important features of the software, and the software cannot be used without them.

- [x] Image compression **`✅`** | **`🔧 Improving`**
  - [x] AVIF
  - [ ] HEIC
  - [ ] WebP
  - [ ] JPEG
  - [ ] PNG
  - [ ] GIF
- [x] Modify image metadata **`✅`** | **`🔧 Improving`** ｜ **`🐛 Bug Occurred`**
  - [ ] Regex support ([#10](https://github.com/wibus-wee/PhotosProcessor/issues/10))
  - [ ] Clone ([#8](https://github.com/wibus-wee/PhotosProcessor/issues/8))
- [ ] Image dark watermark support **`⏳ In Progress.`** | **`❓ Need help.`**
- [ ] GPS location fix **`⏳ In Progress.`** | **`❓ Need help.`**
- [ ] Menu bar item
- [ ] Stitching images
  - [ ] Horizontal
  - [ ] Vertical
  - [ ] Grid
  - [ ] Custom
- [ ] DAMA
- [ ] Noise generator

### Performance Features

> Performance features are features that improve the user experience.

- [x] Configuration Support
- [ ] Supports batch processing one time **`🏷️ Planning`** | **`❓ Need help.`**
- [x] Shared processing image
- [x] Drag and drop processing
- [x] Log Display **`🐛 Bug Occurred` ([`#1`](https://github.com/wibus-wee/PhotosProcessor/issues/1))**
- [x] Process Queue Support **`🔧 Improving`** | **`🛞 Configurable`**
- [x] Support for loading external dependencies (avifenc, etc.) **`💣 Improve later?`** | **`🛞 Configurable`**
- [x] Quickly compression with global hotkey **`🛞 Configurable`**
- [ ] Support image processing after processing **`🏷️ Planning`** | **`🛞 Configurable`**
- [ ] Gaussian blur effect when processing ([#6](https://github.com/wibus-wee/PhotosProcessor/issues/6)) **`🏷️ Planning`**

### Others

- [ ] Refactor UI **`🏷️ Planning. After the core features are completed`**
  - [ ] Standlone *Welcome page*
  - [x] Standlone *Settings Page*
- [ ] Multiple languages (i18n) **`🥷 May implemented in the future`**

### May NOT be implemented features

> This part of the content may be very complex, and the performance after implementation may not be excellent.

- [ ] Curves (RGB/CMYK)
- [ ] Automatic Adjustment
- [ ] ~~Fork all features of **CleanShot X & Shottr**~~ (It will be implemented as a new project: **`Shot Max`**)
<!--  - [ ] Enhance highlight circle function -->
<!--  - [ ] Brush memory function  -->
<!--  - [ ] Mosaic enhancement -->

## References

- [新一.enp1s1 on X](https://twitter.com/_a_wing/status/1700586549065155043). 
- [Lakr233/ActionBee](https://github.com/Lakr233/ActionBee)
- [Lakr233/CameraTools](https://github.com/Lakr233/CameraTools)
- [ISStego](https://github.com/isena/ISStego). We create a Swift implementation of the ISStego algorithm. (Based on [Fork of ISStego by nob3rise](https://github.com/nob3rise/ISStego)) Full credits to the original authors.

## Author

PhotosProcessor © Wibus, Released under AGPLv3. Created on Sep 11, 2023

> [Personal Website](http://wibus.ren/) · [Blog](https://blog.wibus.ren/) · GitHub [@wibus-wee](https://github.com/wibus-wee/) · Telegram [@wibus✪](https://t.me/wibus_wee)

