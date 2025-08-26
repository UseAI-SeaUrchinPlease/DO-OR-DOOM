# 開発環境セットアップガイド

## VS Code/Cursor エディタでのデバイス設定

### 1. 個人設定ファイルの作成

`.vscode/settings.json.example` をコピーして個人設定を作成してください：

```bash
cp .vscode/settings.json.example .vscode/settings.json
```

### 2. デバイスIDの確認と設定

#### iOS (iPhone/iPad)
```bash
# 利用可能なiOSシミュレータを確認
xcrun simctl list devices available

# 例: iPhone 15 Pro のデバイスIDをコピー
# 730A7F9E-84FD-43BB-8190-17F6AEB87DDB
```

#### Android
```bash
# 利用可能なAndroidエミュレータを確認
flutter emulators

# 例: Pixel_7_API_34 など
```

### 3. settings.json の更新

`.vscode/settings.json` を開いて、`dart.defaultDeviceId` を自分の希望するデバイスIDに変更：

```json
{
  "dart.defaultDeviceId": "YOUR_DEVICE_ID_HERE"
}
```

### 4. プラットフォーム設定

iOSとAndroidで異なる設定も可能：

```json
{
  "dart.defaultDeviceId": "730A7F9E-84FD-43BB-8190-17F6AEB87DDB",
  "flutter.defaultTargetPlatform": "ios"  // または "android"
}
```

## 推奨デバイス設定

### iOS
- **iPhone 15 Pro**: 最新機能とパフォーマンステスト用
- **iPhone SE (3rd generation)**: 小画面対応テスト用

### Android  
- **Pixel 7 API 34**: 標準的なAndroid体験
- **Medium Phone API 36.0**: 中サイズ画面テスト用

## 注意事項

⚠️ `.vscode/settings.json` は個人設定のため、**Gitにコミットしないでください**  
✅ `.vscode/settings.json.example` は共有設定テンプレートとしてコミット可能

## トラブルシューティング

### デバイスが表示されない場合
```bash
# デバイス一覧を更新
flutter doctor
flutter devices

# iOS Simulatorを再起動
killall Simulator
open -a Simulator
```

### 設定が反映されない場合
1. VS Code/Cursorを再起動
2. Flutter拡張を無効化→有効化
3. コマンドパレット: "Developer: Reload Window"
