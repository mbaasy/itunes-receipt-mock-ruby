##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Subscription
  class Subscription < Purchase
    attr_accessor :expires_date, :web_order_line_item_id, :is_trial_period

    def initialize(options = {})
      super
      @expires_date = options.fetch :expires_date, nil
      @web_order_line_item_id =
        options.fetch :web_order_line_item_id,
                      rand(1_000_000_000..9_999_999_999).to_s
      @is_trial_period = options.fetch :is_trial_period, false

      fail MissingArgumentError, 'expires_date is required' unless @expires_date
    end

    def result(_options = {})
      super.merge(
        'web_order_line_item_id' => web_order_line_item_id,
        'is_trial_period' => is_trial_period
      ).merge(date_attrs('expires_date', expires_date))
    end
  end
end
