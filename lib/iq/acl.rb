module IQ # :nodoc:
  module ACL # :nodoc:
    def self.version
      VERSION::STRING
    end

    module VERSION #:nodoc:
      MAJOR = 1
      MINOR = 0
      TINY  = 1

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
    
    autoload :Basic, File.join(File.dirname(__FILE__), 'acl', 'basic')
    
    # This error is raised when a user does not have access to a supplied path.
    class AccessDeniedError < StandardError
    end
  end
end
