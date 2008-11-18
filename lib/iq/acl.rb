module IQ # :nodoc:
  module ACL # :nodoc:
    def self.version
      VERSION::STRING
    end

    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 9
      TINY  = 3

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
    
    autoload :Basic, File.join(File.dirname(__FILE__), 'acl', 'basic')
    
    # This error is raised when a user does not have access to a supplied path.
    class AccessDeniedError < StandardError
    end
  end
end
