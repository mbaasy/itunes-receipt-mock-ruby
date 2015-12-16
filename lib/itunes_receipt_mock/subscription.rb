##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Subscription
  class Subscription < Purchase
    SUBSCRIPTION_DEFAULTS = {
      expires_date: nil,
      web_order_line_item_id: proc do
        receipt.transactions.next_web_order_line_item_id
      end
    }

    attr_accessor :expires_date, :web_order_line_item_id

    def initialize(options)
      super
      send_defaults(SUBSCRIPTION_DEFAULTS, options)
      fail MissingArgumentError, 'expires_date is required' unless @expires_date
    end

    def renew(options)
      attrs = {
        receipt: receipt,
        in_app: false,
        quantity: quantity,
        product_id: product_id,
        original_transaction_id: transaction_id,
        original_purchase_date: purchase_date,
        is_trial_period: is_trial_period
      }.merge(options)
      receipt.transactions.create attrs
    end

    def as_json
      super.merge(
        'web_order_line_item_id' => web_order_line_item_id.to_s
      ).merge(expires_date_attrs(expires_date))
    end
  end
end
