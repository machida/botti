#language: ja
フィーチャ: twitter で情報交換
  シナリオ: tweetせず、ぼっちである
    前提 twitter ログイン
    もし "ユーザ"ページを表示している
    かつ "つぶやき"に twitter 用字句生成
     かつ "Twitter にもポストする"のチェックを外す
     かつ "投稿"ボタンをクリックする
    ならば "投稿しました"と表示されていること
     かつ "twitter"に投稿されていないこと
  シナリオ: twitterでつぶやく
    前提 twitter ログイン
    もし "ユーザ"ページを表示している
     かつ "つぶやき"に twitter 用字句生成
     かつ "Twitter にもポストする"をチェックする
     かつ "投稿"ボタンをクリックする
    ならば "投稿しました"と表示されていること
     かつ "twitter"に投稿されていること
  シナリオ: DM で返信
    前提 twitter ログイン
    もし "DM"ページを表示している
    ならば "駒場で飯くおう"と表示されていること
     かつ "tomy_kaira"と表示されていること
    もし "メッセージ"に twitter 用字句生成
     かつ "DM"を選択する
     かつ "声をかける"ボタンをクリックする
    ならば "声をかけました"と表示されていること
     かつ DMが送信されていること
  シナリオ: Mention で返信
    前提 twitter ログイン
    もし "DM"ページを表示している
    ならば "駒場で飯くおう"と表示されていること
     かつ "tomy_kaira"と表示されていること
    もし "メッセージ"に twitter 用字句生成
     かつ "Mention"を選択する
     かつ "声をかける"ボタンをクリックする
    ならば "声をかけました"と表示されていること
     かつ "twitter"に投稿されていること
     かつ DMが送信されていないこと
