require 'rails_helper'

RSpec.describe 'Admin::V1::Coupons without authentication', type: :request do
  let(:url) { '/admin/v1/coupons' }

  describe 'GET /coupons' do
    let!(:coupons) { create_list(:coupon, 5) }

    before(:each) { get url }

    include_examples 'unauthenticated access'
  end

  describe 'POST /coupons' do
    let(:coupon_params) { attributes_for(:coupon).to_json }

    before(:each) { post url, params: coupon_params }
    
    include_examples 'unauthenticated access'
  end

  describe 'PATCH /coupons/:id' do
    let(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }
    let(:new_name) { 'My new coupon' }
    let(:coupon_params) { { coupon: { name: new_name } }.to_json }

    before(:each) { patch url, params: coupon_params  }

    include_examples 'unauthenticated access'
  end

  describe 'DELETE /coupons/:id' do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    before(:each) { delete url }

    include_examples 'unauthenticated access'
  end
end