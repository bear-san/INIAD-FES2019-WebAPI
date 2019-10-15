# INIAD-FES2019 公式App API仕様
ここでは、INIAD-FES 2019で来場者・参加団体の構成員に提供するスマーフォトンアプリのAPIの仕様を定める

APIのURLのうち、SchemaとHost Domainは事前にシステム管理者が設定をし個別に関係者に連絡するものとし、本API仕様では記載を省略する

特記無き場合、Authorizationヘッダに`Bearer "APIキー"`を含める必要がある（認証できない場合403エラーを返す）

## 共通機能
### ユーザー登録API： `POST /api/v1/user/new` 

アプリを使用するユーザーを作成し、APIキーを発行する

**Request Parameter:**
- `device_type:String` -> デバイスの種別、`iOS`/`Android`

**Response Parameter:**
- `status:String` -> API実行結果、`success`/`error`
- `secret:String(Optional)` -> APIキー、失敗時は`null`
- `description:String(Optional)` -> API実行結果を自然言語で表記する
- `role:Array<String>` -> 作成されたユーザーに付与された権限

**権限について**
- `developer` -> 以下、`system_admin`と同一、本番環境では運用しない
- `system_admin` -> システム管理者、全ての権限を有する
- `fes_admin` -> 実行委員会内での管理者
- `fes_committee` -> 一般実行委員
- `app_user` -> アプリユーザー、デフォルト権限
- `circle_participant` -> 大学祭出展団体
- `visitor` -> 来場受付を済ませた一般来場者

### 通知トークンアップデートAPI： `POST /api/v1/user`

アプリでプッシュ通知を受信するためのトークンを更新する

**Request Parameter:**
- `device_token` -> 端末で取得できたデバイストークン

**Response Parameter:**
- `status`
- `description:String(Optional)`

### ユーザー確認API： `GET /api/v1/user`

認証されたユーザーの情報を取得する

**Request Parameter**
- なし

**Response Parameter**
- `status:String`
- `description:String(Optional)`
- `role:Array<String>` -> ユーザーに付与されている権限
- `member_of:Array<Object>` -> ユーザーが所属している団体
```
{
    "ucode":"団体に割当されたucode",
    "organization_name":"団体名"
}
```
## デジタルパンフレット関係機能
### 企画一覧API： `GET /api/v1/contents`


INIAD-FESで実施されている企画を取得する

**Request Parameter:**
- `floor:Integer(Optional)` -> 階層、1〜5で指定、指定しない場合はすべてのフロアで検索する
- `room_num:String(Optional)` -> 部屋、INIADの構内図に準拠、別名が与えられている場合は別名を部屋名として扱う（INIADホールなど）
- `room_near:String(Optional)` -> 部屋、指定された部屋の付近の部屋で検索する

**Response Parameter:**
- `status:String`
- `description:String(Optional)`
- `objects:Array` -> 企画のデータを格納する、存在しない場合は空の配列が返る、企画データの構造については以下参照
```
{
    "ucode":"企画に割り振られたucode",
    "title":"企画名",
    "description":"企画の概要",
    "organizer": {
        "ucode":"参加団体に割り振られたucode",
        "organizer_name":"参加団体名"
    },
    "place": {
       "ucode":"企画実施場所に割り振られたucode",
       "room_name":"企画実施場所名",
       "door_name":["対応する扉番号"],
       "room_color":"マップ上で表示されるべき色のコード、HTMLカラーコードで表現"
    }
}
```

### 企画API `/api/v1/contents/:ucode`

指定したucodeに対応する企画を取得する

**Request Parameter**
- `:ucode` -> ucode

**Response Parameter**
- `status:String`
- `description:String(Optional)`
- `object:Object` -> 企画のデータを格納する、構造については前出のものと同様だがArrayでなく1件のみ返す

## 来場受付関係機能
### ユーザー属性ダンプAPI： `GET /api/v1/visitor`

指定したユーザー、もしくは認証されたユーザーの情報をダンプする

**Request Parameter**
- `user_id:String(Optional)` -> user_id、指定しない場合は認証されたユーザーの情報をダンプする

**Response Parameter**
- `status:String`
- `description:String(Optional)`
- `role:Array<String>` -> ユーザーに付与されている権限
- `history:Array<Object>` -> 企画来訪の履歴、以下参照
```
"visit": [
  {
    "ucode": "企画に付与されているucode",
    "timestamp": "来場の時間のタイムスタンプ、ISO8601形式"
  }
]
```
- `attribute:Object` -> 来場者の属性

### 属性登録API： `POST /api/v1/visitor/attributes`

来場者の属性を登録する

**Request Parameter**
- ＊未定＊

**Response Parameter**
- `status:String`
- `description:String(Optional)`
- `user_id:String` -> ユーザーID QRに使用する

### 来場受付API： `POST /api/v1/visitor/entry/:ucode`

各企画への来場を記録する

**Request Parameter**
- `:ucode:String` -> 企画に割り振られたucode
- `user_id:String` -> 来場者のQRコードから読み取ったuser_id

**Response Parameter**
- `status:String`
- `description:String(Optional)`
- `issued_time:DateTime` ->サーバー上で記録された時間、サーバーのローカルタイムをISO8601形式で表現

## 管理機能
### 来場受付API（INIAD-FES受付）： `POST /api/v1/admin/reception`

INIAD-FES自体への来場を記録する

**Request Parameter**
- `user_id` -> 読み取ったQRから取得できたuser_id

**Response Parameter**
- `status:String`
- `description:String(Optional)`