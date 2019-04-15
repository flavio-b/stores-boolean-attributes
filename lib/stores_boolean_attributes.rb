require "stores_boolean_attributes/version"
require 'active_support/concern'

module StoresBooleanAttributes
  extend ActiveSupport::Concern

  included do
    class << self
      def define_query_methods_for(*accessors)
        accessors.each do |accessor|
          define_method("#{accessor}?") do
            query_store_accessor(accessor)
          end
        end
      end
    end
  end

  private

  # Modified version of query_attribute to work with store_accessors.
  def query_store_accessor(accessor_name)
    value = send(accessor_name)

    case value
    when true        then true
    when false, nil  then false
    else
      column = self.class.columns_hash[accessor_name]
      if column.nil?
        if Numeric === value || value !~ /[^0-9]/
          !value.to_i.zero?
        else
          return false if ActiveModel::Type::Boolean::FALSE_VALUES.include?(value)
          !value.blank?
        end
      elsif value.respond_to?(:zero?)
        !value.zero?
      else
        !value.blank?
      end
    end
  end
end
