require_relative "thing"

module Redd
  module Objects
    # A submission made in a subreddit.
    class Submission < Thing
      include Thing::Editable
      include Thing::Hideable
      include Thing::Moderatable
      include Thing::Saveable
      include Thing::Votable

      alias_property :nsfw?, :over_18
      alias_property :self?, :is_self
      alias_property :comments_count, :num_comments

      def short_url
        "http://redd.it/" + self[:id]
      end

      def gilded?
        self[:gilded] > 0
      end
    end
  end
end
