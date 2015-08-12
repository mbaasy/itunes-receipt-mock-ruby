##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Purchase
  class Purchase
    include ItunesReceiptMock::Mixins

    PURCHASE_DEFAULTS = {
      product_id: nil,
      quantity: 1,
      transaction_id: proc { ItunesReceiptMock.next_transaction_id },
      original_transaction_id: proc { transaction_id },
      purchase_date: proc { Time.now },
      original_purchase_date: proc { purchase_date }
    }

    attr_accessor :quantity, :product_id, :transaction_id,
                  :original_transaction_id, :purchase_date,
                  :original_purchase_date

    def initialize(options = {})
      send_defaults(PURCHASE_DEFAULTS, options)
      fail ItunesReceiptMock::MissingArgumentError,
           'product_id is required' unless @product_id
    end

    def result(_options = {})
      {
        'quantity' => quantity,
        'product_id' => product_id,
        'transaction_id' => transaction_id,
        'original_transaction_id' => original_transaction_id
      }
        .merge(date_attrs('purchase', purchase_date))
        .merge(date_attrs('original_purchase', original_purchase_date))
    end
  end
end
