#language: ja
フィーチャ: twitter で情報交換
  シナリオ: twitterでつぶやく
    前提 twitter ログイン
    もし "the homepage"ページを表示している
     かつ twitter 用字句生成
     かつ "投稿"ボタンをクリックする
    ならば "投稿成功"と表示されていること
     かつ "cucumber をもちいたテスト投稿"と"twitter"に投稿されていること
  シナリオ: 位置情報
