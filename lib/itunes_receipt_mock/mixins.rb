##
# ItunesReceiptMock
module ItunesReceiptMock
  ##
  # ItunesReceiptMock::Mixins
  module Mixins
    private

    def date_attrs(prefix, date)
      {
        "#{prefix}_date" => date.utc.strftime('%F %T') + ' Etc/GMT',
        "#{prefix}_date_ms" => date.utc.strftime('%s%L').to_i,
        "#{prefix}_date_pst" => date.getlocal('-08:00').strftime('%F %T') +
          ' America/Los_Angeles'
      }
    end
  end
end
