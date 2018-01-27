require "json"

module Garlicoin::Models
  class Transaction

    JSON.mapping(
      account: String,
      address: String,
      category: String,
      amount: Float64,
      label: String,
      vout: Int32,
      confirmations: Int32,
      blockhash: String,
      blockindex: Int32,
      blocktime: { type: Time, converter: Time::EpochConverter },
      txid: String,
      walletconflicts: Array(String),
      time: { type: Time, converter: Time::EpochConverter },
      timereceived: { type: Time, converter: Time::EpochConverter },
      bip125_replaceable: { type: String, key: "bip125-replaceable" }
    )

  end
end
