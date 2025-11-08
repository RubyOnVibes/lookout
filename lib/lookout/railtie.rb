module Lookout
  class Railtie < ::Rails::Railtie
    initializer "lookout.assets.precompile" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w[lookout/manifest]
      end
    end
  end
end
