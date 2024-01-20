require_relative 'app/view'
require_relative 'app/controller'
require_relative 'app/story'

# ブラウザのAPIを使いやすくするためのショートハンド定数
URLSearchParams = JS.global[:URLSearchParams]
Location = JS.global[:location]

class App
  def initialize
    view = View.new Document.querySelector('.container')
    view.update initial_phrase
    Controller.new view
  end

  private

  # 初期表示する文字列を取得する
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
