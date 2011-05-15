#language: ja
フィーチャ: 友人をみる
  シナリオ: 友人のページをみる
    もし twitter ログイン
    かつ "My Page"リンクをクリックする
    ならば "div#friends"に"tomy_kaira"と表示されていること
    かつ 投稿フォームが表示されていること
    かつ "フォロワーにおすすめしましょう"と表示されていること

  シナリオ: 友人のtweetをみる
    もし twitter ログイン
    かつ "My Page"リンクをクリックする
    ならば "div#friends_status"に"tomy_kaira"と表示されていること
    かつ "駒場で飯くおう"と表示されていること
