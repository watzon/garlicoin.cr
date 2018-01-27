require "json"
require "json_rpc"
require "http/client"

module Garlicoin

  class Client < JsonRpc::HttpClient

    def initialize(host : String, port : Int32, user : String, password : String)
      # Set up the HTTP client
      http_client = HTTP::Client.new(host, port)
      http_client.basic_auth(user, password)

      # Turn it into a JSON-RPC client
      super http_client
    end

    def self.new(config : Config)
      host = config.get("rpcallowip").split('/')[0]
      port = config.get("rpcport").to_i
      user = config.get("rpcuser")
      password = config.get("rpcpassword")
      new(host, port, user, password)
    end

    def abandon_transaction(id : String)
      call(JsonRpc::Response(String), "abandontransaction", [id])
    end

    def abort_rescan
      call(JsonRpc::EmptyResponse, "abortrescan")
    end

    def add_multi_sig_address(nrequired : String, keys : Array(String), account : String? = nil)
      call(JsonRpc::Response(Bool), "addmultisigaddress", [nrequired, key_arr, account])
    end

    def add_witness_address(address : String)
      call(JsonRpc::Response(Bool), "addwitnessaddress", [address])
    end

    def backup_wallet(destination : String)
      call(JsonRpc::EmptyResponse, "backupwallet", [destination])
    end

    def bump_fee(txid : String, options = nil)
      call(JsonRpc::EmptyResponse, "bumpfee", [txid, options])
    end

    def dump_private_key(address : String)
      call(JsonRpc::EmptyResponse, "dumpprivkey", [address])
    end

    def dump_wallet(filename : String)
      call(JsonRpc::EmptyResponse, "dumpwallet", [filename])
    end

    def encrypt_wallet(passphrase : String)
      call(JsonRpc::EmptyResponse, "encryptwallet", [passphrase])
    end

    def get_account(address : String)
      call(JsonRpc::Response(String), "getaccount", [address])
    end

    def get_account_address(account : String)
      call(JsonRpc::Response(String), "getaccountaddress", [account])
    end

    def get_addresses_by_account(account : String)
      call(JsonRpc::Response(Array(String)), "getaddressesbyaccount", [account])
    end

    def get_balance(account = "", minconf = 1, include_watch_only = false)
      call(JsonRpc::Response(Float64), "getbalance", [account, minconf, include_watch_only])
    end

    def get_best_block_hash
      call(JsonRpc::Response(String), "getbestblockhash")
    end

    def get_block(hash : String)
      call(JsonRpc::Response(Models::Block), "getblock", [hash])
    end

    def get_blockchain_info
      call(JsonRpc::Response(Models::BlockchainInfo), "getblockchaininfo")
    end

    def get_block_count
      call(JsonRpc::Response(Int32), "getblockcount")
    end

    def get_block_hash(index : Int32)
      call(JsonRpc::Response(String), "getblockhash", [index])
    end

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
