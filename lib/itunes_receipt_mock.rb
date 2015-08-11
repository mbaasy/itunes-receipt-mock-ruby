require 'active_support/all'
require 'itunes_receipt_mock/mixins'
require 'itunes_receipt_mock/base'
require 'itunes_receipt_mock/receipt'
require 'itunes_receipt_mock/purchase'
require 'itunes_receipt_mock/subscription'

module ItunesReceiptMock
  class MissingArgumentError < StandardError; end

  def self.new(options={})
    Base.new(options)
  end
end
