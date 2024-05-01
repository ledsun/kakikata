require 'js/require_remote'

module OrbitalRing
  module Util
    def self.to_snake_case(symbol)
      symbol.to_s
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .downcase
    end
  end

  class Loader
    attr_accessor :dir

    def setup
      Loader.define_const_missing Object, @dir
    end

    private

    def self.define_const_missing(mod, dir)
      mod.define_singleton_method(:const_missing) do |id|
        module_name = Util.to_snake_case(id)

        JS::RequireRemote.instance.load("#{dir}/#{module_name}")
        p "#{module_name} loaded!"

        loaded_module = const_get(id)
        Loader.define_const_missing loaded_module, dir
        loaded_module
      end
    end
  end
end
