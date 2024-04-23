require 'js/require_remote'

module OrbitalRing
  refine String do
    def to_snake_case = self.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  end

  refine Symbol do
    def to_snake_case = self.to_s.to_snake_case
  end
end

using OrbitalRing

# 定数名からモジュールをオートーロードします。
def Object.const_missing(id)
  module_name = id.to_snake_case
  JS::RequireRemote.instance.load(module_name)
  p "#{module_name} loaded!"

  mod = const_get(id)
  # 読み込んだモジュールに、サブモジュールのオートーロードを定義します。
  mod.define_singleton_method(:const_missing) do |sub_id|
    path = self.name.to_s.split('::')
                         .map(&:to_snake_case)
                         .join('/')
    module_name = "#{path}/#{sub_id.to_snake_case}"
    JS::RequireRemote.instance.load(module_name)
    p "#{module_name} loaded!"

    const_get(sub_id)
  end

  mod
end

App.new
