# Missingly

A DSL for handling method\_missing hooks.

## Installation

Add this line to your application's Gemfile:

    gem 'missingly'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install missingly

## Usage

### Use regular expression matching

```ruby
class ArrayWithHashes
  include Missingly::Matchers

  handle_missingly /^find_by_(\w+)$/ do |matches, *args, &block|
    fields = matches[1].split("_and_")
    hashes.find do |hash|
      fields.inject(true) do |fields_match, field|
        index_of_field = fields.index(field)
        arg_for_field = args[index_of_field]

        fields_match = fields_match && hash[field.to_sym] == arg_for_field
        break false unless fields_match
        true
      end
    end
  end

  handle_missingly /^find_all_by_(\w+)$/ do |matches, *args, &block|
    fields = matches[1].split("_and_")
    hashes.find_all do |hash|
      fields.inject(true) do |fields_match, field|
        index_of_field = fields.index(field)
        arg_for_field = args[index_of_field]

        fields_match = fields_match && hash[field.to_sym] == arg_for_field
        break false unless fields_match
        true
      end
    end
  end

  attr_reader :hashes

  def initialize(hashes)
    @hashes = hashes
  end
end

hashes = [
  { id: 1, name: 'Pat', gender: 'f' },
  { id: 2, name: 'Pat', gender: 'm' },
  { id: 3, name: 'Steve', gender: 'm' },
  { id: 4, name: 'Sue', gender: 'f' },
]

instance = ArrayWithHashes.new(hashes)
instance.find_by_name_and_gender('Pat', 'm') # { id: 2, name: 'Pat', gender: 'm' }
instance.find_all_by_name('Pat') # both male and female Pat's
instance.respond_to?(:find_by_name_and_gender) # true
instance.method(:find_by_name_and_gender) # method object
```

### Use array matching

```ruby
class NetJSON
  include Missingly::Matchers

  handle_missingly [:get, :put, :post, :delete] do |method_name, url, params|
    uri = URI.parse(url)

    requester = Net::HTTP.new(uri.host, uri.port)
    request = "Net::HTTP::#{method_name.to_s.classify}".constantize.new(uri.path)

    request.body = params.to_json

    requester.request(request)
  end
end

requester = NetJSON.new
requester.get 'http://www.example.com/some_path/', {first_name: 'John'}
requester.put 'http://www.example.com/some_resource/1/', {admin: true}
```

### Use for delegation

```ruby
class UserDecorator
  include Missingly::Matchers

  handle_missingly [:roles], to: :user

  def can_edit?
    roles.include?(:editor)
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
