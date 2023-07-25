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

# 1文字分のHTMLテンプレート
Template = ERB.new(<<~'END_HTML')
  <div class="character">
    <span>
      <%= character %>
    </span>
  </div>
END_HTML

# おはなしのテキスト
# 初期表示文字列の候補
Text = <<TEXT
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

# ブラウザのAPIを使いやすくするためのショートハンド定数
module Document
  def self.querySelector(selectors) = JS.global[:document].querySelector(selectors)
end
URLSearchParams = JS.global[:URLSearchParams]
Location = JS.global[:location]

# 画面に表示する
def set(phrase)
  html = phrase.gsub('　', '')
               .gsub("\n", '')
               .chars[0, 48]
               .map { |character| Template.result_with_hash character: }
               .join

  content = Document.querySelector ".content"
  content.innerHTML = html
end

# 初期表示する文字列を取得する
def initial_phrase
  searchParams = URLSearchParams.new(Location[:search])
  if searchParams.has? 'phrase'
    searchParams.get('phrase')
                .to_s
  else
    Text.split("\n\n")
        .sample
  end
end

# ボタンを押したときの挙動を定義する
class Controller
  Document.querySelector('button').addEventListener 'click' do
    statements = Document.querySelector '.statements'
    phrase = statements[:value].to_s
    set phrase
  end
end

set initial_phrase
Controller.new
