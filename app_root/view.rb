require 'erb'
require 'js'

class View
  # 1文字分のHTMLテンプレート
  CharacterTemplate = ERB.new(<<~'END_HTML')
  <div class="character">
    <span>
      <%= character %>
    </span>
  </div>
  END_HTML

  PageTemplate = ERB.new(<<~'END_HTML')
  <div class="page">
    <div class="grid">
      <% characters.each do |character| %>
        <%= View.render :Character, character: %>
      <% end %>
    </div>
  </div>
  END_HTML

  def self.render(template, locals)
    template = const_get(template.to_s + 'Template')
    template.result_with_hash(locals)
  end

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
            pages << chars
          end

    @html_element[:innerHTML] = pages.map do |characters|
      View.render :Page, characters:
    end
  end
end
