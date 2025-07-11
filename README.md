# SMS Factor

An easy way to use API SMS of http://www.smsfactor.com/ (http://www.smsfactor.com/api-sms/)

---

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
    - [Sending a SMS](#sending-a-sms)
    - [Sub Accounts](#sub-accounts)
    - [Tokens](#tokens)
    - [Error Handling](#error-handling)
- [Development](#development)
- [Copyright](#copyright)

---

# Installation

You can install sms_factor by adding this line in your Gemfile :

```
gem 'sms_factor'
```

And then run :

```
bundle install
```

# Configuration

To use this gem, configure SmsFactor using your API information :

```ruby
SmsFactor::Init.configure do |config|
  # config.api_url = 'http://api.smsfactor.com'
  # config.verify_ssl = false
  config.api_default_from = '<a default sender name>'

  # Authentications
  # 1. API key (recommended)
  config.api_key = '<your API key>'

  # 2. email / password (legacy)
  # config.api_login = '<your_email@your_company.com>'
  # config.api_password = '<your_password>'
end
```

# Usage

## Sending a SMS

You can send an SMS easily with the following methods:

```ruby
r = SmsFactor.sms('Hello World', '336++++++++') # to a single recipient
r = SmsFactor.sms('Hello World', ['336++++++++', '336++++++++', '336++++++++']) # to multiple recipients
r = SmsFactor.sms('Hello World', '336++++++++', 'Toto') # to override default from

# Retrieve credit after the sms was sent
r.credit
```

You can also send an SMS with a custom API key, for example if you want to send on behalf of a sub account:

```ruby
sms = SmsFactor::Sms.new(
  message: 'Hello from subaccount!',
  recipients: ['336++++++++']
)

sms.deliver(api_key: '<subaccount API key>')
```

If you do not pass an api_key, the gem will use the default API key configured for the main account.

## Sub Accounts

### API Key Behavior
Important:
> For all sub-account or token calls, if you do not pass an api_key argument, the gem will automatically use the API key configured globally (i.e. your main account).
> To act on behalf of a sub-account, pass its API key explicitly in the method’s parameters.

### Initialize API
```ruby
api = SmsFactor::SubAccount.new
```

### Create a sub account

Creates a new sub account under your main SMS Factor account.

```ruby
response = api.create(
  email: 'sub@example.com',
  password: 'SuperSecure123',
  type: SmsFactor::SubAccount::COMPANY,
  firstname: 'John',
  lastname: 'Doe'
)

# Response contains:
# response.id
# response.active
```

You must provide one of the following values for the `type` field:
- `"company"`
- `"association"`
- `"administration"`
- `"private"`

### List sub accounts

Lists all sub accounts belonging to your main account.

```ruby
response = api.list
response.sub_accounts.each do |sub_account|
  puts sub_account.client_id
  puts sub_account.email
end
```

### Get a single sub account

Fetches details of a specific sub account by its client ID.

```ruby
response = api.get(1234)
puts response.sub_account.email
puts response.sub_account.credits
```

### Lock or unlock a sub account

Locks or unlocks a sub account to prevent or allow usage.

SMS Factor API does not provide any way to delete a sub account once created.  
Locking a sub account is the only way to effectively disable it.

```ruby
api.lock(1234)
api.unlock(1234)
```

### Transfer credits to a sub account

Transfers a given number of credits from the main account to a sub account.

This operation **allocates credit rights** to the sub account, allowing it to send SMS messages.  
Credits are **not deducted** from the main account balance at the time of transfer. They are only deducted from the main account when the sub account actually sends SMS messages.

```ruby
response = api.transfer_credits(1234, 300)
puts response.credits
puts response.child_credits
```

### Check balance

Retrieves the available credits for your main account or a sub account.

```ruby
# For the main account (uses the configured API key)
response = api.balance
puts response.credits

# For a sub account
response = api.balance('<sub_account_api_key>')
puts response.credits

```

## Tokens

### Initialize API

```ruby
api = SmsFactor::Token.new
```

### Create token for main account

```ruby
response = api.create_for_main_account(
  name: 'IntegrationToken',
  ttl: 3600,
  allowed_ips: ['1.2.3.4']
)

# Response contains:
# response.token
# response.token_id
```

### Create token for sub account

Creates an API token for a specific sub account.

Tokens allow the sub account to perform API operations independently of the main account.

**Important:** The token value (the API key string itself) is only available in the response of the creation call. Once created, you can no longer retrieve the token value through the API; only the metadata (such as `name`, `ttl`, `allowed_ips`, ...) remains accessible in future calls.

```ruby
response = api.create_for_sub_account(
  sub_account_id: 1234,
  name: 'SubToken',
  ttl: 1800,
  allowed_ips: ['1.2.3.4']
)

puts response.token
puts response.token_id
```

### List tokens

Retrieves the list of all tokens (main account or sub accounts) currently configured.

```ruby
response = api.list(api_key: '<sub-account api key>')
response.tokens.each do |token|
  puts token.name
  puts token.api_token_id
end
```

### Get details of a specific token

Fetches details for a specific token.

```ruby
response = api.get(token_id: 12, api_key: '<sub-account api key>')
puts response.token.name
puts response.token.created_at
```

### Delete a token

Deletes an API token.

This will immediately revoke the token’s ability to authenticate further API calls.

```ruby
response = api.delete(token_id: 12, api_key: '<sub-account api key>')
puts response.deleted_token
```

## Error Handling

When the API returns an error status code, the gem raises specific exceptions:

- `SmsFactor::AuthError`
- `SmsFactor::NotEnoughCreditsError`
- `SmsFactor::ResourceNotFoundError`
- `SmsFactor::InvalidTokenIdError`
… and other custom errors defined in the gem.

Example:

```ruby
begin
  api.get(999)
rescue SmsFactor::ResourceNotFoundError => error
  puts error.message
end
```

# Development

In the case you have [Docker](https://www.docker.com/) on you machine, you can
use the [Earthly](https://earthly.dev/) tool in order to build a Docker image
with all the dependencies for this project and run the test suite:

```
earthly --allow-privileged +rspec
```
_This command will build the image the first time, and then run the unit testing
frameworr Rspec._

Earthly reduces the differences between your machine and your CI by isolating
Docker in Docker. Running the tests in Earthly on your machine will run the same
as running on your CI. The only differences remaining are CPU and Internet
speed.

While developing, you will prefer using `docker-compose` to run in a quicker
manner your commands:

```
docker-compose run --rm gem rubocop
```
_The Docker ENTRYPOINT being `bundle exec` all the passed commands are prefixed
and make rspec, rubocop and the other Ruby commands available without writing
`bundle exec`._

# Copyright

Copyright (c) 2015 Julien Séveno
