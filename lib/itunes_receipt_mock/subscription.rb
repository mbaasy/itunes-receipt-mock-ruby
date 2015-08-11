module ItunesReceiptMock
  class Subscription < Purchase
    attr_reader :expires_date, :weborder_line_item, :is_trial_period

    def initialize(options={})
      super
      @expires_date = options[:expires_date]
      @weborder_line_item = options[:weborder_line_item] || rand(1_000_000_000..9_999_999_999).to_s
      @is_trial_period = options[:is_trial_period] || false

      fail MissingArgumentError, 'expires_date is required' unless @expires_date
    end
  end
end
