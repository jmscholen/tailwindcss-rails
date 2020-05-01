# frozen_string_literal: true

require 'rails/generators/base'

module Tailwindcss
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      def yarn_add_tailwindcss
        run "yarn --ignore-engines add tailwindcss@1.2.0 --tilde"
      end

      def init_tailwindcss_and_add_tailwindui
        run "./node_modules/.bin/tailwind init ./tailwind.config.js"
        inject_into_file "./tailwind.config.js", "    require('@tailwindcss/ui'),\n", after: "plugins: ["
        inject_into_file "./tailwind.config.js", "        sans: ['Inter var', ...defaultTheme.fontFamily.sans],\n", after: "fontFamily: {\n"
      end

      def setup_directories
        run "mkdir -p app/javascript/stylesheets"
        run "mv app/assets/stylesheets/application.css app/javascript/stylesheets/application.scss"
      end

      def add_alpine_library
        inject_into_file "app/views/layouts/application.html.erb", '<script src="https://cdn.jsdelivr.net/gh/alpinejs/alpine@v2.0.1/dist/alpine.js" defer></script>', after: "<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>\n"
      end

      def setup_tailwindcss
        template "tailwind.css", "app/javascript/stylesheets/application.scss"
        append_to_file "app/javascript/packs/application.js", "import '/stylesheets/application.scss'"
      end

      def configure_postcssrc
        inject_into_file "postcss.config.js", "    require('tailwindcss'),\n", after: "require('postcss-import'),\n"
        inject_into_file "postcss.config.js", "    require('autoprefixer'),\n", after: "plugins: [\n"
      end

      def remove_corejs_3
        gsub_file "babel.config.js", /regenerator: true,\n          corejs: 3/, "regenerator: true,"
      end
    end
  end
end
