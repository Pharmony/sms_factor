# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SmsFactor::ResponseFactory do
  let(:success_response) do
    instance_double(
      RestClient::Response,
      body: {
        status: 1,
        message: 'OK',
        credits: 200,
        postpaid: 0,
        postpaid_limit: false,
        unlimited: false
      }.to_json
    )
  end

  let(:error_response) do
    instance_double(RestClient::Response, body: { status: -3, message: 'Not enough credits' }.to_json)
  end

  describe '.build' do
    subject(:result) do
      described_class.build(success_response, SmsFactor::Responses::BalanceResponse)
    end

    it 'returns a BalanceResponse' do
      expect(result).to be_a(SmsFactor::Responses::BalanceResponse)
    end

    it 'has the correct credits value' do
      expect(result.credits).to eq(200)
    end
  end

  describe '.build with unknown error status' do
    let(:unknown_error_response) do
      instance_double(RestClient::Response,
                      body: { status: -99, message: 'Something weird happened' }.to_json)
    end

    it 'raises UnknownApiError for unknown status codes' do
      expect do
        described_class.build(unknown_error_response, SmsFactor::Responses::BalanceResponse)
      end.to raise_error(SmsFactor::UnknownApiError, /Something weird happened/)
    end
  end

  describe '.build with error response' do
    it 'raises ApiError on error status' do
      expect do
        described_class.build(error_response, SmsFactor::Responses::BalanceResponse)
      end.to raise_error(SmsFactor::NotEnoughCreditsError, /Not enough credits/)
    end
  end
end
