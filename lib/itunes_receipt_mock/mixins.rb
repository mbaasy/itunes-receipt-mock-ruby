##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Mixins
  module Mixins
    private

    def send_defaults(defaults, options)
      defaults.each do |k, v|
        send "#{k}=", options.fetch(k, v.class == Proc ? instance_eval(&v) : v)
      end
    end

    def date_attrs(prefix, date)
      {
        "#{prefix}_date" => date.to_time.utc.strftime('%F %T') + ' Etc/GMT',
        "#{prefix}_date_ms" => date.to_time.utc.strftime('%s%L'),
        "#{prefix}_date_pst" => date.to_time.getlocal('-08:00')
          .strftime('%F %T') + ' America/Los_Angeles'
      }
    end

    def expires_date_attrs(date)
      {
        'expires_date' => date.to_time.utc.strftime('%s%L'),
        'expires_date_formatted' => date.to_time.utc
          .strftime('%F %T') + ' Etc/GMT',
        'expires_date_formatted_pst' => date.to_time.getlocal('-08:00')
          .strftime('%F %T') + ' America/Los_Angeles'
      }
    end
  end
end
