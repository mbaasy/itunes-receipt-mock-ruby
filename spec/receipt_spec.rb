require 'spec_helper'

describe ItunesReceiptMock::Receipt do
  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  describe '.new' do
    subject { described_class.new(options) }

    context 'with minimal options' do
      let(:options) { { :bundle_id => 'foobar' } }

      it 'sets "bundle_id" to the option value' do
        expect(subject.bundle_id).to eq(options[:bundle_id])
      end

      it 'defaults everything else' do
        expect(subject.environment).to eq('Production')
        expect(subject.adam_id).to eq(0)
        expect(subject.app_item_id).to eq(0)
        expect(subject.application_version).to eq('1')
        expect(subject.download_id).to eq(0)
        expect(subject.version_external_identifier).to eq(0)
        expect(subject.original_purchase_date).to eq(Time.now)
      end
    end

    context 'when options are complete' do
      let(:options) do
        {
          :bundle_id => 'foobar',
          :environment => 'Sandbox',
          :adam_id => rand(1..5),
          :app_item_id => rand(1..5),
          :application_version => rand(1..5).to_s,
          :download_id => rand(1..5),
          :version_external_identifier => rand(1..5),
          :original_purchase_date => Time.new(2015, 06, 20, 8, 16, 32)
        }
      end

      it 'sets all the things' do
        expect(subject.environment).to eq(options[:environment])
        expect(subject.adam_id).to eq(options[:adam_id])
        expect(subject.app_item_id).to eq(options[:app_item_id])
        expect(subject.application_version).to eq(options[:application_version])
        expect(subject.download_id).to eq(options[:download_id])
        expect(subject.version_external_identifier).to eq(options[:version_external_identifier])
        expect(subject.original_purchase_date).to eq(options[:original_purchase_date])
      end
    end
  end

  describe '#add_purchase' do
    let(:receipt) { described_class.new(:bundle_id => 'foobar') }

    subject { receipt.add_purchase(options) }

    context 'with minimal options' do
      let(:options) { { :product_id => 'whatever' } }

      it 'creates an instance of Purchase' do
        expect(subject).to be_a(Array)
        expect(subject.length).to eq(1)
        expect(subject.first).to be_a(ItunesReceiptMock::Purchase)
      end
    end

    context 'when product_id is not present' do
      let(:options) { { } }

      it 'raises an MissingArgumentError' do
        expect {subject}.to raise_error(ItunesReceiptMock::MissingArgumentError)
      end
    end
  end

  describe '#add_subscription' do
    let(:receipt) { described_class.new(:bundle_id => 'foobar') }

    subject { receipt.add_subscription(options) }

    context 'with minimal options' do
      let(:options) { { :product_id => 'whatever', expires_date: 1.month.from_now } }

      it 'creates an instance of Subscription' do
        expect(subject).to be_a(Array)
        expect(subject.length).to eq(1)
        expect(subject.first).to be_a(ItunesReceiptMock::Subscription)
      end
    end

    context 'when expires_date is not present' do
      let(:options) { { :product_id => 'whatever' } }

      it 'raises an MissingArgumentError' do
        expect {subject}.to raise_error(ItunesReceiptMock::MissingArgumentError)
      end
    end
  end

  describe '#result' do
    let(:receipt) { described_class.new(:bundle_id => 'foobar') }
    let(:options) { { } }

    subject { receipt.result(options) }

    it 'returns everything' do
      expect(subject['receipt_type']).to eq(receipt.environment)
      expect(subject['adam_id']).to eq(receipt.adam_id)
      expect(subject['app_item_id']).to eq(receipt.app_item_id)
      expect(subject['bundle_id']).to eq(receipt.bundle_id)
      expect(subject['application_version']).to eq(receipt.application_version)
      expect(subject['download_id']).to eq(receipt.download_id)
      expect(subject['version_external_identifier']).to eq(receipt.version_external_identifier)
      expect(subject['original_application_version']).to eq(receipt.original_application_version)
      expect(subject['in_app']).to be_a(Array)
      expect(subject['request_date']).to eq(Time.now.utc.strftime('%F %T') + ' Etc/GMT')
      expect(subject['original_purchase_date']).to eq(receipt.original_purchase_date.utc.strftime('%F %T') + ' Etc/GMT')
    end

    context 'when "request_date" is in options' do
      let(:options) { { :request_date => rand(1..5).hours.ago } }

      it 'returns the request_date as specified' do
        expect(subject['request_date']).to eq(options[:request_date].utc.strftime('%F %T') + ' Etc/GMT')
      end
    end
  end
end
