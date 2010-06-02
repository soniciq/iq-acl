# This class provides a really simple way of handling access control. By simply
# supplying a hash of paths with user privileges for each of them, a powerful
# ACL system can be created. Wildcards (in this case asterisks) can be used to
# denote global rules.
# 
# @example
#   # Create an instance of the basic class, supplying rights as a hash, note
#   # that asterisks are used as wildcards.
#   auth = IQ::ACL::Basic.new(
#     '*'                 => { 'terry' => 'r' },
#     'projects'          => { 'jonny' => 'rw' },
#     'projects/private'  => { 'billy' => 'rw', 'terry' => nil },
#     'projects/public'   => { 'terry' => 'rw', '*' => 'r' }
#   )
#   
#   # You could alternatively read rights from a YAML file.
#   auth = IQ::ACL::Basic.new(YAML.load_file('rights.yml'))
# 
#   auth.authenticate! 'guest', 'projects'         #=> raises IQ::ACL::AccessDeniedError
#   auth.authenticate! 'jonny', 'projects'         #=> 'rw'
#   auth.authenticate! 'billy', 'projects'         #=> raises IQ::ACL::AccessDeniedError
#   auth.authenticate! 'terry', 'projects'         #=> 'r'
#   auth.authenticate! 'guest', 'projects/private' #=> raises IQ::ACL::AccessDeniedError
#   auth.authenticate! 'jonny', 'projects/private' #=> 'rw'
#   auth.authenticate! 'billy', 'projects/private' #=> 'rw'
#   auth.authenticate! 'terry', 'projects/private' #=> raises IQ::ACL::AccessDeniedError
#   auth.authenticate! 'guest', 'projects/public'  #=> 'r'
#   auth.authenticate! 'jonny', 'projects/public'  #=> 'r'
#   auth.authenticate! 'billy', 'projects/public'  #=> 'r'
#   auth.authenticate! 'terry', 'projects/public'  #=> 'rw
# 
#   # A block may be given to authenticate! that should return true if the yielded
#   # rights are adequate for the user, for example the following will raise an
#   # IQ::ACL::AccessDeniedError as 'terry' does not have write access to the
#   # 'projects' path. If 'terry' had write access to the 'projects' path, the
#   # exception would not be thrown.
# 
#   auth.authenticate! 'terry', 'projects' do |rights|
#     rights.include?('w')
#   end
# 
#   # In the previous examples, strings are used to identify the user, however
#   # user may be any object. This becomes quite powerful as you could use the
#   # objects returned from an ORM such as ActiveRecord. Also the rights in the
#   # previous examples were strings, however these may be of any type also,
#   # again allowing powerful solutions to be built e.g.
# 
#   user = User.find_by_email('jamie@example.com')
#   auth = IQ::ACL::Basic.new('projects/*' => { user => user.roles })
# 
#   auth.authenticate!(user, 'projects/some-project') do |roles|
#     roles.find_by_name('project_editor')
#   end
#
class IQ::ACL::Basic
  
  # Returns a new instance to be authenticated against.
  # 
  # @param [Hash] permissions
  def initialize(permissions)
    raise ArgumentError, 'Must supply permissions as a hash' unless permissions.is_a?(Hash)
    @permissions = permissions
  end

  # Returns the rights that a user has for a given path. When the user has no
  # access to the given path, nil is returned.
  # 
  # When a block is supplied the user rights are yielded as the block parameter
  # and the block is expected to return true when the rights are sufficient.
  # 
  # @param [Object] user
  # @param [String] path
  # 
  # @return [nil, Object] the rights that the given user has to the path.
  def authenticate(user, path)
    raise ArgumentError, 'Path must be a string' unless path.is_a?(String)
    
    segments = path.split('/')
    rights = until segments.empty?
      if rights = permissions[segments.join('/')]
        access = rights[user] || rights['*']
        return nil if (rights.has_key?(user) || rights.has_key?('*')) && access.nil?
        break access if access
      end
      segments.pop
    end || (global = permissions['*']) && (global[user] || global['*']) || nil
    
    return nil if block_given? && (yield(rights) != true)
    rights
  end
  
  # Returns the rights that a user has for a given path. When the user has no
  # access to the given path, an IQ::ACL::AccessDeniedError is raised.
  # When a block is supplied the user rights are yielded as the block parameter
  # and the block is expected to return true when the rights are sufficient.
  # 
  # @param [Object] user
  # @param [String] path
  # 
  # @raise [IQ::ACL::AccessDeniedError] when result of block is not true.
  # @return [Object] the rights that the given user has to the path.
  def authenticate!(user, path, &block)
    authenticate(user, path, &block) || raise(IQ::ACL::AccessDeniedError, 'User does not have access to path')
  end

  private
  
  attr_reader :permissions

end