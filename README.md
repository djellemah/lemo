# Lemo

Yet another memoize gem. Because it does some things that are important to me.

Attention paid to performance:

* rewrites the memoized method for fast normal-path execution. Rewritten method
only makes calls to ruby methods, apart from the necessary single call to the
original method.

* Uses instance variables for memoisation storage.

`Lemo::Memo` treats nil as a value, in other words uses presence or absence of
an instance variable to establish whether the value has been memoised or not.
Can clear one or several or all memoized values.

`Lemo::Ormo` behaves like `@ivar ||=` so clearing is just setting `@ivar`
to `nil`. Or removing it.

`_memoed_methods` gives a hash of methods that have been memoised, and their
unmemoised method bodies.

Works on singleton instances. Although the syntax is clunky and best avoided.

Is just as threadsafe as `||=` (in other words it mostly isn't)

Will raise an exception if you attempt to memoise methods with parameters.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lemo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lemo

## Usage

``` ruby
require 'lemo/ormo'

class YourThing
  include Lemo::Ormo # or Lemo::Memo if you want nil-as-a-value and specialised clearing.

  def normal_method
    rand
  end

  memo def expensive_calculation
    # do complicated stuff that is referentially transparent
  end
end

your_thing = YourThing.new
your_thing.expensive_calculation
your_thing.clear_memos
```

## Development

`rspec` to run specs

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/djellemah/lemo.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
