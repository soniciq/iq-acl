require File.join(File.dirname(__FILE__), 'unit_test_helper')

module IQ::Tests::ACL::Unit::Basic
  Factory = IQ::Tests::ACL::Factory

  # ----------------------------------------------------------------------------------------------------
  # Instance Methods
  # ----------------------------------------------------------------------------------------------------

  # initialize
  # ----------
  class InitializeTest < Test::Unit::TestCase
    def test_should_accept_hash
      assert_nothing_raised(ArgumentError) { Factory.new_basic({}) }
    end

    def test_should_raise_when_argument_is_not_a_hash
      assert_raise(ArgumentError) { Factory.new_basic('not a hash') }
    end

    def test_should_store_supplied_hash_in_permissions_instance_variable
      assert_equal(
        { 'the' => 'permissions' }, Factory.new_basic('the' => 'permissions').instance_variable_get('@permissions')
      )
    end
  end
  
  # authorize!
  # ----------
  class AuthorizeBangTest < Test::Unit::TestCase
    def test_should_respond
      assert_respond_to Factory.new_basic({}), :authorize!
    end

    def test_should_accept_username_as_first_argument
      instance = Factory.new_basic({})
      instance.instance_variable_set '@permissions', { 'the/path' => { 'the user' => true } }
      assert_nothing_raised(ArgumentError) { instance.authorize!('the user', 'the/path') }
    end

    def test_should_accept_path_as_second_argument
      instance = Factory.new_basic({})
      instance.instance_variable_set '@permissions', { 'the/path' => { 'the user' => true } }
      assert_nothing_raised(ArgumentError) { instance.authorize!('the user', 'the/path') }
    end

    def test_should_raise_when_path_is_not_a_string
      assert_raise(ArgumentError) { Factory.new_basic({}).authorize!('the user', :not_a_string) }
    end

    def test_should_raise_access_denied_error_when_no_match
      assert_raise(IQ::ACL::AccessDeniedError) { Factory.new_basic({}).authorize!('the user', 'will/not/match') }
    end

    def test_should_return_result_of_direct_match_in_permissions_hash_with_path_and_user_when_available
      instance = Factory.new_basic({})
      instance.instance_variable_set '@permissions', { 'the/path' => { 'the user' => 'the access' } }
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    def test_should_return_result_of_direct_match_in_permissions_hash_with_path_and_star_user_when_user_not_found
      instance = Factory.new_basic({})
      instance.instance_variable_set '@permissions', { 'the/path' => { '*' => 'the access' } }
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    def test_should_return_result_of_parent_match_in_permissions_hash_with_path_and_user_over_global_user_when_no_match
      instance = Factory.new_basic({})
      instance.instance_variable_set(
        '@permissions', { 'the' => { 'the user' => 'the access', '*' => 'global access' } }
      )
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    def test_should_return_result_of_parent_match_in_permissions_hash_with_path_and_star_user_when_user_not_found
      instance = Factory.new_basic({})
      instance.instance_variable_set '@permissions', { 'the' => { '*' => 'the access' } }
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    def test_should_continue_down_permissions_tree_until_a_match_with_path_and_user_is_found_over_global_access
      instance = Factory.new_basic({})
      instance.instance_variable_set(
        '@permissions', { 'the/long' => { 'the user' => 'the access', '*' => 'global access' } }
      )
      assert_equal 'the access', instance.authorize!('the user', 'the/long/big/nested/path')
    end

    def test_should_continue_down_permissions_tree_until_a_match_with_path_and_star_user_when_user_not_found
      instance = Factory.new_basic({})
      instance.instance_variable_set '@permissions', { 'the/long' => { '*' => 'the access' } }
      assert_equal 'the access', instance.authorize!('the user', 'the/long/big/nested/path')
    end

    def test_should_return_result_of_user_in_star_entry_of_permissions_hash_over_star_user_when_no_other_matches
      instance = Factory.new_basic({})
      instance.instance_variable_set(
        '@permissions', { '*' => { 'the user' => 'the access', '*' => 'global access' }, 'other/path' => {} }
      )
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end

    def test_should_return_result_of_star_user_in_star_entry_of_permissions_hash_when_no_user_match
      instance = Factory.new_basic({})
      instance.instance_variable_set '@permissions', { '*' => { '*' => 'the access' }, 'other/path' => {} }
      assert_equal 'the access', instance.authorize!('the user', 'the/path')
    end
  end

end