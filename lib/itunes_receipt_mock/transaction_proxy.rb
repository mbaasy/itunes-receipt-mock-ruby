##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::TransactionProxy
  class TransactionProxy < Array
    attr_accessor :receipt, :transaction_id, :web_order_line_item_id

    def initialize(receipt)
      @receipt = receipt
      @transaction_id = 1_000_000_000
      @web_order_line_item_id = 1_000_000_000
    end

    def create(options)
      klass = options[:expires_date].nil? ? Purchase : Subscription
      transaction = klass.new options.merge(receipt: @receipt)
      self << transaction
      transaction
    end

    def in_app
      select(&:in_app?).map(&:as_json)
    end

    def latest_receipt_info
      map(&:as_json)
    end

    def next_transaction_id
      @transaction_id += 1
    end

    def next_web_order_line_item_id
      @web_order_line_item_id += 1
    end
  end
end
