# Ruby API for Digipost from Posten

Simple Ruby API for sending messages through Digipost from The Norwegian Postal Service (Posten).

## Getting started

### Prerequisites

* An account with Digipost
* A private key for sending messages

### Configuration

````ruby
user_id     = 12345 #
certificate = '' # Not needed for now
private_key = File.new('path/to/your/private_key').read
Digipost::Service.configure(user_id, certificate, private_key)
````

### Sending messages

````ruby
# Prepare message
message = Digipost::Api::Representations::Message.new
message.recipient = "digipost-user#1235"
message.subject   = "Hi there!"
message.authentication_level = 'PASSWORD' # or 'TWO_FACTOR'
message.sms_notification     = false # or true
message.date = Time.now
message.pdf  = File.read('path/to/your/pdf_file')

# Send the message
service = Digipost::Service.new
service.send_message(message)
````

And that should be about it :)


## How to contribute

1. Fork this project
2. `bundle install`
3. `bundle exec rspec spec/**/*_spec.rb`
4. Add your features, please add specs for it
5. Request a pull request