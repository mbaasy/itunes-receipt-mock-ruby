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

    subject { validation.result }

    it 'contains the purchases in the receipt.in_app object' do
      expect(validation.receipt.in_app.length).to eq(2)
    end

    it 'contains the purchases in the latest_receipt_info object' do
      expect(validation.latest_receipt_info.length).to eq(2)
    end

    context 'renewing the subscription' do
      let!(:renewal) do
        validation.renew_subscription subscription,
                                      expires_date: 1.month.from_now
      end

      it 'contains two subscription transactions in latest_receipt_info' do
        expect(validation.latest_receipt_info.length).to eq(3)
      end
    end
  end
end
