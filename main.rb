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

class View
  # 1文字分のHTMLテンプレート
  CharactorTemplate = ERB.new(<<~'END_HTML')
  <div class="character">
    <span>
      <%= character %>
    </span>
  </div>
  END_HTML

  PageTemplate = ERB.new(<<~'END_HTML')
  <div class="page">
    <div class="grid">
      <%= characters %>
    </div>
  </div>
  END_HTML

  def initialize(html_element)
    @html_element = html_element
  end

  # 画面に表示する
  def update(phrase)
    pages = []
    phrase.gsub(/[^ぁ-んァ-ン一-龠々]/, '')
          .chars
          .each_slice(48) do |chars|
            # 1ページに表示する文字数は48文字。
            # 48文字に満たない場合に左寄せで表示されます。
            # 足りない場合は空文字で埋めます。
            chars = chars.fill(nil, chars.length..47)
            pages << chars.map { |character| CharactorTemplate.result_with_hash character: }
                          .join
          end

    @html_element.innerHTML = pages.map { |characters| PageTemplate.result_with_hash characters: }
  end
end

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

App.new
