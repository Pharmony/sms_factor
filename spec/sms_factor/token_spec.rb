# frozen_string_literal: true

require 'spec_helper'
require 'rest-client'

RSpec.describe SmsFactor::Token do
  subject(:api) { described_class.new }

  include_context 'with sms_factor responses'

  describe '#create_for_main_account' do
    let(:response) do
      success_response(
        status: 1,
        message: 'OK',
        token: 'abc.def',
        token_id: '2',
        allowed_ips: []
      )
    end

    def expect_create_call
      expect(RestClient).to have_received(:post).with(
        a_string_including('/token'),
        a_string_matching(/"name":"test"/)
          .and(a_string_matching(/"ttl":3600/))
          .and(a_string_matching(/"allowed_ips":\["1.2.3.4"\]/)),
        hash_including(:accept, :content_type)
      )
    end

    before do
      allow(RestClient).to receive(:post).and_return(response)
    end

    it 'creates a token for main account' do
      result = api.create_for_main_account(name: 'test')
      expect(result.token).to eq('abc.def')
    end

    it 'sends correct payload' do
      allow(RestClient).to receive(:post).and_return(response)

      api.create_for_main_account(name: 'test', ttl: 3600, allowed_ips: ['1.2.3.4'])

      expect_create_call
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :post,
      method_name: :create_for_main_account,
      args: [name: 'test'],
      error_key: :auth_error
    }
  end

  describe '#create_for_sub_account' do
    let(:response) do
      success_response(
        status: 1,
        message: 'OK',
        token: 'sub.token',
        token_id: '3',
        allowed_ips: []
      )
    end

    def expect_create_call
      expect(RestClient).to have_received(:post).with(
        a_string_including('/token/account/5'),
        a_string_matching(/"name":"SubToken"/)
          .and(a_string_matching(/"ttl":1800/))
          .and(a_string_matching(/"allowed_ips":\["8.8.8.8"\]/)),
        hash_including(:accept, :content_type)
      )
    end

    before do
      allow(RestClient).to receive(:post).and_return(response)
    end

    it 'creates token for sub account' do
      result = api.create_for_sub_account(sub_account_id: 5, name: 'SubToken')
      expect(result.token).to eq('sub.token')
    end

    it 'sends correct payload for sub account' do
      allow(RestClient).to receive(:post).and_return(response)

      api.create_for_sub_account(sub_account_id: 5, name: 'SubToken', ttl: 1800, allowed_ips: ['8.8.8.8'])

      expect_create_call
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :post,
      method_name: :create_for_sub_account,
      args: [sub_account_id: 5, name: 'SubToken'],
      error_key: :auth_error
    }
  end

  describe '#list' do
    let(:response) do
      success_response(
        status: 1,
        message: 'OK',
        tokens: [{
          name: 'My Token',
          api_token_id: 15,
          is_active: '1',
          created_at: '2025-01-01T01:00:00Z',
          expired_at: nil,
          ttl: nil,
          allowed_ips: []
        }]
      )
    end

    before do
      allow(RestClient).to receive(:get).and_return(response)
    end

    it 'returns tokens list with correct names' do
      result = api.list
      expect(result.tokens.map(&:name)).to eq(['My Token'])
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :get,
      method_name: :list,
      args: [],
      error_key: :resource_not_found
    }
  end

  describe '#get' do
    let(:response) do
      success_response(
        status: 1,
        message: 'OK',
        token: {
          name: 'One Token',
          api_token_id: 12,
          created_at: '2025-01-01T01:00:00Z',
          expired_at: nil,
          ttl: nil,
          is_active: '1',
          allowed_ips: []
        }
      )
    end

    before do
      allow(RestClient).to receive(:get).and_return(response)
    end

    it 'returns a single token with correct name' do
      result = api.get(token_id: 12)
      expect(result.token.name).to eq('One Token')
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :get,
      method_name: :get,
      args: [token_id: 999],
      error_key: :invalid_token
    }
  end

  describe '#delete' do
    let(:response) do
      success_response(
        status: 1,
        message: 'OK',
        deleted_token: '12'
      )
    end

    before do
      allow(RestClient).to receive(:delete).and_return(response)
    end

    it 'deletes a token and returns correct id' do
      result = api.delete(token_id: 12)
      expect(result.deleted_token).to eq(12)
    end

    it_behaves_like 'an endpoint with API errors', {
      http_verb: :delete,
      method_name: :delete,
      args: [token_id: 999],
      error_key: :invalid_token
    }
  end
end
