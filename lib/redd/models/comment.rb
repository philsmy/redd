# frozen_string_literal: true

require_relative 'lazy_model'
require_relative 'gildable'
require_relative 'inboxable'
require_relative 'moderatable'
require_relative 'postable'
require_relative 'replyable'

require_relative 'listing'
require_relative 'subreddit'
require_relative 'user'

module Redd
  module Models
    # A comment.
    class Comment < LazyModel
      include Gildable
      include Inboxable
      include Moderatable
      include Postable
      include Replyable

      # Create a Comment from its fullname.
      # @param client [APIClient] the api client to initialize the object with
      # @param id [String] the fullname
      # @return [Comment]
      def self.from_id(client, id) = new(client, name: id)

      def name() = @attributes.fetch(:name)

      private

      def after_initialize
        @attributes[:replies] =
          if @attributes[:replies].is_a?(Hash)
            @client.unmarshal(@attributes[:replies])
          else
            Models::Listing.new(@client, children: [], after: nil, before: nil)
          end

        @attributes[:author] = User.from_id(@client, @attributes.fetch(:author))
        @attributes[:subreddit] = Subreddit.from_id(@client, @attributes.fetch(:subreddit))
      end

      def default_loader
        @attributes.key?(:link_id) ? load_with_comments : load_without_comments
      end

      def load_with_comments
        url = format(
          '/comments/%<link_id>s/_/%<id>s',
          link_id: @attributes[:link_id].sub('t3_', ''),
          id: @attributes.fetch(:id) { name.sub('t1_', '') }
        )

        @client.get(url).body[1][:data][:children][0][:data]
      end

      def load_without_comments
        @client.get(
          '/api/info',
          id: "t1_#{@attributes.fetch(:id) { name.sub('t1_', '') }}"
        ).body[:data][:children][0][:data]
      end
    end
  end
end
