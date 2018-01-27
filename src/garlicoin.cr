require "./core_extensions/*"
require "./garlicoin/models/*"
require "./garlicoin/*"

# TODO: Write documentation for `Garlicoin`
module Garlicoin
  # TODO: Put your code here
end

config = Garlicoin::Config.load
client = Garlicoin::Client.new(config)

tx = client.list_wallets
pp tx
