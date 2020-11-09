require 'rails_helper'

RSpec.describe 'Admin::V1::Categories', type: :request do
  let(:user) { create(:user) }
  let(:url) { '/admin/v1/categories' }

  describe 'GET /categories' do
    let!(:categories) { create_list(:category, 5) }

    it 'should return all categories' do
      get url, headers: auth_header(user)
      expect(body_json['categories']).to contain_exactly(*categories.as_json(only: %i[id name]))
    end

    it 'returns status code 200' do
      get url, headers: auth_header(user)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST /categories' do
    context 'with valid params' do
      let(:category_params) { attributes_for(:category).to_json }

      it 'should create a new category' do
        expect do
          post url, headers: auth_header(user), params: category_params
        end.to change(Category, :count).by(1)
      end

      it 'should return the category created' do
        post url, headers: auth_header(user), params: category_params
        expected_category = Category.last.as_json(only: %i[id name])
        expect(body_json['category']).to eq(expected_category)
      end

      it 'should return status code 200' do
        post url, headers: auth_header(user), params: category_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:category_invalid_params) { attributes_for(:category, name: nil).to_json }

      it 'should not create a new category' do
        expect do
          post url, headers: auth_header(user), params: category_invalid_params
        end.to_not change(Category, :count)
      end

      it 'should return an error message' do
        post url, headers: auth_header(user), params: category_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable entity status code' do
        post url, headers: auth_header(user), params: category_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end
end
