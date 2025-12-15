module Api
    class MessageProcessor
      def self.call(from:, body:)
        return if body.blank?
  
        conversation = Conversation.find_or_create_by!(chat_id: from)
  
        conversation.messages.create!(
          role: "user",
          content: body
        )
  
        context = Chat::ContextBuilder.call(conversation)
        prompt  = Chat::PromptBuilder.system_prompt
        reply   = Chat::OpenAiClient.call(prompt, context)
  
        conversation.messages.create!(
          role: "assistant",
          content: reply
        )
  
        Whatsapp::Sender.call(from, reply)
      end
    end
  end
  