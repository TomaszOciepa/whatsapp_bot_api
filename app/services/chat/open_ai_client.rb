module Chat
    class OpenAiClient
      def self.call(system_prompt, context)
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
  
        response.dig("choices", 0, "message", "content") ||
          "Hmm… chwilowo mi się zacięło 🤔"
      end
    end
  end
  