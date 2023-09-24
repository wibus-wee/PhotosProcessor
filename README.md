# PhotosProcessor For macOS

A multi-functional picture processor software for macOS. Written in Swift.

<pre align="center">
🧪 Working in Progress
</pre>

## Roadmap

### Core Features

> The core features are the most important features of the software, and the software cannot be used without them.

- [x] Image compression
- [ ] Modifies image metadata
- [ ] Adds a dark watermark

### Performance Features

> Performance features are features that improve the user experience.

- [ ] Menu bar Drag to process
- [ ] Configuration Support
- [ ] Expert mode, common mode, noob mode
- [ ] Supports batch processing
- [x] Drag and drop processing
- [x] Log Display
- [x] Process Queue Support
- [ ] Remove built-in Resource (avifenc,exiftool,magick)

### Configurations

> Configurations are features that allow users to customize the software. When the configuration item is not completed, the following options will not be checked.

- [ ] Avifenc
  - Description: *The path to the avifenc executable file.*
  - Type: `Select + Input`
  - Default: `Built-in`
  - Options: `Built-in`, `Custom` (If `Custom` is selected, the input box will be displayed)
- [ ] Menu bar Drag to process immediately
  - Description: *Whether to process immediately when dragging to the menu bar.*
  - Type: `Checkbox`
  - Default: `true`
- [ ] Default Mode
  - Description: *The default mode when the software is opened.*
  - Type: `Select`
  - Default: `Normal`
  - Options: `Expert`, `Normal`, `Noob`
- [ ] Check for updates automatically
  - Description: *Whether to check for updates automatically when the software is opened.*
  - Type: `Checkbox`
  - Default: `true`
- [ ] Start menu bar processing
  - Description: *Whether to start the menu bar processing.*
  - Type: `Checkbox`
  - Default: `true`
- [ ] Execute command immediately
  - Description: *Whether to execute the command immediately.*
  - Type: `Checkbox`
  - Default: `true`

## References

- [a-wing's Notion Site](https://awing.notion.site/2023-36-v1-1-1e1b3542b8e84db197555365824a6773)
- [a-wing's Tweet](https://twitter.com/_a_wing/status/1700586549065155043)

## Author

PhotosProcessor © Wibus, Released under AGPLv3. Created on Sep 11, 2023

> [Personal Website](http://iucky.cn/) · [Blog](https://blog.iucky.cn/) · GitHub [@wibus-wee](https://github.com/wibus-wee/) · Telegram [@wibus✪](https://t.me/wibus_wee)

