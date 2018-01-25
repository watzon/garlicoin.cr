# garlicoin.cr

WIP Garlicoin API connection library in Crystal. Connects to the garlicoin daemon via JSON-RPC and uses it's built in commands to examine the blockchain, send money, interact with your wallet, and more.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  garlicoin:
    github: watzon/garlicoin
```

## Usage

```crystal
require "garlicoin"

# Connect to garlicoind using the information supplied in your garlicoin.conf file
client = Garlicoin::Client.new("localhost", 42070, "username", "password")

accounts = client.list_accounts
pp accounts # => { "": 2.53575342 }

# Or you can lead your config from your garlicoin.conf directly
conf = Garlicoin::Config.load
client = Garlicoin::Client.new(conf)

accounts = client.list_accounts
pp accounts # => { "": 2.53575342 }
```

## Contributing

1. Fork it ( https://github.com/watzon/garlicoin.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [watzon](https://github.com/watzon) Chris Watson - creator, maintainer
