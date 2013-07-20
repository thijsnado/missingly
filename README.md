# Missingly

A DSL for handling method\_missing hooks.

[![Code Climate](https://codeclimate.com/github/moger777/missingly.png)](https://codeclimate.com/github/moger777/missingly)
[![Build Status](https://travis-ci.org/moger777/missingly.png?branch=master)](https://travis-ci.org/moger777/missingly)
[![Coverage Status](https://coveralls.io/repos/moger777/missingly/badge.png?branch=master)](https://coveralls.io/r/moger777/missingly?branch=master)

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

### Use custom matchers

In the example with the regex block matchers, our code has to do a
fair amount of work which is not looking up a value in a hash, for example:

```ruby
fields = matches[1].split("_and_")
```

will run every time and can have a performance impact. Likewise we
are always running:

```ruby
field.to_sym
```

In the hash lookup. If the field was already a symbol, there would be less work. And
the fields were already split up, there would be less work each time. Custom block
matchers can be done as follows:

```ruby
class OurMatcher < Missingly::BlockMatcher
  attr_reader :some_matcher, :options_hash, :method_block

  def initialize(some_matcher, options_hash, method_block)
    @some_matcher, @method_block = some_matcher, method_block
  end

  def should_respond_to?(instance, name)
    # our custom code
  end

  def setup_method_name_args(method_name)
    # args we will pass to block
  end

  def matchable; some_matcher; end
end
```

Since we essentially want to re-use the regex block helper, we can inherit and override
setup_method_name_args. These args will be passed to the block in the handle_missingly
call:

```ruby
class FindByFieldsWithAndsMatcher < Missingly::RegexBlockMatcher
  def initialize(regex, options, block)
    super regex, block
  end

  def setup_method_name_args(method_name)
    matches = regex.match(method_name)
    fields = matches[1].split("_and_")
    fields.map(&:to_sym)
  end
end
```

From here, we can use our custom matcher:

```ruby
class ArrayWithHashes
  include Missingly::Matchers

  handle_missingly /^find_by_(\w+)$/, with: FindByFieldsWithAndsMatcher do |fields, *args, &block|
    hashes.find do |hash|
      fields.inject(true) do |fields_match, field|
        index_of_field = fields.index(field)
        arg_for_field = args[index_of_field]

        fields_match = fields_match && hash[field] == arg_for_field
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
instance.respond_to?(:find_by_name_and_gender) # true
instance.method(:find_by_name_and_gender) # method object
```

For more fine grain controll, you can write should_respond_to? which should
return true if method responds to, and handle, which should define method and
return results of first run of method.

### How inheritance works

The handle_missingly method is designed to be both inherited and overwritable by
child classes. The following scenarios should work:

Straight up inheritance:

```ruby
class Parent
  handle_missingly /foo/ do
    :foo
  end
end

class Child < Parent
end

Child.new.foo # should return :foo
```

Overwriting:

```ruby
class Parent
  handle_missingly /foo/ do
    :foo
  end
end

class Child < Parent
  handle_missingly /foo/ do
    :bar
  end
end

Child.new.foo # should return :bar
```

Missingly handlers are based off of "matchable" passed to matcher, so the following
will also be overwritten:

```ruby
class Parent
  handle_missingly /foo/ do
    :foo
  end
end

class Child < Parent
  handle_missingly /foo/, to: :something
end

Child.new.foo # should return whatever something returns
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. Please no tabs or trailing whitespace
7. Features and bug fixes should have specs
