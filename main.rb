require 'js'
require 'erb'

class JS::Object
  def method_missing(sym, *args, &block)
    if self[sym].typeof == "function"
      # 関数として定義されていたら、関数として呼び出す。
      self.call(sym, *args, &block)
    elsif sym.end_with? '='
      # =で終わるメソッドはセッター
      self.method(:[]=).call(sym.to_s.gsub!(/=$/, ''), *args)
    elsif args.empty?
      # 引数がなければゲッター
      # JavaScriptのオブジェクトなので、存在しないプロパティを読んでもエラーにしない。undefiendを返す。
      self.method(:[]).call(sym)
    else
      # 引数がないメソッド呼び出しは method_missing
      super
    end
  end
end

template = ERB.new(<<~'END_HTML')
  <div class="charactor">
    <span>
      <%= charactor %>
    </span>
  </div>
END_HTML

text =<<TEXT
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

def init(text, template)
  html = text.split("\n\n")
  .sample
  .gsub('　', '')
  .gsub("\n", '')
  .chars[0, 48]
  .map do |charactor|
    template.result_with_hash charactor:
  end.join

  content = JS.global.document.querySelector ".content"
  content.innerHTML = html
end

init(text, template)


