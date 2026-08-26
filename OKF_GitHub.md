

# 📘 **GitHubリポジリ分析拡張機能（VSCode）企画書 / 設計書（v1）**

---

## 🎯 **目的（Purpose）**
GitHub リポジトリ内の複数ファイルを効率的に分析し、  
ユーザーの質問に対して **関連するファイルだけを読み込み、Gemini 3.6 に最適化された形で回答させる**。

Gemini のトークン制限を回避しつつ、  
「全体を理解したうえで質問に答える」体験を実現する。

---

## 🏗 **全体構成（Architecture Overview）**

```
GitHub API → ファイル一覧取得
    ↓
OKF生成（ファイルごと）
    ↓
OKFストレージ（Webview内 or ローカル）
    ↓
質問入力
    ↓
OKF検索（関連ファイル抽出）
    ↓
Raw読み込み（関連ファイルのみ）
    ↓
Gemini 3.6-flash に送信
    ↓
応答表示
```

---

## 📂 **OKF（Optimized Knowledge File）とは？**
各ファイルの **要約・特徴・キーワード・リンク** を含むメタ情報。

### OKFの例
```json
{
  "filename": "src/auth.js",
  "summary": "認証処理を担当するファイル。ログイン、トークン発行など。",
  "keywords": ["auth", "login", "token"],
  "link": "https://github.com/23tk/Git/blob/main/src/auth.js"
}
```

---

## 🔧 **機能仕様（Feature Specification）**

### 1. **ファイル一覧取得**
- GitHub API `/contents` を使用
- 各ファイルに「OKF生成」ボタンを付与

### 2. **OKF生成（ファイルごと）**
- Raw を fetch
- Gemini 3.6-flash に「要約して」と送信
- summary / keywords / link を抽出
- OKF を保存（Webview内 or ローカル）

### 3. **質問処理**
- 質問文を受け取る
- 全 OKF を検索し、関連度スコアを算出
- スコア上位のファイルを抽出（例：3〜5件）

### 4. **関連ファイル読み込み**
- 抽出されたファイルだけ Raw を fetch
- Gemini に渡すための payload を生成

### 5. **Gemini応答**
- Gemini 3.6-flash に送信
- 応答を表示

---

## 🧠 **関連ファイル抽出ロジック（Scoring）**

### スコア計算例
```
質問文の単語 × OKF.keywords → +3点
質問文の単語 × OKF.summary → +1点
質問文の単語 × filename → +2点
```

例：  
質問「認証周りを改善したい」

```
auth.js → keywords: ["auth", "login", "token"] → 高スコア
router.js → keywords: ["router"] → 低スコア
```

---

## 🖥 **UI設計（Webview）**

### 画面構成
1. **ファイル一覧表示**
   - 各行に「OKF生成」ボタン
2. **OKF一覧表示**
   - 生成済みOKFを確認できる
3. **質問入力欄**
4. **回答表示欄**

---

## 📦 **データ保存方式（選択式）**

### A. Webview内メモリ（簡易）
- 再起動で消える
- 実装が軽い

### B. ローカル保存（推奨）
- `okf/filename.json` として保存
- 再利用可能
- 大規模リポジトリでも効率的

---

## 🚀 **メリット**
- トークン制限を回避できる  
- 大規模リポジトリでも高速  
- Gemini 3.6 の要約能力を最大限活用  
- 質問に対して「関連ファイルだけ」を読むので精度が高い  
- 拡張としての完成度が高い

---

## 📅 **次回やること（To-Do）**
- OKF保存方式（Webview内 or ローカル）を決める  
- OKF生成ボタンの実装  
- OKF検索ロジックの実装  
- 質問→関連ファイル抽出→Gemini送信の実装  
- 全体統合

