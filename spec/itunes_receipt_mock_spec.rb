require 'spec_helper'

describe ItunesReceiptMock do
  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  describe '.new' do
    subject { described_class.new(options) }

    let(:options) { { bundle_id: 'com.example' } }

    it 'initializes a Receipt' do
      expect(subject).to be_a(described_class::Receipt)
    end

    it 'sets the attributes' do
      expect(subject.status).to eq(0)
      expect(subject.request_date).to eq(Time.now)
      expect(subject.environment).to eq('Production')
      expect(subject.bundle_id).to eq('com.example')
      expect(subject.adam_id).to eq(1)
      expect(subject.app_item_id).to eq(1)
      expect(subject.application_version).to eq(1)
      expect(subject.download_id).to eq(1)
      expect(subject.version_external_identifier).to eq(1)
      expect(subject.original_purchase_date).to eq(Time.now)
      expect(subject.original_application_version).to eq(1)
    end

    it 'initializes the transactions' do
      expect(subject.transactions).to be_a(described_class::TransactionProxy)
    end

    context 'when options are populated' do
      let(:options) do
        {
          status: 21_000,
          request_date: 1.day.ago,
          environment: 'Sandbox',
          bundle_id: 'com.example2',
          adam_id: 2,
          app_item_id: 2,
          application_version: 2,
          download_id: 2,
          version_external_identifier: 2,
          original_purchase_date: 1.day.ago,
          original_application_version: 2
        }
      end

      it 'sets the attributes' do
        expect(subject.status).to eq(21_000)
        expect(subject.request_date).to eq(1.day.ago)
        expect(subject.environment).to eq('Sandbox')
        expect(subject.bundle_id).to eq('com.example2')
        expect(subject.adam_id).to eq(2)
        expect(subject.app_item_id).to eq(2)
        expect(subject.application_version).to eq(2)
        expect(subject.download_id).to eq(2)
        expect(subject.version_external_identifier).to eq(2)
        expect(subject.original_purchase_date).to eq(1.day.ago)
        expect(subject.original_application_version).to eq(2)
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

  describe '#receipt.transactions.create' do
    subject { receipt.transactions.create(options) }

    let(:receipt) { described_class.new(bundle_id: 'com.example') }

    shared_examples 'a Purchase' do
      it 'adds it to the transactions' do
        expect(receipt.transactions).to include(subject)
      end

      it 'increments the transaction_id' do
        expect(receipt.transactions.transaction_id).to eq(1_000_000_000)
        subject
        expect(receipt.transactions.transaction_id).to eq(1_000_000_001)
      end

      it 'sets the attributes' do
        expect(subject.product_id).to eq('foobar')
        expect(subject.quantity).to eq(1)
        expect(subject.transaction_id).to eq(1_000_000_001)
        expect(subject.original_transaction_id).to eq(subject.transaction_id)
        expect(subject.purchase_date).to eq(Time.now)
        expect(subject.original_purchase_date).to eq(subject.purchase_date)
        expect(subject.is_trial_period).to eq(false)
        expect(subject.in_app).to eq(true)
        expect(subject.receipt).to eq(receipt)
      end

      context 'when options are populated' do
        let(:options) do
          {
            product_id: 'whatever',
            quantity: 2,
            transaction_id: 999,
            original_transaction_id: 998,
            purchase_date: 1.day.ago,
            original_purchase_date: 2.days.ago,
            is_trial_period: true
          }
        end

        it 'sets the attributes' do
          expect(subject.product_id).to eq('whatever')
          expect(subject.quantity).to eq(2)
          expect(subject.transaction_id).to eq(999)
          expect(subject.original_transaction_id).to eq(998)
          expect(subject.purchase_date).to eq(1.day.ago)
          expect(subject.original_purchase_date).to eq(2.days.ago)
          expect(subject.is_trial_period).to eq(true)
        end
      end

      context 'when product_id is missing' do
        let(:options) { {} }

        it 'raises an MissingArgumentError' do
          expect { subject }.to raise_error(
            described_class::MissingArgumentError,
            'product_id is required'
          )
        end
      end
    end

    shared_examples 'a Subscription' do
      it_behaves_like 'a Purchase'

      it 'increments the web_order_line_item_id' do
        expect(receipt.transactions.web_order_line_item_id).to eq(1_000_000_000)
        subject
        expect(receipt.transactions.web_order_line_item_id).to eq(1_000_000_001)
      end

      it 'sets the attributes' do
        expect(subject.expires_date).to eq(1.month.from_now)
        expect(subject.web_order_line_item_id).to eq(1_000_000_001)
      end

      context 'when options are populated' do
        let(:options) do
          {
            product_id: 'whatever',
            expires_date: 7.days.from_now,
            web_order_line_item_id: 999
          }
        end

        it 'sets the attributes' do
          expect(subject.web_order_line_item_id).to eq(999)
        end
      end
    end

    context 'creating a purchase' do
      let(:options) do
        {
          product_id: 'foobar'
        }
      end

      it 'initializes a Purchase' do
        expect(subject).to be_a(described_class::Purchase)
      end

      it_behaves_like 'a Purchase'
    end

    context 'creating a subscription' do
      let(:options) do
        {
          product_id: 'foobar',
          expires_date: 1.month.from_now
        }
      end

      it 'initializes a Subscription' do
        expect(subject).to be_a(described_class::Subscription)
      end

      it_behaves_like 'a Subscription'
    end
  end

  describe 'subscription.renew' do
    subject { subscription.renew(options) }

    let(:receipt) { described_class.new(bundle_id: 'com.example') }
    let!(:subscription) do
      receipt.transactions.create(
        product_id: 'premium',
        purchase_date: 1.month.ago,
        expires_date: Time.now
      )
    end
    let(:options) do
      {
        expires_date: 1.month.from_now
      }
    end

    it 'initializes a Subscription' do
      expect(subject).to be_a(described_class::Subscription)
    end

    it 'adds the new subscription to transactions' do
      expect(receipt.transactions).to include(subject)
      expect(receipt.transactions).to include(subscription)
    end

    it 'assigns the attributes' do
      expect(subject.expires_date).to eq(1.month.from_now)
      expect(subject.in_app).to eq(false)
    end

    context 'when in_app is set to true' do
      let(:options) do
        {
          expires_date: 1.month.from_now,
          in_app: true
        }
      end

      it 'sets in_app to true' do
        expect(subject.in_app).to eq(true)
      end
    end
  end

  describe '#receipt.as_json' do
    subject { receipt.as_json }

    let(:receipt) { described_class.new(bundle_id: 'com.example') }
    let!(:purchase) do
      receipt.transactions.create(product_id: 'foobar')
    end
    let!(:subscription) do
      receipt.transactions.create(
        product_id: 'premium',
        purchase_date: 1.month.ago,
        expires_date: Time.now
      )
    end
    let(:in_app_purchase_json) do
      subject['receipt']['in_app'].detect do |t|
        t['transaction_id'].to_i == purchase.transaction_id
      end
    end
    let(:latest_receipt_info_purchase_json) do
      subject['latest_receipt_info'].detect do |t|
        t['transaction_id'].to_i == purchase.transaction_id
      end
    end
    let(:in_app_subscription_json) do
      subject['receipt']['in_app'].detect do |t|
        t['transaction_id'].to_i == subscription.transaction_id
      end
    end
    let(:latest_receipt_info_subscription_json) do
      subject['latest_receipt_info'].detect do |t|
        t['transaction_id'].to_i == subscription.transaction_id
      end
    end

    shared_examples 'a date' do
      it 'displays the date in GMT' do
        expect(json[prefix + '_date'])
          .to eq(date.utc.strftime('%F %T') + ' Etc/GMT')
      end

      it 'displays the date as a ms timestamp' do
        expect(json[prefix + '_date_ms'])
          .to eq(date.utc.strftime('%s%L'))
      end

      it 'displays the date in PST' do
        expect(json[prefix + '_date_pst'])
          .to eq(date.getlocal('-08:00').strftime('%F %T') +
                 ' America/Los_Angeles')
      end
    end

    shared_examples 'expires a date' do
      it 'displays the date as a ms timestamp' do
        expect(json['expires_date'])
          .to eq(date.utc.strftime('%s%L'))
      end

      it 'displays the date as a ms timestamp' do
        expect(json['expires_date_formatted'])
          .to eq(date.utc.strftime('%F %T') + ' Etc/GMT')
      end

      it 'displays the date in PST' do
        expect(json['expires_date_formatted_pst'])
          .to eq(date.getlocal('-08:00').strftime('%F %T') +
                 ' America/Los_Angeles')
      end
    end

    shared_examples 'a purchase json object' do
      it 'contains all the details for a purchase' do
        expect(json['product_id']).to eq(obj.product_id)
        expect(json['quantity']).to eq(obj.quantity.to_s)
        expect(json['original_transaction_id'])
          .to eq(obj.original_transaction_id.to_s)
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
        expect(json['is_trial_period']).to eq(obj.is_trial_period.to_s)
      end

      describe 'expires date' do
        let(:date) { obj.expires_date }
        it_behaves_like 'expires a date'
      end
    end

    it 'contains the lastest_receipt' do
      expect(subject['latest_receipt']).to_not be_nil
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
      let(:subscription_options) do
        {
          expires_date: 1.month.from_now
        }
      end

      let!(:renewal) do
        subscription.renew subscription_options
      end

      it 'contains two transactions in receipt.in_app' do
        expect(subject['receipt']['in_app'].length).to eq(2)
      end

      it 'contains three transactions in latest_receipt_info' do
        expect(subject['latest_receipt_info'].length).to eq(3)
      end

      context 'when in_app is true' do
        let(:subscription_options) do
          {
            expires_date: 1.month.from_now,
            in_app: true
          }
        end

        it 'contains three transactions in receipt.in_app' do
          expect(subject['receipt']['in_app'].length).to eq(3)
        end

        it 'contains three transactions in latest_receipt_info' do
          expect(subject['latest_receipt_info'].length).to eq(3)
        end
      end
    end
  end
end
