class View
  include OrbitalRing::Renderer

  def initialize(html_element)
    @html_element = html_element
  end

  # 画面に表示する
  def update(phrase)
    pages = filter(phrase).chars
                          .each_slice(48) # 1ページに表示する文字数は48文字
                          .map { |chars| fill chars }
                          .map { |characters| {characters:} }

    @html_element[:innerHTML] = render :page, collection: pages
  end

  private

  # ひらがな、カタカナ、漢字を抽出
  def filter(phrase) = phrase.gsub(/[^ぁ-んァ-ンー-龠々]/, '')

  # 48文字に満たない場合に左寄せで表示されます。
  # 右寄せするために、足りない文を空文字で埋めます。
  def fill(chars) = chars.fill nil, chars.length..47
end
