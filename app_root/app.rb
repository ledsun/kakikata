
# ブラウザのAPIを使いやすくするためのショートハンド定数
URLSearchParams = JS.global[:URLSearchParams]
Location = JS.global[:location]

class App
  # ビューを初期化して、コントローラーを起動する
  def initialize
    view = View.new Document.querySelector('.container')
    view.update initial_phrase

    Controller.new view
  end

  private

  # 初期表示文字列を取得
  # URLのクエリパラメータにphraseがあればその値を使い、なければStoryを使う
  def initial_phrase
    searchParams = URLSearchParams.new(Location[:search])
    if searchParams.has? 'phrase'
      searchParams.get('phrase')
                  .to_s
    else
      Story
    end
  end
end
