# frozen_string_literal: true

require 'spec_helper'

describe SmsFactor, :vcr do
  let(:message) { FFaker::LoremFR.phrase[0..160] }

  describe 'sms' do
    let(:recipients) { FFaker::PhoneNumberFR.mobile_phone_number }

    context 'without being configured' do
      it 'raises' do
        expect { described_class.sms(message, recipients) }
          .to raise_error(RuntimeError, /The configuration is not complete\./)
      end
    end

    context 'with wrong credentials auth' do
      let(:cassette_name) { 'wrong_credentials_auth' }

      before do
        SmsFactor::Init.configure do |config|
          config.api_default_from = FFaker::CompanyFR.name
          config.api_login = FFaker::Internet.email
          config.api_password = FFaker::Internet.password
        end
      end

      it "doesn't deliver" do
        expect(described_class.sms(message, recipients)).not_to be_success
      end
    end

    context 'with valid credentials auth' do
      let(:cassette_name) { 'valid_credentials_auth' }

      before do
        SmsFactor::Init.configure do |config|
          config.api_default_from = FFaker::CompanyFR.name
          config.api_login = 'juseveno@idol.io'
          config.api_password = 'julien'
        end
      end

      it 'delivers' do
        expect(described_class.sms(message, '0799175425')).to be_success
      end

      it 'responds with status equal 1' do
        expect(described_class.sms(message, '0799175425').status).to be 1
      end

      it 'responds with message equal to "OK"' do
        expect(described_class.sms(message, '0799175425').message).to eql 'OK'
      end
    end

    context 'with wrong API key auth' do
      let(:cassette_name) { 'wrong_api_key_auth' }

      before do
        SmsFactor::Init.configure do |config|
          config.api_default_from = FFaker::CompanyFR.name
          config.api_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiw' \
                           'iaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'
        end
      end

      it "doesn't deliver" do
        expect(described_class.sms(message, recipients)).not_to be_success
      end

      it 'responds with status equal -1' do
        expect(described_class.sms(message, '0799175425').status).to be(-1)
      end
    end

    context 'with valid API key auth' do
      let(:cassette_name) { 'valid_api_key_auth' }

      before do
        SmsFactor::Init.configure do |config|
          config.api_default_from = FFaker::CompanyFR.name
          config.api_key = SMS_FACTOR_API_KEY
        end
      end

      it 'delivers' do
        expect(described_class.sms(message, '0799175425')).to be_success
      end

      it 'responds with status equal 1' do
        expect(described_class.sms(message, '0799175425').status).to be 1
      end

      it 'responds with message equal to "OK"' do
        expect(described_class.sms(message, '0799175425').message).to eql 'OK'
      end

      it 'uses the passed API key' do
        described_class.sms(message, '0799175425')

        expect(WebMock)
          .to have_requested(:post, 'https://api.smsfactor.com/send')
          .with(headers: { Authorization: "Bearer #{SMS_FACTOR_API_KEY}" }).once
      end
    end
  end

  describe 'deliver' do
    context 'with valid API key auth and an api_key argument' do
      let(:another_sms_factor_api_key) do
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTA1NiIsImlhdCI6MTY4MTM3MzI2Ni4wMDM0NDF9.r0V1zH5GwtW1_dvRqb' \
          'PAhcuUE33JY_sT3uUQs8e8Cn4'
      end
      let(:cassette_name) { 'passed_valid_api_key_auth' }
      let(:sms) { described_class.new(message, '0799175425') }

      before do
        SmsFactor::Init.configure do |config|
          config.api_default_from = FFaker::CompanyFR.name
          config.api_key = SMS_FACTOR_API_KEY
        end
      end

      it 'delivers' do
        expect(sms.deliver(api_key: another_sms_factor_api_key)).to be_success
      end

      it 'uses the passed API key' do
        sms.deliver(api_key: another_sms_factor_api_key)

        expect(WebMock)
          .to have_requested(:post, 'https://api.smsfactor.com/send')
          .with(headers: { Authorization: "Bearer #{another_sms_factor_api_key}" }).once
      end
    end
  end
end
