# frozen_string_literal: true

module Redd
  module Models
    # Things that can be sent to a user's inbox.
    module Inboxable
      # Block the user that sent this item.
      def block() = @client.post('/api/block', id: @attributes.fetch(:name))

      # Mark this thing as read.
      def mark_as_read() = @client.post('/api/read_message', id: @attributes.fetch(:name))

      # Mark one or more messages as unread.
      def mark_as_unread() = @client.post('/api/unread_message', id: @attributes.fetch(:name))
    end
  end
end
