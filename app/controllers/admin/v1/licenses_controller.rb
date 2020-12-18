module Admin
  module V1
    class LicensesController < ApiController
      before_action :load_license, only: %i[show update destroy]

      def index
        @licenses = License.all
      end

      def show; end

      def create
        @license = License.new
        @license.attributes = license_params
        save_license!
      end

      def update
        @license.attributes = license_params
        save_license!
      end

      def destroy
        @license.destroy
      end

      private

      def license_params
        return {} unless params.key?('license')

        params.require(:license).permit(:id, :key, :game_id)
      end

      def load_license
        @license = License.find(params[:id])
      rescue StandardError
        render_errors(message: 'Could not find license.')
      end

      def save_license!
        @license.save!
        render :show
      rescue StandardError
        render_errors(fields: @license.errors.messages)
      end
    end
  end
end
