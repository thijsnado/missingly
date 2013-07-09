module Missingly
  module Matchers
    module ClassMethods
      def missingly_reader(array, hash)
        handle_missingly array do |method_name|
          @hash[method_name]
        end
      end
      
      def missingly_writer(array, hash)
        writers = array.map { |x| (x.to_s + "=").to_sym }
        handle_missingly writers do |method_name, new_value|
          @hash[(method_name.to_s[0..method_name.to_s.length - 2]).to_sym] = new_value
        end
      end
      
      def missingly_accessor(array, hash)
        missingly_reader(array, hash)
        missingly_writer(array, hash)
      end
    end
  end
end