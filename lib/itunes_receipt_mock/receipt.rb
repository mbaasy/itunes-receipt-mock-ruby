module ItunesReceiptMock
  class Receipt
    include ItunesReceiptMock::Mixins

    attr_reader :environment, :adam_id, :app_item_id, :bundle_id,
                :application_version, :download_id,
                :version_external_identifier, :original_purchase_date,
                :original_application_version,
                :purchases

    def initialize(options={})
      @purchases = []
      @environment = options[:environment] || 'Production'
      @adam_id = options[:adam_id] || 0
      @app_item_id = options[:app_item_id] || 0
      @bundle_id = options[:bundle_id]
      @application_version = options[:application_version] || '1'
      @download_id = options[:download_id] || 0
      @version_external_identifier = options[:version_external_identifier] || 0
      @original_purchase_date = options[:original_purchase_date] || Time.now
      @original_application_version = options[:original_application_version] || 0

      fail MissingArgumentError, 'bundle_id is required' unless @bundle_id
    end

    def result(options = {})
      request_date = options[:request_date] = Time.now
      {
        'receipt_type' => environment,
        'adam_id' => adam_id,
        'app_item_id' => app_item_id,
        'bundle_id' => bundle_id,
        'application_version'=> application_version,
        'download_id' => download_id,
        'version_external_identifier' => version_external_identifier,
        'original_application_version' => original_application_version,
        'in_app' => purchases.map { |purchase| purchase.result }
      }
        .merge(date_attrs('request', request_date))
        .merge(date_attrs('original_purchase', original_purchase_date))
    end

    def add_purchase(options={})
      purchase = Purchase.new(options)
      @purchases << purchase
      purchase
    end

    def add_subscription(options={})
      purchase = Subscription.new(options)
      @purchases << purchase
      purchase
    end
  end
end
