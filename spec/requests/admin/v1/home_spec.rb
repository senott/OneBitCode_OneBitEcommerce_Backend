require 'rails_helper'

describe 'Home', type: :request do
  let(:user) { create(:user) }

  it 'returns the correct message' do
    get '/admin/v1/home', headers: auth_header(user)
    expect(body_json).to eq({ 'message' => 'Uhulll!!!!!' })
  end

  it 'returns the correct status' do
    get '/admin/v1/home', headers: auth_header(user)
    expect(response).to have_http_status(:ok)
  end
end
