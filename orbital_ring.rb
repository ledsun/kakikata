require 'js/require_remote'

module OrbitalRing
  class Loader
    attr_accessor :dir

    def setup
      Loader.define_const_missing @dir, Object
    end

    private

    # const_missingを定義して、見つからない定数をリモートから読み込む
    def self.define_const_missing(dir, mod)
      mod.define_singleton_method(:const_missing) do |id|
        # 定数名をスネークケースに変換して、リモートから読み込む
        feature_name = Util.to_snake_case(id)
        JS::RequireRemote.instance.load("#{dir}/#{feature_name}")

        # 読み込んだモジュールにconst_missingを定義する
        loaded_module = const_get(id)
        Loader.define_const_missing dir, loaded_module
        loaded_module
      end
    end
  end

  module Util
    def self.to_snake_case(symbol)
      symbol.to_s
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .downcase
    end
  end
end
