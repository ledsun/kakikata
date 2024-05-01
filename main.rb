require 'js/require_remote'

module OrbitalRing
  module Util
    refine String do
      def to_snake_case = self.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
    end

    refine Symbol do
      def to_snake_case = self.to_s.to_snake_case
    end
  end

  class Loader
    attr_accessor :dir

    using OrbitalRing::Util

    def setup
      Loader.define_const_missing Object, @dir
    end

    private

    def self.define_const_missing(mod, dir)
      mod.define_singleton_method(:const_missing) do |id|
        module_name = id.to_snake_case

        JS::RequireRemote.instance.load("#{dir}/#{module_name}")
        p "#{module_name} loaded!"

        loaded_module = const_get(id)
        Loader.define_const_missing loaded_module, dir
        loaded_module
      end
    end
  end
end


loader = OrbitalRing::Loader.new
loader.dir = 'app_root'
loader.setup

App.new
