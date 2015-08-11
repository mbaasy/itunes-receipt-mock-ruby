module ItunesReceiptMock
  class Purchase
    include ItunesReceiptMock::Mixins

    attr_reader :quantity, :product_id, :transaction_id,
                :original_transaction_id, :purchase_date,
                :original_purchase_date

    def initialize(options={})
      @product_id = options[:product_id]
      @quantity = options[:quantity] || 1
      @transaction_id = options[:transaction_id] || rand(1_000_000_000..9_999_999_999).to_s
      @original_transaction_id = options[:original_transaction_id] || @transaction_id
      @purchase_date = options[:purchase_date] || Time.now
      @original_purchase_date = options[:original_purchase_date] || @purchase_date

      fail ItunesReceiptMock::MissingArgumentError, 'product_id is required' unless @product_id
    end

    def result
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
