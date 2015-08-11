##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Receipt
  class Receipt
    include ItunesReceiptMock::Mixins

    attr_reader :in_app
    attr_accessor :environment, :adam_id, :app_item_id, :bundle_id,
                  :application_version, :download_id,
                  :version_external_identifier, :original_purchase_date,
                  :original_application_version

    def initialize(options = {})
      @in_app = {}
      @bundle_id = options.fetch :bundle_id, nil
      @environment = options.fetch :environment, 'Production'
      @adam_id = options.fetch :adam_id, 0
      @app_item_id = options.fetch :app_item_id, 0
      @application_version = options.fetch :application_version, '1'
      @download_id = options.fetch :download_id, 0
      @version_external_identifier =
        options.fetch :version_external_identifier, 0
      @original_purchase_date = options.fetch :original_purchase_date, Time.now
      @original_application_version =
        options.fetch :original_application_version, 0

      fail MissingArgumentError, 'bundle_id is required' unless @bundle_id
    end

    def result(options = {})
      request_date = options[:request_date] = Time.now
      {
        'receipt_type' => environment,
        'adam_id' => adam_id,
        'app_item_id' => app_item_id,
        'bundle_id' => bundle_id,
        'application_version' => application_version,
        'download_id' => download_id,
        'version_external_identifier' => version_external_identifier,
        'original_application_version' => original_application_version,
        'in_app' => in_app_result(options)
      }
        .merge(date_attrs('request', request_date))
        .merge(date_attrs('original_purchase', original_purchase_date))
    end

    def add_purchase(options = {})
      purchase = Purchase.new(options)
      @in_app[purchase.transaction_id] = purchase
      purchase
    end

    def add_subscription(options = {})
      purchase = Subscription.new(options)
      @in_app[purchase.transaction_id] = purchase
      purchase
    end

    private

    def in_app_result(options)
      in_app.map { |_, v| v.result(options) }
    end
  end
end
