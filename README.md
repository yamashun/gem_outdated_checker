# GemOutdatedChecker
GemOutdatedChecker is the gem to gets an array of outdated gems maintained by the bundler.
The usage scenario assumes that batch processing will periodically retrieve outdated gems and notify you (For example, by slack or mail).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gem_outdated_checker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gem_outdated_checker

## Usage

```ruby
require "gem_outdated_checker"

GemOutdatedChecker::GemList.new.outdated_gems
# => ["  * actioncable (newest 5.2.3, installed 5.1.5)",
# "  * actionmailer (newest 5.2.3, installed 5.1.5)",
# "  * actionpack (newest 5.2.3, installed 5.1.5)",
# "  * actionview (newest 5.2.3, installed 5.1.5)",
# "  * activemodel (newest 5.2.3, installed 5.1.5)",
#      .
#      .
#      .
# "  * yard (newest 0.9.19, installed 0.8.7.6)"]
```

If you want to exclude some gems from the target for some reason, add the target string to the config.

```ruby
GemOutdatedChecker::GemList.configure do |config|
  config.exclude_gems = %w(actionpack actionview)
end

GemOutdatedChecker::GemList.new.update_required_gems
```

### Public methods
`GemOutdatedChecker::GemList` class has following three public methods.

| public method | return gem list |
----|----
| outdated_gems | all outdated gems |
| update_required_gems | outdated gems excluding `config.exclude_gems` |
| pending_gems | outdated_gems - update_required_gems |

### Bundle path

GemOutdatedChecker exec `bundle outdated` to get outdated_gems gems.
If you want to change the bundle path, the following configure enable:

```ruby
GemOutdatedChecker::GemList.configure do |config|
  config.bundle_path = "./bin/bundle"
end
# => exec `./bin/bundle outdated` to get outdated_gems gems.
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

