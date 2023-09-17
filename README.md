# PhotosProcessor

A multi-functional picture processor software.

## Roadmap

### Core Features

> The core features are the most important features of the software, and the software cannot be used without them.

- [ ] Image compression | 图片压缩
- [ ] Modifies image metadata | 修改图片元数据
- [ ] Adds a dark watermark | 暗水印

### Performance Features

> Performance features are features that improve the user experience.

- [ ] Menu bar Drag to process | 菜单栏拖拽处理
- [ ] Configuration Support | 配置支持
- [ ] Expert mode, common mode, noob mode | 专家模式、普通模式、小白模式
- [ ] Supports batch processing | 支持批量处理
- [ ] Drag and drop processing | 拖拽处理
- [x] Log Display | 日志显示
- [ ] Process Queue Support | 处理队列支持

## Configurations

> Configurations are features that allow users to customize the software.

- [ ] Avifenc, Exiftool, Magick Path
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

## Author

PhotosProcessor © Wibus, Released under AGPLv3. Created on Sep 11, 2023

> [Personal Website](http://iucky.cn/) · [Blog](https://blog.iucky.cn/) · GitHub [@wibus-wee](https://github.com/wibus-wee/) · Telegram [@wibus✪](https://t.me/wibus_wee)

