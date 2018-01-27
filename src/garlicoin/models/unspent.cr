require "json"

module Garlicoin::Models
  class Unspent

    JSON.mapping(
      txid: String,
      vout: Int32,
      address: String,
      account: String,
      scriptPubKey: String,
      amount: Float64,
      confirmations: Float64,
      spendable: Bool,
      solvable: Bool,
      safe: Bool
    )

  end
end
