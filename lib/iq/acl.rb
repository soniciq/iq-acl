module IQ # :nodoc:
  module ACL # :nodoc:
    autoload :Basic, File.join(File.dirname(__FILE__), 'acl', 'basic')
    
    # This error is raised when a user does not have access to a supplied path.
    class AccessDeniedError < StandardError
    end
  end
end
