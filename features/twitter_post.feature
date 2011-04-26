#language: ja
フィーチャ: twitter をもちいて ぼっち であることを知らせる
  シナリオ: twitterでつぶやく
    前提 twitter ログイン
    もし "the homepage"ページを表示している
    かつ "内容"に"cucumber をもちいたテスト投稿+#{Time.now}"と入力する
    かつ "投稿"ボタンをクリックする
    ならば "投稿成功"と表示されていること
    かつ "cucumber をもちいたテスト投稿"と"twitter"に投稿されていること
  シナリオ: 位置情報
