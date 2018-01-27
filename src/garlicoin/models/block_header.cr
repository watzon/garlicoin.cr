require "json"

module Garlicoin::Models
  class BlockHeader

    JSON.mapping(
      hash: String,
      confirmations: Int32,
      height: Int32,
      version: Int32,
      versionHex: String,
      merkleroot: String,
      time: { type: Time, converter: Time::EpochConverter },
      mediantime: { type: Time, converter: Time::EpochConverter },
      nonce: Int32,
      bits: String,
      difficulty: Float64,
      chainwork: String,
      previousblockhash: String,
      nextblockhash: String
    )

  end
end
