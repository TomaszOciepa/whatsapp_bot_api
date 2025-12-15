module Api
  class MessagesController < ApplicationController
    def create
      Api::MessageProcessor.call(
        from: params[:from],
        body: params[:body]
      )

      render json: { status: "ok" }
    end
  end
end
