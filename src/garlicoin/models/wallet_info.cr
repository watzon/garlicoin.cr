require "json"

module Garlicoin::Models
  class WalletInfo

    JSON.mapping(
      walletname: String,
      walletversion: Int32,
      balance: Float64,
      unconfirmed_balance: Float64,
      immature_balance: Float64,
      txcount: Int32,
      keypoololdest: Int32,
      keypoolsize: Int32,
      keypoolsize_hd_internal: Int32,
      paytxfee: Float64,
      hdmasterkeyid: String
    )

  end
end
