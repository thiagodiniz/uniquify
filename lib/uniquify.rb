module Uniquify
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def uniquify(*args, &block)
      options = { :length => 15 }
      options.merge!(args.pop) if args.last.kind_of? Hash

      class_inheritable_reader(:uniquify_options)
      write_inheritable_attribute(:uniquify_options, options)

      args.each do |name|
        before_validation :on => :create do |record|
          if block
            record.ensure_unique(name, &block)
          else
            record.ensure_unique(name)
          end
        end
      end
    end

    def generate_unique
        SecureRandom.base64(uniquify_options[:length]).tr('+/=lIO0', 'pqrsxyz')
    end
  end

  def ensure_unique(name, &block)
    begin
      self[name] = (block ? block.call : self.class.generate_unique)
    end while self.class.exists?(name => self[name])

    self[name]
  end
end

class ActiveRecord::Base
  include Uniquify
end
