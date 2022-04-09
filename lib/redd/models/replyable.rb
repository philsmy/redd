# frozen_string_literal: true

module Redd
  module Models
    # A model that can be commented on or replied to.
    module Replyable
      # Anything replyable has a name
      def name() = @attributes.fetch(:name)

      # Add a comment to a link, reply to a comment or reply to a message.
      # @param text [String] the text to comment
      # @return [Comment, PrivateMessage] The created reply.
      def reply(text) = @client.model(:post, '/api/comment', text:, thing_id: name).first
    end
  end
end
