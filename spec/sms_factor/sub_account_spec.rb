# frozen_string_literal: true

require 'spec_helper'
require 'rest-client'

RSpec.describe SmsFactor::SubAccount do
  subject(:api) { described_class.new }

  include_context 'with sms_factor responses'

  let(:sub_account_data) do
    {
      client_id: 101,
      email: 'single@test.com',
      credits: 15,
      unlimited: 1,
      status: 1,
      firstname: 'Yoh',
      lastname: 'Asakura',
      city: 'Tokyo',
      phone: '33612345678',
      address1: 'Street 1',
      address2: 'Street 2',
      zip: '75000',
      country: 'FR',
      country_code: 'FR',
      lang: 'FR',
      senderid: '',
      time_zone: 'Europe/Paris',
      current_month_consumption: 100,
      previous_month_consumption: 200
    }
  end

  describe '#create' do
    context 'with valid parameters' do
      let(:api_response) do
        success_response(
          status: 1,
          message: 'OK',
          id: '1234',
          active: '1'
        )
      end

      let(:expect_create_call) do
        expect(RestClient).to have_received(:post).with(
          a_string_including('/account'),
          a_string_matching(/"email":"test@test.com"/)
            .and(a_string_matching(/"type":"company"/))
            .and(a_string_matching(/"firstname":"bob"/)),
          hash_including(:accept, :content_type)
        )
      end

      before do
        allow(RestClient).to receive(:post).and_return(api_response)
      end

      it 'builds correct payload' do
        api.create(email: 'test@test.com', password: 'secret', type: SmsFactor::SubAccount::COMPANY, firstname: 'bob')

        expect_create_call
      end
    end

    context 'with missing parameters' do
      it 'raises ArgumentError for missing email' do
        expect do
          api.create(email: '', password: 'secret', type: SmsFactor::SubAccount::COMPANY)
        end.to raise_error(ArgumentError, /email is required/)
      end

      it 'raises ArgumentError for missing password' do
        expect do
          api.create(email: 't@test.com', password: '', type: SmsFactor::SubAccount::COMPANY)
        end.to raise_error(ArgumentError, /password is required/)
      end

      it 'raises ArgumentError for missing type' do
        expect do
          api.create(email: 't@test.com', password: 'secret', type: nil)
        end.to raise_error(ArgumentError, /type is required/)
      end

      it 'raises ArgumentError for invalid type' do
        expect do
          api.create(email: 't@test.com', password: 'secret', type: 'badtype')
        end.to raise_error(ArgumentError, /Invalid type/)
      end
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :post,
      method_name: :create,
      args: [email: 't@test.com', password: 'secret', type: 'company'],
      error_key: :auth_error
    }
  end

  describe '#list' do
    let(:api_response) do
      success_response(
        status: 1,
        message: 'OK',
        sub_accounts: [sub_account_data]
      )
    end

    before do
      allow(RestClient).to receive(:get).and_return(api_response)
    end

    it 'returns list of sub accounts' do
      result = api.list
      expect(result.sub_accounts.map(&:client_id)).to eq [101]
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :get,
      method_name: :list,
      args: [],
      error_key: :auth_error
    }
  end

  describe '#get' do
    let(:api_response) do
      success_response(
        status: 1,
        message: 'OK',
        sub_account: sub_account_data
      )
    end

    before do
      allow(RestClient).to receive(:get).and_return(api_response)
    end

    it 'returns single sub account' do
      result = api.get(101)
      expect(result.sub_account.client_id).to eq 101
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :get,
      method_name: :get,
      args: [999],
      error_key: :resource_not_found
    }
  end

  describe '#lock' do
    let(:api_response) do
      success_response(
        status: 1,
        message: 'OK',
        state: 'locked'
      )
    end

    before do
      allow(RestClient).to receive(:get).and_return(api_response)
    end

    it 'locks a sub account' do
      result = api.lock(101)
      expect(result.state).to eq 'locked'
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :get,
      method_name: :lock,
      args: [101],
      error_key: :resource_not_found
    }
  end

  describe '#unlock' do
    let(:api_response) do
      success_response(
        status: 1,
        message: 'OK',
        state: 'unlocked'
      )
    end

    before do
      allow(RestClient).to receive(:get).and_return(api_response)
    end

    it 'unlocks a sub account' do
      result = api.unlock(101)
      expect(result.state).to eq 'unlocked'
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :get,
      method_name: :unlock,
      args: [101],
      error_key: :resource_not_found
    }
  end

  describe '#balance' do
    let(:api_response) do
      success_response(
        status: 1,
        message: 'OK',
        credits: 200,
        postpaid: 0,
        postpaid_limit: false,
        unlimited: false
      )
    end

    before do
      allow(RestClient).to receive(:get).and_return(api_response)
      allow(SmsFactor::Headers).to receive(:api_headers).and_call_original
    end

    it 'returns balance with credits' do
      result = api.balance
      expect(result.credits).to eq 200
    end

    it 'passes custom api_key to headers' do
      api.balance('subaccount-api-key')
      expect(SmsFactor::Headers).to have_received(:api_headers).with('subaccount-api-key')
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :get,
      method_name: :balance,
      args: [],
      error_key: :resource_not_found
    }
  end

  describe '#transfer_credits' do
    let(:api_response) do
      success_response(
        status: 1,
        message: 'OK',
        credits: '990',
        child_credits: '1010'
      )
    end

    before do
      allow(RestClient).to receive(:post).and_return(api_response)
    end

    it 'transfers credits' do
      result = api.transfer_credits(101, 10)
      expect(result.credits).to eq 990
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :post,
      method_name: :transfer_credits,
      args: [101, 10],
      error_key: :not_enough_credits
    }
  end
end
