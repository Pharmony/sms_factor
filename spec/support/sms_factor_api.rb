# frozen_string_literal: true

RSpec.shared_context 'with sms_factor responses' do
  def success_response(body_hash)
    instance_spy(
      RestClient::Response,
      body: body_hash.to_json
    )
  end

  def error_response(status, message)
    instance_spy(
      RestClient::Response,
      body: { status: status, message: message }.to_json
    )
  end
end

RSpec.shared_examples 'an endpoint with API errors' do |params|
  include_context 'with sms_factor responses'

  def call_api_method(api, method_name, args)
    method_args = args.dup
    kwargs = {}

    if method_args.size == 1 && method_args.first.is_a?(Hash)
      # Single hash passed: interpret as kwargs
      kwargs = method_args.first
      method_args = []
    elsif method_args.last.is_a?(Hash)
      # Multiple args, ending with a hash
      kwargs = method_args.pop
    end

    api.send(method_name, *method_args, **kwargs)
  end

  let(:error_cases) do
    {
      auth_error: [-1, SmsFactor::AuthError, 'Auth error'],
      not_enough_credits: [-3, SmsFactor::NotEnoughCreditsError, 'Not enough credits'],
      resource_not_found: [-5, SmsFactor::ResourceNotFoundError, 'Not found'],
      invalid_token: [-10, SmsFactor::InvalidTokenIdError, 'Token not found']
    }
  end

  it 'raises an API error' do
    status_code, error_class, error_message = error_cases.fetch(params[:error_key])

    allow(RestClient).to receive(params[:http_verb]).and_return(error_response(status_code, error_message))

    expect do
      call_api_method(api, params[:method_name], params[:args])
    end.to raise_error(error_class, /#{error_message}/)
  end
end
