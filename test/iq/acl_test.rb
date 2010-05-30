require File.join(File.dirname(__FILE__), '..', 'helper')

class IQ::ACLTest < Test::Unit::TestCase
  context "initialize" do
    should "raise when argument is not a hash" do
      assert_raise(ArgumentError) { IQ::ACL::Basic.new('not a hash') }
    end

    should "store supplied hash in instance variable" do
      assert_equal(
        { 'the' => 'permissions' }, IQ::ACL::Basic.new('the' => 'permissions').instance_variable_get('@permissions')
      )
    end
  end
  
  context "authorize!" do
    should "respond" do
      assert_respond_to IQ::ACL::Basic.new({}), :authorize!
    end

    should "accept username as first argument" do
      instance = IQ::ACL::Basic.new('the/path' => { 'the user' => true })
      assert_nothing_raised(ArgumentError) { instance.authorize!('the user', 'the/path') }
    end

    should "accept path as second argument" do
      instance = IQ::ACL::Basic.new('the/path' => { 'the user' => true })
      assert_nothing_raised(ArgumentError) { instance.authorize!('the user', 'the/path') }
    end

    should "raise when path is not a string" do
      assert_raise(ArgumentError) { IQ::ACL::Basic.new({}).authorize!('the user', :not_a_string) }
    end

    should "raise access denied error when no match" do
      assert_raise(IQ::ACL::AccessDeniedError) { IQ::ACL::Basic.new({}).authorize!('the user', 'will/not/match') }
    end
    
    should "raise when user access explicitly set to nil for given path even when a parent privilege set" do
      instance = IQ::ACL::Basic.new('the' => { 'the user' => 'ok' }, 'the/path' => { 'the user' => nil })
      assert_raise(IQ::ACL::AccessDeniedError) { instance.authorize!('the user', 'the/path') }
    end
    
    should "raise when user access explicitly set to nil for given path even when root global set" do
      instance = IQ::ACL::Basic.new('*' => { 'the user' => 'ok' }, 'the/path' => { 'the user' => nil })
      assert_raise(IQ::ACL::AccessDeniedError) { instance.authorize!('the user', 'the/path') }
    end
    
    should "raise when user access not known but global set to nil for given path even when parent privilege set" do
      instance = IQ::ACL::Basic.new('the' => { 'the user' => 'ok' }, 'the/path' => { 'the user' => nil })
      assert_raise(IQ::ACL::AccessDeniedError) { instance.authorize!('the user', 'the/path') }
    end
    
    should "raise when user access not known but global set to nil for given path even when root global set" do
      instance = IQ::ACL::Basic.new('*' => { 'the user' => 'ok' }, 'the/path' => { '*' => nil })
      assert_raise(IQ::ACL::AccessDeniedError) { instance.authorize!('the user', 'the/path') }
    end

    should "return result of direct match in permissions hash with path and user when available" do
      instance = IQ::ACL::Basic.new('the/path' => { 'the user' => 'the access' })
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end
    
    should "return result of direct match in permissions hash with path and user when available special case" do
      instance = IQ::ACL::Basic.new('projects/rails-site.com' => { 'rails_site' => 'rw' })
      assert_equal 'rw', instance.authorize!('rails_site', 'projects/rails-site.com')
    end

    should "return result of direct match in permissions hash with path and star user when user not found" do
      instance = IQ::ACL::Basic.new('the/path' => { '*' => 'the access' })
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    should "return result of parent match in permissions hash with path and user over global user when no match" do
      instance = IQ::ACL::Basic.new('the' => { 'the user' => 'the access', '*' => 'global access' })
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    should "return result of parent match in permissions hash with path and star user when user not found" do
      instance = IQ::ACL::Basic.new('the' => { '*' => 'the access' })
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    should "continue down permissions tree until a match with path and user is found over global access" do
      instance = IQ::ACL::Basic.new('the/long' => { 'the user' => 'the access', '*' => 'global access' })
      assert_equal 'the access', instance.authorize!('the user', 'the/long/big/nested/path')
    end

    should "continue down permissions tree until a match with path and star user when user not found" do
      instance = IQ::ACL::Basic.new('the/long' => { '*' => 'the access' })
      assert_equal 'the access', instance.authorize!('the user', 'the/long/big/nested/path')
    end

    should "return result of user in star entry of permissions hash over star user when no other matches" do
      instance = IQ::ACL::Basic.new('*' => { 'the user' => 'the access', '*' => 'global access' }, 'other/path' => {})
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    should "return result of star user in star entry of permissions hash when no user match" do
      instance = IQ::ACL::Basic.new('*' => { '*' => 'the access' }, 'other/path' => {})
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end
    
    context "using a block" do
      should "yield the user rights when block given" do
        instance = IQ::ACL::Basic.new('the/path' => { 'the user' => 'the access' })
        the_rights = nil
        instance.authorize!('the user', 'the/path') do |rights|
          the_rights = rights
          true
        end
        assert_equal 'the access', the_rights
      end
    
      should "raise access denied error if block evaluates to false" do
        instance = IQ::ACL::Basic.new('the/path' => { 'the user' => 'the access' })

        assert_raise(IQ::ACL::AccessDeniedError) do
          instance.authorize!('the user', 'the/path') do |rights|
            false
          end
        end
      end
    
      should "raise access denied error if block evaluates to anything other than true" do
        instance = IQ::ACL::Basic.new('the/path' => { 'the user' => 'the access' })

        assert_raise(IQ::ACL::AccessDeniedError) do
          instance.authorize!('the user', 'the/path') do |rights|
            'not true'
          end
        end
      end
    
      should "not raise access denied error when block evaluates to true" do
        instance = IQ::ACL::Basic.new('the/path' => { 'the user' => 'the access' })

        assert_nothing_raised(IQ::ACL::AccessDeniedError) do
          instance.authorize!('the user', 'the/path') do |rights|
            true
          end
        end
      end
    end
  end
end
