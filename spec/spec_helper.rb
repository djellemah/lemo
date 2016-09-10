require 'rspec'

# turn off the "old syntax" warnings
RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  # to get coverage output in ./coverage/index.html say
  #
  #   rspec -t cov
  #
  # otherwise spec run ignores coverage
  if config.filter[:cov]
    config.filter.delete :cov

    # turn on test coverage
    require 'simplecov'
    # and output for sublime higlighting
    require 'simplecov-json'

    SimpleCov.start do
      add_filter '/spec/'
    end

    SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
  end
end

shared_examples_for "Lemonised" do |*methods|
  methods.each do |meth|
    describe meth do
      it "keeps a value for #{meth}" do
        fst = subject.send(meth)

        # Yes, twice
        subject.send(meth).should == fst
        subject.send(meth).should == fst
      end

      it "clear value for #{meth} and return single value" do
        fst = subject.send(meth)
        subject._clear_memos(meth).should == fst
        subject.send(meth).should_not == fst
      end

      it 'handles clear of nonexistent memo' do
        subject.send(meth)
        nonsense = subject._clear_memos :nonsense
        nonsense.should be_nil
      end
    end
  end

  it 'list of memoed methods' do
    methods.each{|meth| subject.send meth}
    subject._memoed_methods.keys.should == methods
  end

  it 'clear all values and return array' do
    values = methods.map{|meth| subject.send meth}
    if values.size > 1
      subject._clear_memos.should == values
    else
      subject._clear_memos.should == values.first
    end
  end
end

