##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Receipt
  class Receipt
    include ItunesReceiptMock::Mixins

    RECEIPT_DEFAULTS = {
      bundle_id: nil,
      environment: 'Production',
      adam_id: 1,
      app_item_id: 1,
      application_version: 1,
      download_id: 1,
      version_external_identifier: 1,
      original_purchase_date: proc { Time.now },
      original_application_version: 1
    }

    attr_reader :in_app
    attr_accessor :environment, :adam_id, :app_item_id, :bundle_id,
                  :application_version, :download_id,
                  :version_external_identifier, :original_purchase_date,
                  :original_application_version

    def initialize(options = {})
      @in_app = {}
      send_defaults(RECEIPT_DEFAULTS, options)
      fail MissingArgumentError, 'bundle_id is required' unless @bundle_id
    end

    def result(options = {})
      request_date = options.fetch :request_date, Time.now
      {
        'receipt_type' => environment,
        'adam_id' => adam_id.to_i,
        'app_item_id' => app_item_id.to_i,
        'bundle_id' => bundle_id,
        'application_version' => application_version.to_s,
        'download_id' => download_id.to_i,
        'version_external_identifier' => version_external_identifier.to_i,
        'original_application_version' =>
          format('%.1f', original_application_version),
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
