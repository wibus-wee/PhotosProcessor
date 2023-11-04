# PhotosProcessor For Mac

A multi-functional picture processor software for macOS. Written in Swift.

<pre align="center">
🧪 Working in Progress
</pre>

![screen](./Resources/screen.avif)

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

