ENV["RAILS_ENV"] = 'test'

# Path to root of plugin dir
$:.unshift(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'lib'))

# Bits used for testing
require 'test/unit'
require 'rubygems'
require 'redgreen'

# Load gem for testing
require 'iq/acl'

module IQ # :nodoc:
  module Tests # :nodoc:
    module ACL # :nodoc:
      autoload :Factory, File.join(File.dirname(__FILE__), 'factory')
    end
  end
end

# Stop depreciation warnings in test output
Object.send(:undef_method, :id)   if Object.respond_to?(:id)
Object.send(:undef_method, :type) if Object.respond_to?(:type)

class Test::Unit::TestCase
  def with_controller(controller)
    @controller   = controller.new
    @request      = ActionController::TestRequest.new
    @response     = ActionController::TestResponse.new
    yield @controller, @request, @response
    @controller, @request, @response = nil
  end
  
  def assert_private_method(subject, method, message = "#{method} should be a private method")
    assert subject.private_methods.include?(method.to_s), message
  end
  
  def assert_protected_method(subject, method, message = "#{method} should be a protected method")
    assert subject.protected_methods.include?(method.to_s), message
  end
end