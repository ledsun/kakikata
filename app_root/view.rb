require 'erb'
require 'js'

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
    phrase.gsub(/[^ぁ-んァ-ンー-龠々]/, '')
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
