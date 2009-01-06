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
  
  class AuthorisationBasedOnIssueWithCurrentIqGitTest < Test::Unit::TestCase
    def test_should_work
      authenticator = IQ::ACL::Basic.new({
        "projects/thelucid.com" => { 
          "miguel" => nil,
          "andy" => nil
        }, 
        "projects" => {
          "miguel" => "rw",
          "andy" => "rw"
        }, 
        "gems" => {
          "miguel" => "r",
          "andy" => "rw"
        }, 
        "projects/rails-site.com" => {
          "rails_site" => "rw",
          "andy" => "rw"
        }, 
        "*" => {
          "jamie"=>"rw"
        }
      })
      assert(authenticator.authorize!('rails_site', 'projects/rails-site.com') do |rights|
        rights.include?('r')
      end)
    end
  end

end