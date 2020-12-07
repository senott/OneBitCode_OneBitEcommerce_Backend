module Admin
  module V1
    class CategoriesController < ApiController
      before_action :load_category, only: %i[update destroy show]

      def index
        @categories = load_categories
      end

      def show
      end

      def create
        @category = Category.new
        @category.attributes = category_params
        save_category!
      end

      def update
        @category.attributes = category_params
        save_category!
      end

      def destroy
        @category.destroy!
      end

      private

      def load_category
        @category = Category.find(params[:id])
      rescue StandardError
        render_errors(message: 'Could not find category.')
      end

      def load_categories
        permitted = params.permit({ search: :name }, { order: {} }, :page, :length)
        Admin::ModelLoadingService.new(Category.all, permitted).call
      end

      def category_params
        return {} unless params.key?('category')

        params.require(:category).permit(:name)
      end

      def save_category!
        @category.save!
        render :show
      rescue StandardError
        render_errors(fields: @category.errors.messages)
      end
    end
  end
end
