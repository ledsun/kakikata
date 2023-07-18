require 'js'
require 'erb'


class JS::Object
  def method_missing(sym, *args, &block)
    if sym == :new
      # new で呼び出されたら、コンストラクタとして呼び出す。
      JS.eval("return #{self.to_construct(args)}")
    elsif self[sym].typeof == "function"
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

  # When call new, received self is like a 'function URLSearchParams() { [native code] }'
  # so, we need to convert it to 'new URLSearchParams()'
  def to_construct(args)
    "new #{constructor_name}(#{to_js_argument_string(args)})"
  end

  def constructor_name
    self.to_s.match(/function\s+([^(]+)/)[1].strip
  end

  # When call new, received argument is like a '["?phrase=%E3%81%82%E3%81%84%E3%81%86"]"
  # But converting string strips double quotes, so we need to add double quotes.
  def to_js_argument_string(args)
    "#{args.map do
      to_string_with_quote _1
    end.join(', ')}"
  end

  # Convert to string with double quotes.
  # Support Ruby String and JavaScript String both.
  def to_string_with_quote(var)
    var.is_a?(String) || var.typeof == "string" ? "\"#{var}\"" : var.to_s
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

def set(phrase, template)
  html = phrase.gsub('　', '')
               .gsub("\n", '')
               .chars[0, 48]
               .map { |character| template.result_with_hash character: }
               .join

  content = JS.global.document.querySelector ".content"
  content.innerHTML = html
end

def init(text, template)
  phrase = text.split("\n\n")
               .sample

  set phrase, template
end

JS.global.document.querySelector('button').addEventListener 'click' do
  statements = JS.global.document.querySelector '.statements'
  phrase = statements.value.to_s
  set phrase, template
end

searchParams = JS.global[:URLSearchParams].new(JS.global[:location][:search])
if searchParams.has('phrase') == JS.eval('return true;')
  phrase = searchParams.get('phrase').to_s
  set phrase, template
else
  init text, template
end