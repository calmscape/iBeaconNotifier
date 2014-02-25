iBeaconNotifier
===========

iBeaconの領域監視(モニタリング)情報をLocalNotificationで通知するサンプルコード

リージョンモニタリング時にCoreLocationから送られる通知の振る舞いを体験するためのデモアプリです。

### 要件
本サンプルコードを動かすには、iOS 7.0以降および Bluetooth 4.0に対応したiOSデバイスが必要になります。iOSシミュレータでは動作しません。

利用デバイスのBluetooth機能および、位置情報サービスをONにした状態で使用してください。

### 機能概要
* ビーコン領域を監視(リージョンモニタリング)し、CoreLocationから送られる通知情報をLocal Notificationとして飛ばす
* 通知情報をログに残す
* ```locationManager:didDetermineState:forRegion:``` で得られる情報のロギング
* ```locationManager:didEnterRegion:``` で得られる情報のロギング
* ```locationManager:didExitRegion:``` で得られる情報のロギング

### カスタマイズ
BeaconList.plist を編集することで領域監視対象のビーコンを指定できます。

指定できるキーは以下の通り。キーの意味は```CLBeaconRegion```および```CLRegion```と同じです。この内容をもとに```CLBeaconRegion```オブジェクトを生成し、ビーコン領域として登録します。


| Key                       | Type    | Value (sample)                       |
| ------------------------- |:-------:| ------------------------------------ |
| proximityUUID             | String  | B9407F30-F5F8-466E-AFF9-25556B57FE6D |
| major                     | Number  | 101                                  |
| minor                     | Number  | 1                                    |
| notifyOnEntry             | Boolean | YES                                  |
| notifyOnExit              | Boolean | YES                                  |
| notifyEntryStateOnDisplay | Boolean | NO                                   |

デフォルトではiBeaconハッカソン3で使用したビーコン領域が登録してあります。

### 通知の解除方法
Local Notificationを止めるには画面右上のスイッチをOFFにするか、OSの設定＞通知センターでアプリの通知を停止してください。

### ソフトウェアライセンスについて
This software is released under the MIT License, see LICENSE.md.
