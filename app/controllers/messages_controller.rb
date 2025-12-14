require "net/http"
require "uri"
require "json"

class MessagesController < ApplicationController
  def create
    chat_id = params[:from].to_s
    body    = params[:body].to_s

    # 1️⃣ znajdź lub utwórz rozmowę
    conversation = Conversation.find_or_create_by!(chat_id: chat_id)

    # 2️⃣ zapisz wiadomość użytkownika
    conversation.messages.create!(
      role: "user",
      content: body
    )

    # 3️⃣ (na razie prosta odpowiedź)
    reply = "Zapamiętałem 😎 Mówiłeś: \"#{body}\""

    # 4️⃣ zapisz odpowiedź bota
    conversation.messages.create!(
      role: "assistant",
      content: reply
    )

    # 5️⃣ wyślij do Node (/send)
    send_to_whatsapp(chat_id, reply)

    render json: { status: "ok" }
  end

  private

  def send_to_whatsapp(chat_id, message)
    uri = URI("http://localhost:3005/send")

    Net::HTTP.post(
      uri,
      { to: chat_id, message: message }.to_json,
      "Content-Type" => "application/json"
    )
  end
end
