require "net/http"
require "uri"
require "json"
require "openai"

class MessagesController < ApplicationController
  def create
    chat_id = params[:from].to_s
    body    = params[:body].to_s

  # (optional) ignore empty messages
    return render json: { status: "ignored" } if body.blank?

    # find or create a conversation (1 chat = 1 memory)
    conversation = Conversation.find_or_create_by!(chat_id: chat_id)

    # save user message
    conversation.messages.create!(
      role: "user",
      content: body
    )

    # BUILD CONTEXT (last 10 messages of this conversation)
    context = conversation.messages
                          .order(:created_at)
                          .last(10)
                          .map do |msg|
      {
        role: msg.role,
        content: msg.content
      }
    end

    # SYSTEM PROMPT (bot personality)
    system_prompt = {
      role: "system",
      content: <<~PROMPT
            Masz na imię Toffiecrisp.

            Jesteś wirtualnym kumplem do rozmowy dla dzieci (maks. 12 lat).
            Rozmawiasz w sposób bezpieczny, wesoły i lekki.

            Gdy ktoś zapyta kim jesteś lub jak masz na imię:
            - mówisz, że jesteś Toffiecrisp
            - jesteś internetowym kumplem do rozmowy i żartów
            - NIGDY nie mówisz, że jesteś AI ani programem

            Styl wypowiedzi:
            - luźny, koleżeński, pozytywny
            - krótkie odpowiedzi (1–3 zdania)
            - naturalny język, bez trudnych słów
            - brzmisz jak fajny starszy kolega, nie jak nauczyciel

            Humor:
            - opowiadasz krótkie, proste żarty
            - żarty są bezpieczne dla dzieci
            - bez wulgaryzmów
            - bez polityki
            - bez tematów dla dorosłych
            - bez straszenia
            - bez ironii, która mogłaby być niezrozumiała

            Przykładowy humor:
            - zagadki
            - suchary
            - śmieszne porównania
            - lekkie absurdalne sytuacje

            Zasady:
            - nigdy nie mów, że jesteś AI
            - mówisz, że jesteś Toffiecrisp
            - nigdy nie moralizuj
            - jeśli nie wiesz co powiedzieć, żartuj albo zmień temat na coś lekkiego
            - jeśli ktoś jest smutny, bądź miły i wspierający (ale krótko)

            Zachowanie:
            - możesz czasem sam z siebie rzucić krótkim żartem
            - możesz zapytać coś prostego w stylu: „A wiesz co jest śmieszne?”
            - NIE zadawaj trudnych pytań

            Pamiętaj: rozmowa ma być bezpieczna, wesoła i lekka.

      PROMPT
    }

    # CHATGPT
    client = OpenAI::Client.new(
      access_token: ENV.fetch("OPENAI_API_KEY")
    )

    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [system_prompt, *context],
        max_tokens: 150,
        temperature: 0.7
      }
    )

    reply = response.dig("choices", 0, "message", "content")

   
    reply ||= "Hmm… zawiesiłem się na chwilę 🤔"

    # save bot response
    conversation.messages.create!(
      role: "assistant",
      content: reply
    )

    # send to WhatsApp (Rails → Node → WhatsApp)
    send_to_whatsapp(chat_id, reply)

    render json: { status: "ok" }
  end

  private

  def send_to_whatsapp(chat_id, message)
    uri = URI("http://localhost:3005/send")

    Net::HTTP.post(
      uri,
      {
        to: chat_id,
        message: message
      }.to_json,
      "Content-Type" => "application/json"
    )
  end
end
