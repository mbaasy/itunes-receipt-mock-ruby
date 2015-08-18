require 'json'
require 'base64'
require 'itunes_receipt_mock/mixins'
require 'itunes_receipt_mock/transaction_proxy'
require 'itunes_receipt_mock/receipt'
require 'itunes_receipt_mock/purchase'
require 'itunes_receipt_mock/subscription'

##
# ItunesReceiptMock
module ItunesReceiptMock
  class MissingArgumentError < StandardError; end

  def self.new(options = {})
    Receipt.new(options)
  end
end
