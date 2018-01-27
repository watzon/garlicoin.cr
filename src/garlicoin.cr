require "./core_extensions/*"
require "./garlicoin/models/*"
require "./garlicoin/*"

# This is a wrapper for the Garlicoin daemon's JSON-RPC API. All of the commands that are
# avaialble via the `garlicoin-cli` utility are also available here, in snake_cased_form.
# This includes commands such as `get_wallet_info` and `send_to_address`. Commands that
# return a large JSON object will typically map said object to a class using
# `JSON.mapping`. This makes it a lot easier to navigate them than with a typical
# `JSON::Any` object, as well as leaving the door open for future improvements.
#
# ## Example use
#
# ```crystal
# require "garlicoin"

# # Connect to garlicoind using the information supplied in your garlicoin.conf file
# client = Garlicoin::Client.new("localhost", 42070, "username", "password")

# accounts = client.list_accounts
# pp accounts # => { "": 2.53575342 }

# # Or you can lead your config from your garlicoin.conf directly
# conf = Garlicoin::Config.load
# client = Garlicoin::Client.new(conf)

# accounts = client.list_accounts
# pp accounts # => { "": 2.53575342 }
# ```
module Garlicoin

  def self.version
    return VERSION
  end

end

config = Garlicoin::Config.load
client = Garlicoin::Client.new(config)

pp client.get_block("fb2d21d39fac92011a48b6ebddd192e764021d7f1351e93a1f1e717383fb4e93")
