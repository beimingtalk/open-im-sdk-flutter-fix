# flutter_openim_sdk
<img src="https://github.com/OpenIMSDK/OpenIM-Docs/blob/main/docs/images/WechatIMG20.jpeg" alt="image" style="width: 350px; " />

[![pub package](https://img.shields.io/pub/v/flutter_openim_sdk.svg)](https://pub.flutter-io.cn/packages/flutter_openim_sdk)
[![Generic badge](https://img.shields.io/badge/platform-android%20|%20ios%20-blue.svg)](https://pub.dev/packages/flutter_openim_sdk)
[![GitHub license](https://img.shields.io/github/license/OpenIMSDK/Open-IM-SDK-Flutter)](https://github.com/OpenIMSDK/Open-IM-SDK-Flutter/blob/main/LICENSE)

A flutter im plugin for android and ios.

## 本地调试 Core

如果你修改了 `openim-sdk-core`，可以让当前 Flutter 插件优先使用本地产物：

- Android: 将编译出来的 `open_im_sdk.aar` 放到 `android/libs/open_im_sdk.aar`
- iOS: 将编译出来的 `OpenIMCore.xcframework` 放到 `ios/Framework/OpenIMCore.xcframework`

当前仓库已经支持“本地优先、远端兜底”：

- 本地产物存在时，优先使用本地 `AAR` / `xcframework`
- 本地产物不存在时，回退到远端发布版本

Core 重新编译命令可在 `openim-sdk-core` 目录执行：

```bash
make android
make ios
```

也可以直接执行仓库根目录的一键脚本：

```bash
bash scripts/update_local_core.sh
```

脚本会自动完成：

- 编译 Core 的 Android AAR
- 编译 Core 的 iOS xcframework
- 拷贝产物到当前 Flutter 插件的本地依赖目录
- 执行 `flutter clean`、`flutter pub get`
- 执行 `example/ios` 下的 `pod install`

####  [demo open source code](https://github.com/OpenIMSDK/Open-IM-Flutter-Demo.git) | [UI library source code](https://github.com/hrxiang/flutter_openim_widget.git)

Scan the QR code below to experience the SDK call example Demo

![Android](https://www.pgyer.com/app/qrcode/OpenIM-Flutter)

# [SDK Documents](https://doc.rentsoft.cn/sdks/quickstart/flutter)
