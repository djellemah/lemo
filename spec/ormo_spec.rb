require_relative 'spec_helper'
require_relative '../lib/lemo/ormo.rb'

describe Lemo::Ormo do
  class self::Holder
    include Lemo::Ormo
    memo def value; rand( -10000..10000 ) end
    memo def other; rand( -10000..10000 ) end
    def plain; rand( -10000..10000 ) end
  end

  subject{ self.class::Holder.new }

  it_behaves_like 'Lemonised', :value, :other

  describe 'nil' do
    # has to be self:: otherwise other example groups that also defined Dynamic get confused.
    class self::Dynamic
      include Lemo::Ormo
      def other_method; end
      memo def tork; other_method end
    end

    subject{ self.class::Dynamic.new }

    it 'calculates first' do
      subject.should_receive(:other_method).and_call_original
      subject.tork.should be_nil
    end

    it 'nil means not Lemonised' do
      subject.should_receive(:other_method).at_least(:once).and_call_original
      subject.tork.should be_nil

      # yes, twice
      subject.tork.should be_nil
      subject.tork.should be_nil
    end
  end

  describe 'extended singleton' do
    subject do
      inst = self.class::Holder.new

      def inst.sother; rand end
      inst.singleton_class.memo :sother

      inst
    end

    it_behaves_like 'Lemonised', :value, :other, :sother
  end

  describe 'singleton' do
    subject do
      obj = Object.new
      def obj.value; rand end
      obj.singleton_class.include(Lemo::Ormo).memo :value
      obj
    end

    it_behaves_like 'Lemonised', :value
  end

  describe 'disallows methods' do
    it 'with arguments' do
      illegal_memo = lambda do
        Class.new do
          include Lemo::Ormo

          memo def thing( *args )
            args.map{rand}
          end
        end
      end

      illegal_memo.should raise_error(ArgumentError, /with parameters/)
    end

    it 'with explicit blocks' do
      illegal_memo = lambda do
        Class.new do
          include Lemo::Ormo

          memo def thing( &blk )
            args.map{rand}
          end
        end
      end

      illegal_memo.should raise_error(ArgumentError, /with parameters/)
    end

    it 'with keywords' do
      illegal_memo = lambda do
        Class.new do
          include Lemo::Ormo

          memo def thing( first:, opt: nil )
            args.map{rand}
          end
        end
      end

      illegal_memo.should raise_error(ArgumentError, /with parameters/)
    end
  end
end
