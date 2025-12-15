module Api
  class MessagesController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def create
      Api::MessageProcessor.call(
        from: params[:from],
        body: params[:body]
      )

      render json: { status: "ok" }
    end
  end
end
