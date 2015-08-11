require 'spec_helper'

describe ItunesReceiptMock do
  describe '.new' do
    subject { described_class.new(options) }

    context 'with minimal options' do
      let(:options) { { :bundle_id => 'foobar' } }

      it 'creates an instance of Base' do
        expect(subject).to be_a(described_class::Base)
      end
    end

    context 'when bundle_id is not present' do
      let(:options) { {} }

      it 'raises an MissingArgumentError' do
        expect {subject}.to raise_error(described_class::MissingArgumentError)
      end
    end
  end
end
