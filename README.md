# Bambora::BatchUpload

Unofficial ruby wrapper for EFT batch uploads to Bambora.

Under development

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bambora-batch_upload'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bambora-batch_upload

## Usage

To configure the upload, you must provide your merchant ID as well as Batch
Upload API Key. The default location for batch files (before uploading) is /tmp.

```ruby
  Bambora::BatchUpload.configure do |config|
    config.merchant_id          = "111111111" #9 digits
    config.batch_upload_api_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    #optional
    config.batch_file_path      = "/tmp"    #default
    config.batch_upload_api_url = "https://api.na.bambora.com/v1/batchpayments" #default
  end
```

To create a batch file and then upload:

```ruby
  #payment type has to be D (debit) or C (credit)
  #amount must be specified in pennies
  #if reference is not specified, it will be set to 0
  #recipient and dynamic descriptor are optional
  Bambora::BatchUpload.create_file do |reader|
    reader.push_into_file(payment_type: "D", amount: 100, reference: 34, 
                          customer_code: "C6777B381C16434B82d40A8d23a19a68",
                          dynamic_descriptor: "Wesam Corp") 
    reader.push_into_file(payment_type: "D",
                          institution_number: "123",
                          transit_number: "12345",
                          account_number: "123458",
                          amount: 200,
                          reference: 667,
                          recipient: "Haddad"
                          )
    ##more lines
    #reader.push_into_file(...)
  end
   
  #by default process date is next business day
  Bambora::BatchUpload.do_upload(process_date) do |batch_id|
    #callback here
    puts "Upload is successful and batch id is #{batch_id}"
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alwesam/bambora-batch_upload. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bambora::BatchUpload project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alwesam/bambora-batch_upload/blob/master/CODE_OF_CONDUCT.md).
