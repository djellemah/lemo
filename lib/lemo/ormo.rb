# Copyright John Anderson 2015-2016

require_relative 'memoed_methods'

module Lemo
  # simple replacement for ||= (y'know or-or-equals)
  # in others words stores values as plain old @name, and nil means same as does-not-exist
  module Ormo
    include MemoedMethods

    module ClassMethods
      def memoed_methods
        @memoed_methods ||= {}
      end

      # provide a legal ivar name from a method name. instance variables
      # can't have ? ! and other punctuation. Which isn't handled. Obviously.
      # WARNING meth, meth? and meth! will access the same ivar.
      def ivar_from( meth )
        :"@#{meth.to_s.delete ILLEGAL_IVAR_CHARS}"
      end

      # WARNING race condition if two threads concurrently define the same
      # memo'ed method on the same class. Unlikely, but still.
      def ormo( meth )
        unbound_previous_method = instance_method meth

        # still doesn't prevent memoisation of methods with an implicit block
        unless unbound_previous_method.parameters.empty?
          raise ArgumentError, "can't memo #{meth} with parameters"
        end

        # keep this for initial calculation, and recalculation
        memoed_methods[meth] = unbound_previous_method
        ivar = ivar_from meth

        # Define the class using instance variable @ syntax, for fastest
        # runtime. Use class_eval to define an instance method, cos self is the
        # class (or singleton class) right now
        class_eval <<-RUBY, __FILE__, __LINE__
          undef #{meth} if $VERBOSE # only to avoid warnings during -w
          def #{meth}
            #{ivar} ||= _memoed_methods[:#{meth}].bind(self).call
          end
        RUBY

        # allow chaining of symbol returned from def
        meth
      end

      # for all the things using memo already
      alias memo ormo
    end

    # hook in class methods on include
    def self.included( other_module )
      other_module.extend ClassMethods
    end
  end
end
