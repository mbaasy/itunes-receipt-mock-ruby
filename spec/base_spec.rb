require 'spec_helper'

describe ItunesReceiptMock::Base do
  describe '.new' do
    let(:options) { { :bundle_id => 'foobar' } }

    subject { described_class.new(options) }

    it 'creates an instance of Receipt' do
      expect(subject.receipt).to be_a(ItunesReceiptMock::Receipt)
    end
  end

  describe '#result' do
    let(:base) { described_class.new(:bundle_id => 'foobar') }

    subject { base.result(options) }

    context 'when status is 0' do
      let(:options) { { :status => 0 } }

      it 'returns everything' do
        expect(subject['status']).to eq(0)
        expect(subject['environment']).to_not be_nil
        expect(subject['receipt']).to_not be_nil
      end
    end

    context 'when status is not 0' do
      let(:options) { { :status => 1 } }

      it 'returns just the status' do
        expect(subject).to eq('status' => options[:status])
      end
    end
  end
end
