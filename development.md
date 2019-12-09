## 开始

```bash
$ git clone https://github.com/PoiScript/NGNGA.git
$ cd NGNGA
$ flutter pub get
```

## 调试

```bash
$ flutter run
```

## 打包

### Android

```bash
$ flutter build apk --target-platform android-arm,android-arm64 --split-per-abi
```

## 发布

在发布新版本前请确保前面的 commit 的 CI 检查已经通过。

然后更新 `pubspec.yaml` 中的版本号并创建一个新的 commit 和 tag：

```diff
- version: 4.1.2
+ version: 4.2.0
```

```bash
$ git add pubspec.yaml
$ git commit -m "release: cut the v4.2.0 release"
$ git tag v4.2.0
$ git push
$ git push --tags
```

NGNGA 的版本号遵循 [semantic versioning](https://semver.org/)。

## format

```
$ flutter format lib/ test/
```

## lint

```bash
$ flutter analyze
```

## 翻译

NGNGA 目前支持 English（英文）和中文。

为了在不同的语言设置下都能正确显示相应，请不要将在程序中硬编码字符串：

```dart
// Don't
// widget.dart
Text("newString")
```

相反，在 `AppLocalizations` 中添加一个新的 getter，并使用
`AppLocalizations.of(context)`：

```dart
// Do
// localizations.dart
String get newString => Intl.message('newString', locale: localeName);

// widget.dart
Text(AppLocalizations.of(context).newString)
```

之后生成新的 arb 文件：

```bash
$ flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localizations.dart
```

更新 arb 文件之后再生成对应的 dart 文件：

```bash
$ flutter pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/localizations.dart lib/l10n/intl_en.arb lib/l10n/intl_zh.arb
```
