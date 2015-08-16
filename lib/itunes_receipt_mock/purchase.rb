##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Purchase
  class Purchase
    include ItunesReceiptMock::Mixins

    PURCHASE_DEFAULTS = {
      receipt: nil,
      product_id: nil,
      quantity: 1,
      transaction_id: proc { receipt.transactions.next_transaction_id },
      original_transaction_id: proc { transaction_id },
      purchase_date: proc { Time.now },
      original_purchase_date: proc { purchase_date },
      is_trial_period: false,
      in_app: true
    }

    attr_accessor :quantity, :product_id, :transaction_id,
                  :original_transaction_id, :purchase_date,
                  :original_purchase_date, :is_trial_period,
                  :receipt, :in_app

    alias_method :in_app?, :in_app

    def initialize(options = {})
      send_defaults(PURCHASE_DEFAULTS, options)
      fail MissingArgumentError, 'product_id is required' unless @product_id
      fail MissingArgumentError, 'receipt is required' unless @receipt
    end

    def as_json
      {
        'quantity' => quantity.to_s,
        'product_id' => product_id,
        'transaction_id' => transaction_id.to_s,
        'original_transaction_id' => original_transaction_id.to_s,
        'is_trial_period' => is_trial_period.to_s
      }
        .merge(date_attrs('purchase', purchase_date))
        .merge(date_attrs('original_purchase', original_purchase_date))
    end
  end
end
