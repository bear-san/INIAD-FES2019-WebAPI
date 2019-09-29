# INIAD-FES2019 公式App API仕様
ここでは、INIAD-FES 2019で来場者・参加団体の構成員に提供するスマーフォトンアプリのAPIの仕様を定める

APIのURLのうち、SchemaとHost Domainは事前にシステム管理者が設定をし個別に関係者に連絡するものとし、本API仕様では記載を省略する

## 共通機能
### ユーザー登録API： `POST /api/v1/user/new` 

アプリを使用するユーザーを作成し、APIキーを発行する

**Request Parameter:**
- `device_type:String` -> デバイスの種別、`iOS`/`Android`

**Response Parameter:**
- `status:String` -> API実行結果、`success`/`error`
- `secret:String(Optional)` -> APIキー、失敗時は`null`
- `description:String(Optional)` -> API実行結果を自然言語で表記する

### 通知トークンアップデートAPI： `POST /api/v1/user`

アプリでプッシュ通知を受信するためのトークンを更新する

**Request Parameter:**
- `device_token` -> 端末で取得できたデバイストークン

**Response Parameter:**
- `status`
- `description:String(Optional)`

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