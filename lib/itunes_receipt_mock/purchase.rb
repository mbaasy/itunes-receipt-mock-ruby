##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Purchase
  class Purchase
    include ItunesReceiptMock::Mixins

    attr_accessor :quantity, :product_id, :transaction_id,
                  :original_transaction_id, :purchase_date,
                  :original_purchase_date

    def initialize(options = {})
      @product_id = options.fetch :product_id, nil
      fail ItunesReceiptMock::MissingArgumentError,
           'product_id is required' unless @product_id
      @quantity = options.fetch :quantity, 1
      @transaction_id =
        options.fetch :transaction_id,
                      ItunesReceiptMock.next_transaction_id.to_s
      @original_transaction_id =
        options.fetch :original_transaction_id, @transaction_id
      @purchase_date = options.fetch :purchase_date, Time.now
      @original_purchase_date =
        options.fetch :original_purchase_date, @purchase_date
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
