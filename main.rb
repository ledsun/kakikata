require 'js'
require 'erb'


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

template = ERB.new(<<~'END_HTML')
  <div class="character">
    <span>
      <%= character %>
    </span>
  </div>
END_HTML

text = <<TEXT
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

def set(phrase, template)
  html = phrase.gsub('　', '')
               .gsub("\n", '')
               .chars[0, 48]
               .map { |character| template.result_with_hash character: }
               .join

  content = Document.querySelector ".content"
  content.innerHTML = html
end

def init(text, template)
  phrase = text.split("\n\n")
               .sample

  set phrase, template
end

Document.querySelector('button').addEventListener 'click' do
  statements = Document.querySelector '.statements'
  phrase = statements.value.to_s
  set phrase, template
end

searchParams = URLSearchParams.new(Location[:search])
if searchParams.has?('phrase')
  phrase = searchParams.get('phrase').to_s
  set phrase, template
else
  init text, template
end
