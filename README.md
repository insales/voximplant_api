# VoximplantApi

Voximplant HTTP API wraper
http://voximplant.com/docs/references/httpapi/

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voximplant_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install voximplant_api

## Usage

```ruby
client = VoximplantApi::Client.new account_id: 123, api_key: 'apikey-trololo'
client.get_account_info
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/voximplant_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
