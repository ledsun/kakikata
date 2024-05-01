require 'erb'
require 'js'

module OrbitalRing
  module Renderer
    def self.included(base)
      # テンプレートをキャッシュする変数を定義
      base.define_method(:tempaltes_cache) { @tempaltes_cache ||= {} }
    end

    def render(template_name, locals)
      tempaltes_cache[template_name] = load_template(template_name) unless tempaltes_cache[template_name]

      # テンプレート内でrenderメソッドを使えるようにするために
      # このメソッドのbindingを指定します。
      b = binding
      locals.each { |key, value| b.local_variable_set key, value }
      tempaltes_cache[template_name].result b
    end

    private

    def load_template(template_name)
      # テンプレート名から、ファイル名を決定します。
      url = "app_root/#{Util.to_snake_case(template_name)}.html.erb"
      response = JS.global.fetch(url).await
      raise "Failed to fetch template: #{url}" unless response[:status].to_i == 200

      ERB.new(response.text().await.to_s)
    end
  end
end

class View
  include OrbitalRing::Renderer

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
      render :Page, characters:
    end
  end
end
