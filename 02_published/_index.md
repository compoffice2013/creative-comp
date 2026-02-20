# 📋 公開済みコンテンツ管理

> ブログやSNS投稿をWordPressに公開した後、ここに記録をつけてください。
> AIがリンク生成時に公開URLを参照するために使います。

## フォルダ構成

| フォルダ | 内容 |
|---------|------|
| `blog/` | 公開済みブログ記事（WordPress URL記録） |
| `facebook/` | 公開済みFacebook投稿 |
| `instagram/` | 公開済みInstagram投稿 |
| `seo/` | 公開済みSEO設定 |
| `x/` | 公開済みX投稿 |

## 記録フォーマット

ブログ記事を公開したら、以下のフォーマットでファイルを作成してください：

```markdown
---
title: "記事タイトル"
date: YYYY-MM-DD
url: https://comp-office.com/blog/パーマリンク/
status: published
---

# 記事タイトル

（本文はなくてもOK。URLの記録が主目的）
```

## 運用ルール

1. **ブログ公開時**: `02_blog/drafts/` のファイルを編集し、YAMLフロントマターの `link` 欄にURLを追記
2. **公開記録**: このフォルダにも上記フォーマットでファイルを作成
3. **AIの活用**: 過去の公開URLは `wp_search.js` でも検索可能だが、このフォルダの記録も参照する
