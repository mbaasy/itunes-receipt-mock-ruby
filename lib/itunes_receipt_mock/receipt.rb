##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Receipt
  class Receipt
    include ItunesReceiptMock::Mixins

    STATUS_CODES = [0, 21_000] + (21_002..21_008).to_a
    DEFAULTS = {
      status: 0,
      request_date: proc { Time.now },
      environment: 'Production',
      bundle_id: nil,
      adam_id: 1,
      app_item_id: 1,
      application_version: 1,
      download_id: 1,
      version_external_identifier: 1,
      original_purchase_date: proc { Time.now },
      original_application_version: 1
    }

    attr_reader :transactions
    attr_accessor :status, :environment, :request_date, :adam_id, :app_item_id,
                  :bundle_id, :application_version, :download_id,
                  :version_external_identifier, :original_purchase_date,
                  :original_application_version

    def initialize(options = {})
      send_defaults(DEFAULTS, options)
      @transactions = TransactionProxy.new(self)
      fail MissingArgumentError, 'bundle_id is required' unless @bundle_id
    end

    def as_json
      result = { 'status' => status }
      if status == 0
        result.merge!(
          'status' => status,
          'environment' => environment,
          'receipt' => inner_json,
          'latest_receipt_info' => transactions.latest_receipt_info
        )
        result.merge!(
          'latest_receipt' => Base64.strict_encode64(
            JSON.generate(result.as_json)
          )
        )
      end
      result
    end

    def to_json
      JSON.generate(as_json)
    end

    private

    def inner_json
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
        'in_app' => transactions.in_app
      }
        .merge(date_attrs('request', request_date))
        .merge(date_attrs('original_purchase', original_purchase_date))
    end
  end
end
