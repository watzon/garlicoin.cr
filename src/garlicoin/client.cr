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

    # If the request parameters include a 'mode' key, that is used to explicitly select between the default 'template' request or a 'proposal'.
    # It returns data needed to construct a block to work on.
    # For full specification, see BIPs 22, 23, 9, and 145:
    #     https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki
    #     https://github.com/bitcoin/bips/blob/master/bip-0023.mediawiki
    #     https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki#getblocktemplate_changes
    #     https://github.com/bitcoin/bips/blob/master/bip-0145.mediawiki
    def get_block_template(params = {} of String => JSON::Any)
      call(JsonRpc::Response(Models::BlockTemplate), "getblocktemplate", [params])
    end

    # Returns the number of connections to other nodes.
    def get_connection_count
      call(JsonRpc::Response(Int32), "getconnectioncount")
    end

    # Return information about all known tips in the block tree, including the main chain as well as orphaned branches.
    def get_chain_tips
      call(JsonRpc::Response(Array(Models::ChainTip)), "getchaintips")
    end

    # Returns the proof-of-work difficulty as a multiple of the minimum difficulty.
    def get_difficulty
      call(JsonRpc::Response(Float64), "getdifficulty")
    end

    # Returns a json object containing mining-related information.
    def get_mining_info(extended = true)
      call(JsonRpc::Response(Model::MiningInfo), "getmininginfo")
    end

    # Returns a new Garlicoin address for receiving payments.
    # If 'account' is specified (DEPRECATED), it is added to the address book
    # so payments received with the address will be credited to 'account'.
    def get_new_address(account = nil)
      call(JsonRpc::Response(String), "getnewaddress", account ? [account] : nil)
    end

    # Returns all transaction ids in memory pool as a json array of string transaction ids.
    # Hint: use get_mempool_entry to fetch a specific transaction from the mempool.
    def get_raw_mem_pool
      call(JsonRpc::Response(Models::MemPool), "getrawmempool", [true])
    end

    # NOTE: By default this function only works for mempool transactions. If the -txindex option is
    # enabled, it also works for blockchain transactions.
    def get_raw_transaction(txid : String)
      call(JsonRpc::Response(String), "getrawtransaction", [txid, 0])
    end

    # DEPRECATED. Returns the total amount received by addresses with <account> in
    # transactions with at least [minconf] confirmations.
    def get_received_by_account(account : String, minconf = 1)
      call(JsonRpc::Response(Float64), "getreceivedbyaccount", [account, minconf])
    end

    # Returns the total amount received by the given address in transactions with at least
    # minconf confirmations.
    def get_received_by_address(address : String, minconf = 1)
      call(JsonRpc::Response(Float64), "getreceivedbyaddress", [address, minconf])
    end

    # Get detailed information about in-wallet transaction <txid>
    def get_transaction(txid : String)
      call(JsonRpc::Response(Models::RawTransaction), "getrawtransaction", [txid, 1])
    end

    # Returns the server's total unconfirmed balance
    def get_unconfirmed_balance
      call(JsonRpc::Response(Float64), "getunconfirmedbalance")
    end

    # Returns an object containing various wallet state info.
    def get_wallet_info
      info = call(JsonRpc::Response(JSON::Any), "getwalletinfo")
      Models::WalletInfo.from_json(info.to_json)
    end

    # Adds a script (in hex) or address that can be watched as if it were in your
    # wallet but cannot be used to spend.
    def import_address(address : String, label = nil, rescan = true, p2sh = true)
      call(JsonRpc::EmptyResponse, "importaddress", [address, label, rescan, p2sh])
    end

    # Import addresses/scripts (with private or public keys, redeem script (P2SH)),
    # rescanning all addresses in one-shot-only (rescan can be disabled via options).
    def import_multi(requests : String, options = nil)
      call(JsonRpc::EmptyResponse, "importmulti", [requests, options])
    end

    # Adds a private key (as returned by dumpprivkey) to your wallet.
    def import_private_key(key : String, label = nil, rescan = true)
      call(JsonRpc::EmptyResponse, "importprivkey", [key, label, rescan])
    end

    # Imports funds without rescan. Corresponding address or script must previously be
    # included in wallet. Aimed towards pruned wallets. The end-user is responsible
    # to import additional transactions that subsequently spend the imported
    # outputs or rescan after the point in the blockchain the
    # transaction is included.
    def import_pruned_funds
      call(JsonRpc::EmptyResponse, "importprunedfunds")
    end

    # Adds a public key (in hex) that can be watched as if it were in your wallet
    # but cannot be used to spend.
    def import_public_key(key : String, label = nil, rescan = true)
      call(JsonRpc::EmptyResponse, "importpubkey", [key, label, rescan])
    end

    # Imports keys from a wallet dump file (see dump_wallet).
    def import_wallet(filename : String)
      call(JsonRpc::EmptyResponse, "importwallet", [filename])
    end

    # Fills the keypool.
    def key_pool_refill(newsize : Int32)
      call(JsonRpc::EmptyResponse, "keypoolrefill", [newsize])
    end

    # DEPRECATED. Returns Object that has account names as keys, account balances as values.
    def list_accounts(minconf = 1, include_watch_only = false)
      call(JsonRpc::Response(JSON::Any), "list_accounts", [minconf, include_watch_only])
    end

    # Lists groups of addresses which have had their common ownership
    # made public by common use as inputs or as the resulting change
    # in past transactions
    def list_address_groupings
      call(JsonRpc::Response(Array(Array(Array(String)))), "listaddressgroupings")
    end

    # Returns list of temporarily unspendable outputs.
    # See the lockunspent call to lock and unlock transactions for spending.
    def list_lock_unspent
      call(JsonRpc::Response(Array(String)), "listlockunspent")
    end

    # DEPRECATED. List balances by account.
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

    # List balances by receiving address.
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

    # Get all transactions in blocks since block [blockhash], or all transactions if omitted.
    # If "blockhash" is no longer a part of the main chain, transactions from the fork point onward are included.
    # Additionally, if include_removed is set, transactions affecting the wallet which were removed are returned in the "removed" array.
    def list_since_block(blockhash : String, confirmations = 1, include_watch_only = false, include_removed = true)
      call(JsonRpc::Response(
        NamedTuple(
          transactions: Array(String),
          removed: Array(String),
          lastblock: String
        )
      ), "listsinceblock", [blockhash, confirmations, include_watch_only, include_removed])
    end

    # Returns up to 'count' most recent transactions skipping the first 'from' transactions for account 'account'.
    def list_transactions(account : String, count = 10, skip = 0, include_watch_only = false)
      call(JsonRpc::Response(Array(Models::Transaction)), "listtransactions", [account, count, skip, include_watch_only])
    end

    # Returns array of unspent transaction outputs
    # with between minconf and maxconf (inclusive) confirmations.
    # Optionally filter to only include txouts paid to specified addresses.
    def list_unspent(addresses : Array(String), minconf = 1, maxconf = 9999999, include_unsafe = true, query_options = nil)
      call(JsonRpc::Response(Array(Models::Unspent)), "listunspent", [minconf, maxconf, addresses, include_unsafe, query_options])
    end

    # Returns a list of currently loaded wallets.
    # For full information on the wallet, use `get_wallet_info`
    def list_wallets
      call(JsonRpc::Response(Array(String)), "listwallets")
    end

    # Temporarily lock specified transaction outputs.
    def lock_unspent(transactions = "")
      call(JsonRpc::Response(Bool), "lockunspent", [false, transactions])
    end

    # Unlock specified transaction outputs.
    # If no transaction outputs are specified when unlocking then all current locked transaction outputs are unlocked.
    def unlock_unspent(transactions = "")
      call(JsonRpc::Response(Bool), "lockunspent", [true, transactions])
    end

    # DEPRECATED. Move a specified amount from one account in your wallet to another.
    def move(from_account, to_account, amount, minconf = 1, comment = "")
      call(JsonRpc::Response(Bool), "move", [from_account, to_account, amount, minconf, comment])
    end

    # Deletes the specified transaction from the wallet. Meant for use with pruned wallets and as a companion
    # to importprunedfunds. This will affect wallet balances.
    def remove_pruned_funds(txid : String)
      call(JsonRpc::EmptyResponse, "removeprunedfunds", [txid])
    end

    # DEPRECATED (use send_to_address). Sent an amount from an account to a garlicoin address.
    def send_from(from_account, to_address, amount, minconf = 1, comment = "", comment_to = "")
      call(JsonRpc::Response(String), "sendfrom", [from_account, to_address, amount, minconf, comment, comment_to])
    end

    # Send multiple times. Amounts are double-precision floating point numbers.
    def send_many(from_account, addresses : Hash(String, String), minconf = 1, comment = "", comment_to = "")
      call(JsonRpc::Response(String), "sendfrom", [from_account, addresses, minconf, comment, comment_to])
    end

    # Send an amount to a given address.
    def send_to_address(address, amount, comment = "", comment_to = "", subtract_fee_from_amount = false, replacable = false, conf_target = 1, estimate_mode = "")
      call(JsonRpc::Response(String), "sendfrom", [address, amount, comment, comment_to, subtract_fee_from_amount, replacable, conf_target, estimate_mode])
    end

    # DEPRECATED. Sets the account associated with the given address.
    def set_account(address, account)
      call(JsonRpc::Response(Bool), "setaccount", [address, account])
    end

    # Set the transaction fee per kB. Overwrites the paytxfee parameter.
    def set_transaction_fee(amount)
      call(JsonRpc::Response(Bool), "settxfee", [amount])
    end

    # Sign a message with the private key of an address.
    def sign_message(address, message)
      call(JsonRpc::Response(Bool), "signmessage", [address, message])
    end

    # List all json-rpc commands, or get help for a specified command.
    def help(command = "")
      call(JsonRpc::Response(String), "help", [command])
    end
  end

end
