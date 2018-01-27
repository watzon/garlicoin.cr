require "json"

module Garlicoin::Models
  class RawTransaction

    JSON.mapping(
      txid: String,
      hash: String,
      version: Int32,
      size: Int32,
      vsize: Int32,
      locktime: Int32,
      vin: Array(Vin),
      vout: Array(Vout),
      hex: String,
      blockhash: String?,
      confirmations: Int32?,
      time: Int32?,
      blocktime: Int32?
    )

    class Vin

      JSON.mapping(
        coinbase: String,
        sequence: Int32
      )

    end

    class Vout

      JSON.mapping(
        value: Float64,
        n: Int32,
        scriptPubKey: ScriptPubKey
      )

    end

    class ScriptPubKey

      JSON.mapping(
        asm: String,
        hex: String,
        type: String,
        reqSigs: Int32?,
        addresses: Array(String)?
      )

    end
  end
end
