require 'rails_helper'

RSpec.describe 'Admin::V1::Categories as :admin', type: :request do
  let(:user) { create(:user) }
  let(:url) { '/admin/v1/categories' }

  describe 'GET /categories' do
    let!(:categories) { create_list(:category, 10) }

    context 'without any parameters' do
      it 'should return 10 categories' do
        get url, headers: auth_header(user)
        expect(body_json['categories'].count).to eq(10)
      end

      it 'should return 10 first categories' do
        get url, headers: auth_header(user)
        expected_categories = categories[0..9].as_json(only: %i[id name])

        expect(body_json['categories']).to contain_exactly(*expected_categories)
      end

      it 'returns success status code' do
        get url, headers: auth_header(user)
        expect(response.status).to eq(200)
      end
    end

    context 'with search[:name] param' do
      let!(:search_name_categories) do
        categories = []
        15.times { |n| categories << create(:category, name: "Search #{n + 1}") }
        categories
      end

      let(:search_params) { { search: { name: "Search" } } }

      it 'should return only searched categories limited by default pagination' do
        get url, headers: auth_header(user), params: search_params
        expected_categories = search_name_categories[0..9].map do |category|
          category.as_json(only: %i[id name])
        end

        expect(body_json['categories']).to contain_exactly(*expected_categories)
      end

      it 'returns success status code' do
        get url, headers: auth_header(user), params: search_params
        expect(response.status).to eq(200)
      end
    end

    context 'with pagination params' do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it 'should return records sized by :length' do
        get url, headers: auth_header(user), params: pagination_params

        expect(body_json['categories'].count).to eq(length)
      end

      it 'should return categories limited by pagination' do
        get url, headers: auth_header(user), params: pagination_params
        expected_categories = categories[5..9].as_json(only: %i[id name])

        expect(body_json['categories']).to contain_exactly(*expected_categories)
      end

      it 'should return success status code' do
        get url, headers: auth_header(user), params: pagination_params
        expect(response.status).to eq(200)
      end
    end

    context 'with order params' do
      let(:order_params) { { order: { name: 'desc' } } }

      it 'should return ordered categorieslimited by default pagination' do
        get url, headers: auth_header(user), params: order_params
        categories.sort! { |a, b| b.name <=> a.name }
        expected_categories = categories[0..9].as_json(only: %i[id name])

        expect(body_json['categories']).to contain_exactly(*expected_categories)
      end

      it 'should return success status code' do
        get url, headers: auth_header(user), params: order_params
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'GET /categories/:id' do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    before(:each) { get url, headers: auth_header(user) }

    it 'should return requested category' do
      expected_category = category.as_json(only: %i[id name])

      expect(body_json['category']).to eq(expected_category)
    end

    it 'should return success status' do
      expect(response) .to have_http_status(:ok)
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

  describe 'PATCH /categories/:id' do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    context 'with valid params' do
      let(:new_name) { 'My new category' }
      let(:category_params) { { category: { name: new_name } }.to_json }

      it 'should update category name' do
        patch url, headers: auth_header(user), params: category_params
        category.reload
        expect(category.name).to eq(new_name)
      end

      it 'should return updated category' do
        patch url, headers: auth_header(user), params: category_params
        category.reload
        expected_category = category.as_json(only: %i[id name])
        expect(body_json['category']).to eq(expected_category)
      end

      it 'should return status code 200' do
        patch url, headers: auth_header(user), params: category_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      let(:category_invalid_params) { attributes_for(:category, name: nil).to_json }

      it 'should not update category' do
        old_name = category.name
        patch url, headers: auth_header(user), params: category_invalid_params
        category.reload
        expect(category.name).to eq(old_name)
      end

      it 'should return an error message' do
        patch url, headers: auth_header(user), params: category_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'should return unprocessable entity status code' do
        patch url, headers: auth_header(user), params: category_invalid_params
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE /categories/:id' do
    let!(:category) { create(:category) }

    context 'with valid parameter' do
      let(:url) { "/admin/v1/categories/#{category.id}" }

      it 'should remove the category' do
        expect do
          delete url, headers: auth_header(user)
        end.to change(Category, :count).by(-1)
      end

      it 'should return status code 204' do
        delete url, headers: auth_header(user)
        expect(response.status).to eq(204)
      end

      it 'should not return any body content' do
        delete url, headers: auth_header(user)
        expect(body_json).to_not be_present
      end

      it 'should remove all associated product categories' do
        product_categories = create_list(:product_category, 3, category: category)
        delete url, headers: auth_header(user)
        expected_product_categories = ProductCategory.where(id: product_categories.map(&:id))
        expect(expected_product_categories).to be_empty
      end
    end

    context 'with invalid parameter' do
      let(:url) { '/admin/v1/categories/invalid-id' }

      it 'should not remove the category' do
        expect do
          delete url, headers: auth_header(user)
        end.to_not change(Category, :count)
      end

      it 'should return an error message' do
        delete url, headers: auth_header(user)
        expect(body_json['errors']['message']).to eq('Could not find category.')
      end

      it 'should return unprocessable entity status code' do
        delete url, headers: auth_header(user)
        expect(response.status).to eq(422)
      end
    end
  end
end
