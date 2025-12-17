class Conversation < ApplicationRecord
    has_many :messages, dependent: :destroy
  
    validates :chat_id, presence: true, uniqueness: true
  end
  