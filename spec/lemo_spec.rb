require_relative 'spec_helper'
require_relative '../lib/lemo.rb'

describe Lemo do
  class Holder
    include Lemo::Memo
    memo def value; rand -10000..10000 end
    memo def other; rand -10000..10000 end
    def plain; rand -10000..10000 end
  end

  subject{ Holder.new }

  it_behaves_like 'Lemonised', :value, :other

  describe 'nil' do
    # has to be self:: otherwise other example groups that also defined Dynamic get confused.
    class self::Dynamic
      include Lemo::Memo
      def other_method; end
      memo def tork; other_method end
    end

    subject{ self.class::Dynamic.new }

    it 'calculates first' do
      subject.should_receive(:other_method).and_call_original
      subject.tork.should be_nil
    end

    it 'does not calculate subsequent' do
      subject.tork.should be_nil

      subject.should_not_receive(:other_method)

      # yes, twice
      subject.tork.should be_nil
      subject.tork.should be_nil
    end
  end

  describe 'extended singleton' do
    subject do
      inst = Holder.new

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
      obj.singleton_class.include(Lemo::Memo).memo :value
      obj
    end

    it_behaves_like 'Lemonised', :value
  end

  describe 'disallows methods' do
    it 'with arguments' do
      illegal_memo = lambda do
        class Thing
          include Lemo::Memo

          memo def thing( *args )
            args.map{rand}
          end
        end
      end

      illegal_memo.should raise_error(ArgumentError, /with parameters/)
    end

    it 'with explicit blocks' do
      illegal_memo = lambda do
        class Thing
          include Lemo::Memo

          memo def thing( &blk )
            args.map{rand}
          end
        end
      end

      illegal_memo.should raise_error(ArgumentError, /with parameters/)
    end

    it 'with keywords' do
      illegal_memo = lambda do
        class Thing
          include Lemo::Memo

          memo def thing( first:, opt: nil )
            args.map{rand}
          end
        end
      end

      illegal_memo.should raise_error(ArgumentError, /with parameters/)
    end
  end
end
