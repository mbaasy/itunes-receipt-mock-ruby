require 'spec_helper'

describe ItunesReceiptMock::Validation do
  describe '.new' do
    let(:options) { { bundle_id: 'foobar' } }

    subject { described_class.new(options) }

    it 'creates an instance of Receipt' do
      expect(subject.receipt).to be_a(ItunesReceiptMock::Receipt)
    end
  end

  describe '#result' do
    let(:validation) { described_class.new(bundle_id: 'foobar') }

    subject { validation.result(options) }

    context 'when status is 0' do
      let(:options) { { status: 0 } }

      it 'returns everything' do
        expect(subject['status']).to eq(0)
        expect(subject['environment']).to_not be_nil
        expect(subject['receipt']).to_not be_nil
      end
    end

    context 'when status is not 0' do
      let(:options) { { status: 1 } }

      it 'returns just the status' do
        expect(subject).to eq('status' => options[:status])
      end
    end
  end

  describe '#add_purchase' do
    let(:validation) { described_class.new(bundle_id: 'foobar') }

    subject { validation.add_purchase(product_id: 'foobar') }

    it 'adds the purchase to the #latest_receipt_info object' do
      expect(validation.latest_receipt_info[subject.transaction_id])
        .to eq(subject)
    end
  end

  describe '#add_subscription' do
    let(:validation) { described_class.new(bundle_id: 'foobar') }

    subject do
      validation.add_subscription product_id: 'foobar',
                                  expires_date: 1.month.from_now
    end

    it 'adds the subscription to the #latest_receipt_info object' do
      expect(validation.latest_receipt_info[subject.transaction_id])
        .to eq(subject)
    end
  end

  describe '#renew_subscription' do
    let(:validation) { described_class.new(bundle_id: 'foobar') }
    let(:subscription) do
      validation.add_subscription product_id: 'foobar',
                                  purchase_date: 1.month.ago,
                                  expires_date: Time.now
    end

    subject do
      validation.renew_subscription subscription,
                                    expires_date: 1.month.from_now
    end

    it 'removes the old transaction from #receipt#in_app' do
      expect(validation.receipt.in_app[subscription.transaction_id])
        .to eq(subscription)
      subject
      expect(validation.receipt.in_app[subscription.transaction_id])
        .to be_nil
    end

    it 'adds the new transaction to #receipt#in_app' do
      expect(validation.receipt.in_app[subject.transaction_id]).to eq(subject)
    end

    it 'adds the new tranaction to #latest_receipt_info' do
      expect(validation.latest_receipt_info[subject.transaction_id])
        .to eq(subject)
    end

    it 'preserves both transactions in #latest_receipt_info' do
      subject
      expect(validation.latest_receipt_info.values)
        .to match_array([subscription, subject])
    end
  end
end
