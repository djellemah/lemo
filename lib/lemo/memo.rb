# Copyright John Anderson 2015-2016

require_relative 'memoed_methods'

module Lemo
  module Memo
    include MemoedMethods

    module ClassMethods
      def memoed_methods
        @memoed_methods ||= {}
      end

      # provide a legal ivar name from a method name. instance variables
      # can't have ? ! and other punctuation. Which isn't handled. Obviously.
      def ivar_from( maybe_meth )
        :"@_memo_#{maybe_meth.to_s.tr ILLEGAL_IVAR_CHARS,'pi'}"
      end

      def lemo( meth )
        unbound_previous_method = instance_method meth

        # still doesn't prevent memoisation of methods with an implicit block
        unless unbound_previous_method.parameters.empty?
          raise ArgumentError, "can't memo #{meth} with parameters"
        end

        memoed_methods[meth] = unbound_previous_method
        ivar = ivar_from meth

        remove_method meth if $VERBOSE
        define_method meth do
          # This gets executed on every call to meth, so make it fast.
          if instance_variable_defined? ivar
            instance_variable_get ivar
          else
            # bind the saved method to this instance, call the result ...
            to_memo = unbound_previous_method.bind( self ).call
            # ... memo it and return value
            instance_variable_set ivar, to_memo
          end
        end

        meth
      end

      # for all the things using memo already
      alias memo lemo
    end

    # hook in class methods on include
    def self.included( other_module )
      other_module.extend ClassMethods
    end
  end
end
