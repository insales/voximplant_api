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
client.get_account_info # request command "GetAccountInfo"

client.get_phone_number_categories(country_code: 'ru')
=> {"result"=>
  [{"country_code"=>"RU",
    "can_list_phone_numbers"=>true,
    "phone_categories"=>
     [{"phone_installation_price"=>0.0, "phone_period"=>"0-1-0 0:0:0", "phone_category_name"=>"GEOGRAPHIC", "country_has_states"=>false, "phone_price"=>300.0},
      {"phone_installation_price"=>0.0, "phone_period"=>"0-1-0 0:0:0", "phone_category_name"=>"MOBILE", "country_has_states"=>false, "phone_price"=>300.0},
      {"phone_installation_price"=>0.0, "phone_period"=>"0-1-0 0:0:0", "phone_category_name"=>"MOSCOW495", "country_has_states"=>false, "phone_price"=>500.0},
      {"phone_installation_price"=>3000.0, "phone_period"=>"0-1-0 0:0:0", "phone_category_name"=>"TOLLFREE", "country_has_states"=>false, "phone_price"=>1500.0}],
    "phone_prefix"=>"7"}],
 "count"=>1}

```

Or you can use modern api authentication mechanism:

```ruby
client = VoximplantApi::Client.new(account_id: 123, private_key: 'private key credentials goes here', private_key_id: 'private-key-uuid')
client.get_account_info

```

You can download scenario execution log file or phone call record via:

```
client.execute(
  method: :post,
  url: "https://storage.voximplant.com/voximplant-records-secure/2023/04/03/...",
  raw_response: true
)

```

## Pagination and each
Just add 'each_' prefix to method
```ruby
client.each_get_transaction_history(from_date: Time.now - 1592000).to_a
#or
client.each_get_transaction_history(from_date: Time.now - 1592000) do |obj|
  # do something
end
```

## Errors

```ruby
begin
  client.get_account_info
rescue VoximplantApi::Error => e
  puts e
end

begin
  client.not_existing_method
rescue NoMethodError => e
  puts e
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/voximplant_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
