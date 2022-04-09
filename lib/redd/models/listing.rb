# frozen_string_literal: true

require_relative 'basic_model'

module Redd
  module Models
    # A backward-expading listing of items.
    # @see Stream
    class Listing < BasicModel
      include Enumerable

      # @return [Array<Comment, Submission, PrivateMessage>] an array representation of self
      def to_ary() = @attributes.fetch(:children)

      def [](index) = @attributes.fetch(:children)[index]

      def each(&) = @attributes.fetch(:children).each(&)

      def empty?() = @attributes.fetch(:children).empty?

      def first(amount = nil) = @attributes.fetch(:children).first(amount)

      def last(amount = nil) = @attributes.fetch(:children).last(amount)
    end
  end
end
