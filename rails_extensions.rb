module Rails
  module Generators
    module Actions
      def recipe(name)
        File.join(File.dirname(__FILE__), 'recipes', "#{name}.rb")
      end
    end
  end
end
