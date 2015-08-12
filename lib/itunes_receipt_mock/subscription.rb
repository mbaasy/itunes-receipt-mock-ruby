##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Subscription
  class Subscription < Purchase
    SUBSCRIPTION_DEFAULTS = {
      expires_date: nil,
      web_order_line_item_id: proc do
        ItunesReceiptMock.next_web_order_line_item_id
      end,
      is_trial_period: false
    }

    attr_accessor :expires_date, :web_order_line_item_id, :is_trial_period

    def initialize(options = {})
      super
      send_defaults(SUBSCRIPTION_DEFAULTS, options)
      fail MissingArgumentError, 'expires_date is required' unless @expires_date
    end

    def result(_options = {})
      super.merge(
        'web_order_line_item_id' => web_order_line_item_id.to_s,
        'is_trial_period' => is_trial_period
      ).merge(date_attrs('expires', expires_date))
    end
  end
end
