module Lemo
  ILLEGAL_IVAR_CHARS = '?!'.freeze

  module MemoedMethods
    # the set of methods memoed so far that we know about.
    def _memoed_methods
      methods = {}

      if self.class.respond_to?(:memoed_methods)
        methods.merge! self.class.memoed_methods
      end

      if singleton_methods.size > 0 && singleton_class.respond_to?(:memoed_methods)
        methods.merge! singleton_class.memoed_methods
      end

      methods
    end

    # Reset some or all memoized variables.
    # Return cleared value(s)
    # Has to do quite a lot of meta-work, so don't put this in fast-path code.
    def _clear_memos( *requested_meths )
      # construct set of memoed methods to clear
      requested_meths =
      if requested_meths.empty?
        _memoed_methods.keys
      else
        # only clear ivars that actually make sense
        _memoed_methods.keys & requested_meths
      end

      # clear set of memos and keep their values
      memoed_values = requested_meths.map do |meth|
        if instance_variable_defined?( ivar = _memoed_methods[meth].owner.ivar_from(meth) )
          remove_instance_variable(ivar)
        end
      end

      # return nil, the first value, or all values
      (0..1) === memoed_values.size ? memoed_values.first : memoed_values
    end
  end
end
