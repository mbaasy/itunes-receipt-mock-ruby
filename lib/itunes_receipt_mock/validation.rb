##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Validation
  class Validation
    include ItunesReceiptMock::Mixins

    STATUS_CODES = [0, 21_000] + (21_002..21_008).to_a

    attr_reader :receipt, :latest_receipt_info

    def initialize(options = {})
      @latest_receipt_info = {}
      @receipt = Receipt.new(options)
    end

    def result(options = {})
      status = options.fetch(:status, 0)
      result = { 'status' => status }
      if status == 0
        result.merge!(
          'status' => status,
          'environment' => receipt.environment,
          'receipt' => receipt.result(options),
          'latest_receipt_info' => latest_receipt_info_result(options)
        )
        result.merge!(
          'latest_receipt' => Base64.strict_encode64(result.to_json)
        )
      end
      result
    end

    def add_purchase(options = {})
      purchase = receipt.add_purchase(options)
      @latest_receipt_info[purchase.transaction_id] = purchase
      purchase
    end

    def add_subscription(options = {})
      purchase = receipt.add_subscription(options)
      @latest_receipt_info[purchase.transaction_id] = purchase
      purchase
    end

    def renew_subscription(purchase, options = {})
      expires_date = options.fetch(:expires_date, nil)
      fail MissingArgumentError, 'expires_date is required' unless expires_date

      attrs = {
        quantity: purchase.quantity,
        product_id: purchase.product_id,
        original_transaction_id: purchase.original_transaction_id,
        original_purchase_date: purchase.original_purchase_date,
        weborder_line_item: purchase.weborder_line_item,
        is_trial_period: purchase.is_trial_period
      }.merge(expires_date: expires_date).merge(options)

      receipt.in_app.delete(purchase.original_transaction_id)
      add_subscription(attrs)
    end

    private

    def latest_receipt_info_result(options)
      latest_receipt_info.map { |_, v| v.result(options) }
    end
  end
end
