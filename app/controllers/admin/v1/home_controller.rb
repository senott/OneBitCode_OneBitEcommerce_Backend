module Admin
  module V1
    class HomeController < ApiController
      def index
        render json: { message: 'Uhulll!!!!!' }
      end
    end
  end
end
