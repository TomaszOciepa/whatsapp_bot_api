module Chat
    class ContextBuilder
      def self.call(conversation, limit: 10)
        conversation.messages
                    .order(:created_at)
                    .last(limit)
                    .map do |msg|
          { role: msg.role, content: msg.content }
        end
      end
    end
  end
  