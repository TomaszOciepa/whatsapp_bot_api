module Admin
    class DashboardController < ApplicationController
      def index
        # ===== PODSTAWOWE STATYSTYKI =====
        @conversations_count = Conversation.count
        @messages_count = Message.count
  
        @active_today_count =
          Conversation
            .joins(:messages)
            .where(messages: { created_at: Time.zone.today.all_day })
            .distinct
            .count
  
        @last_message = Message.order(created_at: :desc).first
  
        # ===== WYKRES: OSTATNIE 7 DNI (SQLITE SAFE) =====
        days_range = (6.days.ago.to_date..Date.current)
  
        messages =
          Message.where(
            created_at: days_range.first.beginning_of_day..days_range.last.end_of_day
          )
  
        messages_grouped =
          messages.group_by { |m| m.created_at.in_time_zone.to_date }
  
        @messages_by_day =
          days_range.each_with_object({}) do |date, hash|
            hash[date] = messages_grouped[date]&.size || 0
          end
      end
    end
  end
  