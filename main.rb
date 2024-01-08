require 'js'
require 'erb'

# JS::Objectを拡張して、セッターを使えるようにする
class JS::Object
  alias_method :method_missing_original, :method_missing

  def method_missing(sym, *args, &block)
    if sym.end_with? '='
      # =で終わるメソッドはセッター
      self.method(:[]=).call(sym.to_s.gsub!(/=$/, ''), *args)
    else
      method_missing_original(sym, *args, &block)
    end
  end
end

# ブラウザのAPIを使いやすくするためのショートハンド定数
module Document
  def self.querySelector(selectors) = JS.global[:document].querySelector(selectors)
end
URLSearchParams = JS.global[:URLSearchParams]
Location = JS.global[:location]

Model = Data.define(:phrase)

class View
  # 1文字分のHTMLテンプレート
  Template = ERB.new(<<~'END_HTML')
  <div class="character">
    <span>
      <%= character %>
    </span>
  </div>
  END_HTML

  def initialize(html_element)
    @html_element = html_element
  end

  # 画面に表示する
  def update(model)
    html = model.phrase
                .gsub(/[^ぁ-んァ-ン一-龠々]/, '')
                .ljust(48, ' ')
                .chars[0, 48]
                .map { |character| Template.result_with_hash character: }
                .join

    @html_element.innerHTML = html
  end
end

class Controller
  def initialize(view)
    # ボタンを押したときの挙動を定義する
    Document.querySelector('button').addEventListener 'click' do
      statements = Document.querySelector '.statements'
      phrase = statements[:value].to_s
      view.update Model.new(phrase)
    end
  end
end

class App
  # おはなしのテキスト
  # 初期表示文字列の候補
  Story = <<~TEXT
  もりのなか　もりの　おひめさまが
  まどから　かおを　のぞかせてみる
  すると　あさつゆの　おんなのこが
  そよかぜさんに　いわれておまいり

  おがわのほとり　あさつゆみんなで
  ひめさまの　きらきら　ふわふわな
  かみを　とかし　まっかなドレスと
  ぴかぴかのくつで　みじたくおわり

  おひめさまに　あまい　はちみつを
  さっと　もってくる　こけのこたち
  もんのそばの　こかげの　ひかげに
  したくされた　あさの　おしょくじ

  きらきらした　ふちの　こくばんに
  せっせと　てならいの　おひめさま
  からすせんせい　ほんを　くわえて
  ちえを　あれやこれや　たたきこむ

  おべんきょう　おわりに　こじかと
  こうさぎと　いっしょに　えんそく
  あと　ついてくる　りすに　ことり
  うきうきと　たのしい　おひめさま

  もりの　はずれ　こけが　ふかふか
  きのこのこが　すんでいる　ところ
  みいんな　たのしい　なかまたちで
  おはなし　するのが　その　やくめ

  あかりを　てにした　ほしのこたち
  もりのおくへ　ひめを　ごあんない
  くらがりのなか　ぶじ　おうちまで
  いっぱい　あそんで　もう　えがお

  もりの　いきもの　みんな　すやり
  おひめさまも　おやすみの　じかん
  よかぜが　そっと　ざわめいている
  ほしのこひとり　おしろの　みはり
  TEXT

  def initialize
    view = View.new Document.querySelector('.content')
    view.update Model.new(initial_phrase)
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
      Story.split("\n\n")
          .sample
    end
  end
end

App.new
