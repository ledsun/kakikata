# ブラウザのAPIを使いやすくするためのショートハンド定数
module Document
  def self.querySelector(selectors) = JS.global[:document].querySelector(selectors)
end

class App
  class Controller
    def initialize(view)
      # ボタンを押したときの挙動を定義する
      Document.querySelector('button').addEventListener 'click' do
        statements = Document.querySelector '.statements'
        phrase = statements[:value].to_s
        view.update phrase
      end
    end
  end
end
