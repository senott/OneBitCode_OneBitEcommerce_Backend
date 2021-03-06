module Admin
  module V1
    class CouponsController < ApiController
      before_action :load_coupon, only: %i[update destroy]

      def index
        @coupons = Coupon.all
      end

      def create
        @coupon = Coupon.new
        @coupon.attributes = coupon_params
        save_coupon!
      end

      def update
        @coupon.attributes = coupon_params
        save_coupon!
      end

      def destroy
        @coupon.destroy
      end

      private

      def load_coupon
        @coupon = Coupon.find(params[:id])
      rescue StandardError
        render_errors(message: 'Could not find coupon.')
      end

      def coupon_params
        return {} unless params.key?('coupon')

        params.require(:coupon).permit(:code, :status, :discount_value, :due_date)
      end

      def save_coupon!
        @coupon.save!
        render :show
      rescue StandardError
        render_errors(fields: @coupon.errors.messages)
      end
    end
  end
end
