require 'spec_helper'

describe ItunesReceiptMock do
  describe '.new' do
    subject { described_class.new(options) }

    context 'with minimal options' do
      let(:options) { { bundle_id: 'foobar' } }

      it 'creates an instance of Validation' do
        expect(subject).to be_a(described_class::Validation)
      end
    end

    context 'when bundle_id is not present' do
      let(:options) { {} }

      it 'raises an MissingArgumentError' do
        expect { subject }.to raise_error(
          described_class::MissingArgumentError,
          'bundle_id is required'
        )
      end
    end
  end

  describe 'full integration' do
    let(:validation) { described_class.new(bundle_id: 'com.example') }
    let!(:purchase) { validation.add_purchase(product_id: 'foobar') }
    let!(:subscription) do
      validation.add_subscription product_id: 'premium',
                                  purchase_date: 1.month.ago,
                                  expires_date: Time.now
    end
    let(:in_app_purchase_json) do
      subject['receipt']['in_app'].detect do |t|
        t['transaction_id'] == purchase.transaction_id
      end
    end
    let(:latest_receipt_info_purchase_json) do
      subject['latest_receipt_info'].detect do |t|
        t['transaction_id'] == purchase.transaction_id
      end
    end
    let(:in_app_subscription_json) do
      subject['receipt']['in_app'].detect do |t|
        t['transaction_id'] == subscription.transaction_id
      end
    end
    let(:latest_receipt_info_subscription_json) do
      subject['latest_receipt_info'].detect do |t|
        t['transaction_id'] == subscription.transaction_id
      end
    end

    subject { validation.result }

    shared_examples 'a date' do
      it 'displays the date in GMT' do
        expect(json[prefix + '_date'])
          .to eq(date.utc.strftime('%F %T') + ' Etc/GMT')
      end

      it 'displays the date as a ms timestamp' do
        expect(json[prefix + '_date_ms'])
          .to eq(date.utc.strftime('%s%L').to_i)
      end

      it 'displays the date in PST' do
        expect(json[prefix + '_date_pst'])
          .to eq(date.getlocal('-08:00').strftime('%F %T') +
                 ' America/Los_Angeles')
      end
    end

    shared_examples 'a purchase json object' do
      it 'contains all the details for a purchase' do
        expect(json['product_id']).to eq(obj.product_id)
        expect(json['quantity']).to eq(obj.quantity)
        expect(json['original_transaction_id'])
          .to eq(obj.original_transaction_id)
      end

      describe 'purchase date' do
        let(:date) { obj.purchase_date }
        let(:prefix) { 'purchase' }
        it_behaves_like 'a date'
      end

      describe 'original purchase date' do
        let(:date) { obj.original_purchase_date }
        let(:prefix) { 'original_purchase' }
        it_behaves_like 'a date'
      end
    end

    shared_examples 'a subscription json object' do
      it_behaves_like 'a purchase json object'

      it 'contains all the details for a subscription' do
        expect(json['web_order_line_item_id'])
          .to eq(obj.web_order_line_item_id.to_s)
        expect(json['is_trial_period']).to eq(obj.is_trial_period)
      end

      describe 'expires date' do
        let(:date) { obj.expires_date }
        let(:prefix) { 'expires' }
        it_behaves_like 'a date'
      end
    end

    it 'contains all the purchases in the receipt.in_app object' do
      expect(subject['receipt']['in_app'].length).to eq(2)
    end

    it 'contains all the purchases in the latest_receipt_info object' do
      expect(subject['latest_receipt_info'].length).to eq(2)
    end

    it_behaves_like 'a purchase json object' do
      let(:obj) { purchase }
      let(:json) { in_app_purchase_json }
    end

    it 'contains the same object for the purchase in latest_receipt_info' do
      expect(in_app_purchase_json).to eq(latest_receipt_info_purchase_json)
    end

    it_behaves_like 'a subscription json object' do
      let(:obj) { subscription }
      let(:json) { in_app_subscription_json }
    end

    it 'contains the same object for the subscription in latest_receipt_info' do
      expect(in_app_subscription_json)
        .to eq(latest_receipt_info_subscription_json)
    end

    context 'renewing the subscription' do
      let!(:renewal) do
        validation.renew_subscription subscription,
                                      expires_date: 1.month.from_now
      end

      it 'contains two subscription transactions in latest_receipt_info' do
        expect(subject['latest_receipt_info'].length).to eq(3)
      end
    end
  end
end
