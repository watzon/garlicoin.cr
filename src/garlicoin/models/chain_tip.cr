require "json"

module Garlicoin::Models
  class ChainTip

    JSON.mapping(
      height: Int32,
      hash: String,
      branchlen: Int32,
      status: String
    )

  end
end
