require 'erb'
require 'js'

module OrbitalRing
  class Renderer
    include Singleton

    def self.render(template, locals)
      self.instance.render template, locals
    end

    def render(template_name, locals)
      unless @templates[template_name]
        url = "app_root/#{Util.to_snake_case(template_name)}.html.erb"
        response = JS.global.fetch(url).await
        raise "Failed to fetch template: #{url}" unless response[:status].to_i == 200

        template_string = response.text().await.to_s
        template = ERB.new(template_string)
        @templates[template_name] = template
      end

      @templates[template_name].result_with_hash(locals)
    end

    def initialize
      @templates = {}
    end
  end
end

class View
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
      OrbitalRing::Renderer.render :Page, characters:
    end
  end
end
