require "json"

module Garlicoin::Models
  class BlockTemplate

    JSON.mapping(
      capabilities: Array(String),
      version: Int32,
      rules: Array(String),
      vbavailable: NamedTuple(csv: Int32, segwit: Int32),
      vbrequired: Int32,
      previousblockhash: String,
      transactions: Array(Transaction),
      coinbaseaux: NamedTuple(flags: String),
      coinbasevalue: Int32,
      longpollid: String,
      target: String,
      mintime: { type: Time, converter: Time::EpochConverter },
      mutable: Array(String),
      noncerange: String,
      sigoplimit: Int32,
      sizelimit: Int32,
      curtime: Int32,
      bits: String,
      height: Int32
    )

    class Transaction

      JSON.mapping(
        data: String,
        txid: String,
        hash: String,
        depends: Array(String),
        fee: Int32,
        sigops: Int32,
        weight: Int32
      )

    end
  end
end
