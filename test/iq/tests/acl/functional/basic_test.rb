require File.join(File.dirname(__FILE__), 'functional_test_helper')

module IQ::Tests::ACL::Functional::Basic
  Factory = IQ::Tests::ACL::Factory

  # ----------------------------------------------------------------------------------------------------
  # Class Methods
  # ----------------------------------------------------------------------------------------------------

  # self.the_method
  # ---------------
  class SelfTheMethodTest < Test::Unit::TestCase
    def test_should_do_something
      # Your assertion goes here
    end
  end

  # ----------------------------------------------------------------------------------------------------
  # Instance Methods
  # ----------------------------------------------------------------------------------------------------

  # the_method
  # ----------
  class TheMethodTest < Test::Unit::TestCase
    def test_should_do_something
      # Your assertion goes here
    end
  end

end