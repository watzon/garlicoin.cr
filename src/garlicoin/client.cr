require "json"
require "json_rpc"
require "http/client"

module Garlicoin

  class Client < JsonRpc::HttpClient

    # Create a new `Client` using connection information for the `garlicoind` rpc server.
    def initialize(host : String, port : Int32, user : String, password : String)
      # Set up the HTTP client
      http_client = HTTP::Client.new(host, port)
      http_client.basic_auth(user, password)

      # Turn it into a JSON-RPC client
      super http_client
    end

    # Create a new `Client` by utilizing a `Config` object. This config object can be
    # created manually or by loading an existing config file.
    def self.new(config : Config)
      host = config.get("rpcallowip").split('/')[0]
      port = config.get("rpcport").to_i
      user = config.get("rpcuser")
      password = config.get("rpcpassword")
      new(host, port, user, password)
    end

    # Mark in-wallet transaction <txid> as abandoned
    # This will mark this transaction and all its in-wallet descendants as abandoned which will allow
    # for their inputs to be respent.  It can be used to replace "stuck" or evicted transactions.
    # It only works on transactions which are not included in a block and are not currently in the mempool.
    # It has no effect on transactions which are already conflicted or abandoned.
    def abandon_transaction(txid : String)
      call(JsonRpc::Response(String), "abandontransaction", [txid])
    end

    # Stops current wallet rescan triggered e.g. by an import_prov_key call.
    def abort_rescan
      call(JsonRpc::EmptyResponse, "abortrescan")
    end

    # Add a nrequired-to-sign multisignature address to the wallet.
    # Each key is a Garlicoin address or hex-encoded public key.
    # If 'account' is specified (DEPRECATED), assign address to that account.
    def add_multi_sig_address(nrequired : String, keys : Array(String), account : String? = nil)
      call(JsonRpc::Response(Bool), "addmultisigaddress", [nrequired, key_arr, account])
    end

    # Add a witness address for a script (with pubkey or redeemscript known).
    # It returns the witness script.
    def add_witness_address(address : String)
      call(JsonRpc::Response(String), "addwitnessaddress", [address])
    end

    # Safely copies current wallet file to destination, which can be a directory or a path with filename.
    def backup_wallet(destination : String)
      call(JsonRpc::EmptyResponse, "backupwallet", [destination])
    end

    # Bumps the fee of an opt-in-RBF transaction T, replacing it with a new transaction B.
    # An opt-in RBF transaction with the given txid must be in the wallet.
    # The command will pay the additional fee by decreasing (or perhaps removing) its change output.
    # If the change output is not big enough to cover the increased fee, the command will currently fail
    # instead of adding new inputs to compensate. (A future implementation could improve this.)
    # The command will fail if the wallet or mempool contains a transaction that spends one of T's outputs.
    # By default, the new fee will be calculated automatically using estimatefee.
    # The user can specify a confirmation target for estimatefee.
    # Alternatively, the user can specify totalFee, or use RPC settxfee to set a higher fee rate.
    # At a minimum, the new fee rate must be high enough to pay an additional new relay fee (incrementalfee
    # returned by getnetworkinfo) to enter the node's mempool.
    def bump_fee(txid : String, options = nil)
      call(JsonRpc::EmptyResponse, "bumpfee", [txid, options])
    end

    # Reveals the private key corresponding to 'address'.
    # Then the importprivkey can be used with this output
    def dump_private_key(address : String)
      call(JsonRpc::EmptyResponse, "dumpprivkey", [address])
    end

    # Dumps all wallet keys in a human-readable format.
    def dump_wallet(filename : String)
      call(JsonRpc::EmptyResponse, "dumpwallet", [filename])
    end

    # Encrypts the wallet with 'passphrase'. This is for first time encryption.
    # After this, any calls that interact with private keys such as sending or signing
    # will require the passphrase to be set prior the making these calls.
    # Use the walletpassphrase call for this, and then walletlock call.
    # If the wallet is already encrypted, use the walletpassphrasechange call.
    # Note that this will shutdown the server.
    def encrypt_wallet(passphrase : String)
      call(JsonRpc::EmptyResponse, "encryptwallet", [passphrase])
    end

    # DEPRECATED. Returns the account associated with the given address.
    def get_account(address : String)
      call(JsonRpc::Response(String), "getaccount", [address])
    end

    # DEPRECATED. Returns the current Garlicoin address for receiving payments to this account.
    def get_account_address(account : String)
      call(JsonRpc::Response(String), "getaccountaddress", [account])
    end

    # DEPRECATED. Returns the list of addresses for the given account.
    def get_addresses_by_account(account : String)
      call(JsonRpc::Response(Array(String)), "getaddressesbyaccount", [account])
    end

    # If account is not specified, returns the server's total available balance.
    # If account is specified (DEPRECATED), returns the balance in the account.
    # Note that the account "" is not the same as leaving the parameter out.
    # The server total may be different to the balance in the default "" account.
    def get_balance(account = nil, minconf = 1, include_watch_only = false)
      call(JsonRpc::Response(Float64), "getbalance", [account, minconf, include_watch_only])
    end

    # Returns the hash of the best (tip) block in the longest blockchain.
    def get_best_block_hash
      call(JsonRpc::Response(String), "getbestblockhash")
    end

    # Returns an Object with information about block <hash> and information about each transaction.
    def get_block(hash : String)
      call(JsonRpc::Response(Models::Block), "getblock", [hash, 2])
    end

    # Returns an object containing various state info regarding blockchain processing.
    def get_blockchain_info
      call(JsonRpc::Response(Models::BlockchainInfo), "getblockchaininfo")
    end

    # Returns the number of blocks in the longest blockchain.
    def get_block_count
      call(JsonRpc::Response(Int32), "getblockcount")
    end

    # Returns hash of block in best-block-chain at height provided.
    def get_block_hash(index : Int32)
      call(JsonRpc::Response(String), "getblockhash", [index])
    end

    # If verbose is true, returns an Object with information about blockheader <hash>.
    def get_block_header(hash : String)
      header = call(JsonRpc::Response(Models::BlockHeader), "getblockheader", [hash])
    end

    def get_block_template(params = {} of String => JSON::Any)
      call(JsonRpc::Response(Models::BlockTemplate), "getblocktemplate", [params])
    end

    def get_connection_count
      call(JsonRpc::Response(Int32), "getconnectioncount")
    end

    def get_chain_tips
      call(JsonRpc::Response(Array(Models::ChainTip)), "getchaintips")
    end

    def get_difficulty
      call(JsonRpc::Response(Float64), "getdifficulty")
    end

    # Deprecated
    def get_info
      raise "get_info is deprecated. Use get_blockchain_info or get_wallet_info instead."
    end

    def get_mining_info(extended = true)
      call(JsonRpc::Response(JSON::Any), "getmininginfo")
    end

    def get_new_address(account = nil)
      call(JsonRpc::Response(String), "getnewaddress", account ? [account] : nil)
    end

    def get_raw_mem_pool
      call(JsonRpc::Response(Array(String)), "getrawmempool")
    end

    def get_raw_transaction(txid : String)
      call(JsonRpc::Response(String), "getrawtransaction", [txid, 0])
    end

    def get_received_by_account(account : String, minconf = 1)
      call(JsonRpc::Response(Float64), "getreceivedbyaccount", [account, minconf])
    end

    def get_received_by_address(address : String, minconf = 1)
      call(JsonRpc::Response(Float64), "getreceivedbyaddress", [address, minconf])
    end

    def get_transaction(txid : String)
      call(JsonRpc::Response(Models::RawTransaction), "getrawtransaction", [txid, 1])
    end

    def get_unconfirmed_balance
      call(JsonRpc::Response(Float64), "getunconfirmedbalance")
    end

    def get_wallet_info
      info = call(JsonRpc::Response(JSON::Any), "getwalletinfo")
      Models::WalletInfo.from_json(info.to_json)
    end

    def import_address(address : String, label = nil, rescan = true, p2sh = true)
      call(JsonRpc::EmptyResponse, "importaddress", [address, label, rescan, p2sh])
    end

    def import_multi(requests : String, options = nil)
      call(JsonRpc::EmptyResponse, "importmulti", [requests, options])
    end

    def import_private_key(key : String, label = nil, rescan = true)
      call(JsonRpc::EmptyResponse, "importprivkey", [key, label, rescan])
    end

    def import_pruned_funds
      call(JsonRpc::EmptyResponse, "importprunedfunds")
    end

    def import_public_key(key : String, label = nil, rescan = true)
      call(JsonRpc::EmptyResponse, "importpubkey", [key, label, rescan])
    end

    def import_wallet(filename : String)
      call(JsonRpc::EmptyResponse, "importwallet", [filename])
    end

    def key_pool_refill(newsize : Int32)
      call(JsonRpc::EmptyResponse, "keypoolrefill", [newsize])
    end

    def list_accounts(minconf = 1, include_watch_only = false)
      call(JsonRpc::Response(Array(String)), "list_accounts", [minconf, include_watch_only])
    end

    def list_address_groupings
      call(JsonRpc::Response(Array(String)), "listaddressgroupings")
    end

    def list_lock_unspent
      call(JsonRpc::Response(Array(String)), "listlockunspent")
    end

    def list_received_by_account(minconf = 1, empty = true, include_watch_only = false)
      call(JsonRpc::Response(
            Array(
              NamedTuple(
                account: String,
                amount: Float64,
                confirmations: Int32
              )
            )
          ), "listreceivedbyaccount", [minconf, empty, include_watch_only])
    end

    def list_received_by_address(minconf = 1, empty = true, include_watch_only = false)
      call(JsonRpc::Response(
          Array(
            NamedTuple(
              account: String,
              amount: Float64,
              confirmations: Int32
            )
          )
        ), "listreceivedbyaddress", [minconf, empty, include_watch_only])
    end

    def list_since_block(blockhash : String, confirmations = 1, include_watch_only = false, include_removed = true)
      call(JsonRpc::Response(
        NamedTuple(
          transactions: Array(String),
          removed: Array(String),
          lastblock: String
        )
      ), "listsinceblock", [blockhash, confirmations, include_watch_only, include_removed])
    end

    def list_transactions(account : String, count = 10, skip = 0, include_watch_only = false)
      call(JsonRpc::Response(Array(Models::Transaction)), "listtransactions", [account, count, skip, include_watch_only])
    end

    def list_unspent(addresses : Array(String), minconf = 1, maxconf = 9999999, include_unsafe = true, query_options = nil)
      call(JsonRpc::Response(Array(Models::Unspent)), "listunspent", [minconf, maxconf, addresses, include_unsafe, query_options])
    end

    def list_wallets
      call(JsonRpc::Response(Array(String)), "listwallets")
    end

    def lock_unspent(transactions = "")
      call(JsonRpc::Response(Bool), "lockunspent", [false, transactions])
    end

    def unlock_unspent(transactions = "")
      call(JsonRpc::Response(Bool), "lockunspent", [true, transactions])
    end

    def move(from_account, to_account, amount, minconf = 1, comment = "")
      call(JsonRpc::Response(Bool), "move", [from_account, to_account, amount, minconf, comment])
    end

    def remove_pruned_funds(txid : String)
      call(JsonRpc::EmptyResponse, "removeprunedfunds", [txid])
    end

    def send_from(from_account, to_address, amount, minconf = 1, comment = "", comment_to = "")
      call(JsonRpc::Response(String), "sendfrom", [from_account, to_address, amount, minconf, comment, comment_to])
    end

    def send_many(from_account, addresses : Hash(String, String), minconf = 1, comment = "", comment_to = "")
      call(JsonRpc::Response(String), "sendfrom", [from_account, addresses, minconf, comment, comment_to])
    end

    def send_to_address(address, amount, comment = "", comment_to = "", subtract_fee_from_amount = false, replacable = false, conf_target = 1, estimate_mode = "")
      call(JsonRpc::Response(String), "sendfrom", [address, amount, comment, comment_to, subtract_fee_from_amount, replacable, conf_target, estimate_mode])
    end

    def set_account(address, account)
      call(JsonRpc::Response(Bool), "setaccount", [address, account])
    end

    def set_transaction_fee(amount)
      call(JsonRpc::Response(Bool), "settxfee", [amount])
    end

    def sign_message(address, message)
      call(JsonRpc::Response(Bool), "signmessage", [address, message])
    end

    def help(command = "")
      call(JsonRpc::Response(String), "help", [command])
    end
  end

end
