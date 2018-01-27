require "json"

module Garlicoin::Models
  class BlockchainInfo

    JSON.mapping(
      chain: String,
      blocks: Int32,
      headers: Int32,
      bestblockhash: String,
      difficulty: Float32,
      mediantime: Int32,
      verificationprogress: Int32,
      chainwork: String,
      pruned: Bool,
      softforks: Array(SoftFork),
      bip9_softforks: NamedTuple(csv: Bip9SoftFork, segwit: Bip9SoftFork)
    )

  end

  class SoftFork

    JSON.mapping(
      id: String,
      version: Int32,
      reject: NamedTuple(status: Bool)
    )

  end

  class Bip9SoftFork

    JSON.mapping(
      status: String,
      bit: Int32,
      startTime: Int32,
      timeout: Int32,
      since: Int32,
      statistics: NamedTuple(
        period: Int32,
        threshold: Int32,
        elapsed: Int32,
        count: Int32,
        possible: Bool
      )
    )

  end
end
