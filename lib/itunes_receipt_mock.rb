require 'base64'
require 'itunes_receipt_mock/mixins'
require 'itunes_receipt_mock/validation'
require 'itunes_receipt_mock/receipt'
require 'itunes_receipt_mock/purchase'
require 'itunes_receipt_mock/subscription'

##
# ItunesReceiptMock
module ItunesReceiptMock
  class MissingArgumentError < StandardError; end

  @transaction_id = 1_000_000_000
  @web_order_line_item_id = 1_000_000_000
  ##
  # Creates a new iTunes receipt
  #
  # Returns: rdoc-ref:ItunesReceiptMock::Validation
  #
  # Params:
  # +options+:: rdoc-ref:ItunesReceiptMock
  def self.new(options = {})
    Validation.new(options)
  end

  def self.next_transaction_id
    @transaction_id += 1
  end

  def self.next_web_order_line_item_id
    @web_order_line_item_id += 1
  end
end
