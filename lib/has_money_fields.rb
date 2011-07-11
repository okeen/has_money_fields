require 'active_record'
require 'money'

module HasMoneyFields
  module ClassMethods
    def has_money_fields *args
      options = args.extract_options!
      options.symbolize_keys!
      options.assert_valid_keys(:only_cents)

      args.each do |attr|
        constructor = Proc.new do |cents, currency|
          Money.new(cents || 0, currency || Money.default_currency)
        end

        converter = Proc.new do |value|
          if value.respond_to? :to_money
            value.to_money
          else
            raise(ArgumentError, "Can't convert #{value.class} to Money")
          end
        end

        if options[:only_cents]
          mapping = [["money_#{attr.to_s}", "cents"]]
        else
          mapping = [["money_#{attr.to_s}", "cents"], ["currency_#{attr.to_s}", "currency_as_string"]]
        end

        self.composed_of attr,
          :class_name => "Money",
          :mapping => mapping,
          :constructor => constructor,
          :converter => converter
      end
    end
  end
end

ActiveRecord::Base.send :extend, HasMoneyFields::ClassMethods
