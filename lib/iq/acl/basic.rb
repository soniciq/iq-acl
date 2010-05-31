# This class provides a really simple way of handling access control. By simply
# supplying a hash of paths with user privileges for each of them, a powerful
# ACL system can be created. Wildcards (in this case asterisks) can be used to
# denote global rules.
# 
# @example
#   # Create an instance of the basic class, supplying rights as a hash, note
#   # that asterisks are used as wildcards.
#   auth = IQ::ACL::Basic.new({
#     '*'                 => { 'terry' => 'r' },
#     'projects'          => { 'jonny' => 'rw' },
#     'projects/private'  => { 'billy' => 'rw', 'terry' => nil },
#     'projects/public'   => { 'terry' => 'rw', '*' => 'r' }
#   })
#   
#   # You could alternatively read rights from a YAML file.
#   auth = IQ::ACL::Basic.new(YAML.load_file('rights.yml'))
# 
#   auth.authorize! 'guest', 'projects'         #=> raises IQ::ACL::AccessDeniedError
#   auth.authorize! 'jonny', 'projects'         #=> 'rw'
#   auth.authorize! 'billy', 'projects'         #=> raises IQ::ACL::AccessDeniedError
#   auth.authorize! 'terry', 'projects'         #=> 'r'
#   auth.authorize! 'guest', 'projects/private' #=> raises IQ::ACL::AccessDeniedError
#   auth.authorize! 'jonny', 'projects/private' #=> 'rw'
#   auth.authorize! 'billy', 'projects/private' #=> 'rw'
#   auth.authorize! 'terry', 'projects/private' #=> raises IQ::ACL::AccessDeniedError
#   auth.authorize! 'guest', 'projects/public'  #=> 'r'
#   auth.authorize! 'jonny', 'projects/public'  #=> 'r'
#   auth.authorize! 'billy', 'projects/public'  #=> 'r'
#   auth.authorize! 'terry', 'projects/public'  #=> 'rw
# 
#   # A block may be given to authorize! that should return true if the yielded
#   # rights are adequate for the user, for example the following will raise an
#   # IQ::ACL::AccessDeniedError as 'terry' does not have write access to the
#   # 'projects' path. If 'terry' had write access to the 'projects' path, the
#   # exception would not be thrown.
# 
#   auth.authorize! 'terry', 'projects' do |rights|
#     rights.include?('w')
#   end
#
class IQ::ACL::Basic
  
  # Returns a new instance to be authenticated against.
  # 
  # @param [Hash]
  def initialize(permissions)
    raise ArgumentError, 'Must supply permissions as a hash' unless permissions.is_a?(Hash)
    @permissions = permissions
  end
  
  # Returns the rights that a user has for a given path. When the user has no
  # access to the given path, an IQ::ACL::AccessDeniedError is raised. When a
  # block is given the user rights are yielded as the block parameter and the
  # block is expected to return true when the rights are sufficient.
  # 
  # @param [String] user
  # @param [String] path
  # 
  # @return [String] the right for the given user
  def authorize!(user, path)
    raise ArgumentError, 'Path must be a string' unless path.is_a?(String)
    
    segments = path.split('/')
    rights = until segments.empty?
      if rights = permissions[segments.join('/')]
        access = rights[user] || rights['*']
        access_denied! if (rights.has_key?(user) || rights.has_key?('*')) && access.nil?
        break access if access
      end
      segments.pop
    end || (global = permissions['*']) && (global[user] || global['*']) || access_denied!
    
    access_denied! if block_given? && (yield(rights) != true)
    rights
  end

  private
  
  attr_reader :permissions
  
  def access_denied!
    raise IQ::ACL::AccessDeniedError, 'User does not have access to path'
  end
end