module ItunesReceiptMock
  class Base
    include ItunesReceiptMock::Mixins

    STATUS_CODES = [0, 21_000] + (21_002..21_008).to_a

    attr_reader :receipt

    def initialize(options={})
      @receipt = Receipt.new(options)
    end

    def result(options={})
      status = options[:status] || 0
      if status == 0
        {
          'status' => status,
          'environment' => receipt.environment,
          'receipt' => receipt.result(options),
          'latest_receipt_info' => [],
          'latest_receipt' => ''
        }
      else
        {
          'status' => status
        }
      end
    end
  end
end
