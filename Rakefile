require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require 'rake/gempackagetask'

desc 'Default: run unit tests.'
task :default => 'test:unit'

spec = Gem::Specification.new do |s|
  s.name = 'iq-acl'
  s.version = '0.9.2'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.rdoc_options += ['--title', 'IQ::ACL', '--main', 'README', '--inline-source', '--line-numbers']
  s.extra_rdoc_files = ['README', 'MIT-LICENSE']
  s.summary = 'A series of classes for implementing access control lists.'
  s.description = 'This aim of this gem is to provide a series of classes to handle common ACL requirements.'
  s.author = 'Jamie Hill, SonicIQ Ltd'
  s.email = 'jamie@thelucid.com'
  s.homepage = 'http://code.soniciq.com/iq/acl'
  s.require_path = 'lib'
  s.files = %w(README Rakefile MIT-LICENSE) + Dir.glob('{test,lib,rails}/**/*')
end

Rake::GemPackageTask.new(spec) do |pkg|
#  pkg.need_zip = true
#  pkg.need_tar = true
end

namespace :test do
  desc 'Run unit tests for gem.'
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'lib'
    t.pattern = 'test/iq/tests/acl/unit/**/*_test.rb'
    t.verbose = true
  end
  
  desc 'Run functional tests for gem.'
  Rake::TestTask.new(:functional) do |t|
    t.libs << 'lib'
    t.pattern = 'test/iq/tests/acl/functional/**/*_test.rb'
    t.verbose = true
  end

  namespace :unit do
    desc 'Monitor and run unit tests'
    task :auto do
      stakeout(
        'rake test:unit', %w(
          test/iq/tests/acl/test_helper.rb
          test/iq/tests/acl/unit/unit_test_helper.rb
          test/iq/tests/acl/factory.rb
          test/iq/tests/acl/unit/**/*_test.rb
          lib/iq/acl/**/*.rb
        )
      )
    end
  end

  namespace :functional do
    desc 'Monitor and run functional tests'
    task :auto do
      stakeout(
        'rake test:functional', %w(
          test/iq/tests/acl/test_helper.rb
          test/iq/tests/acl/functional/functional_test_helper.rb
          test/iq/tests/acl/factory.rb
          test/iq/tests/acl/functional/**/*_test.rb
          lib/iq/acl/**/*.rb
        )
      )
    end
  end
  
  def growl(title, msg, img, pri=0, sticky="")
    system "growlnotify -n autotest --image ~/.autotest_images/#{img} -p #{pri} -m #{msg.inspect} #{title} #{sticky}"
  end

  def growl_fail(output)
    growl "FAIL", "#{output}", "fail.png", 2
  end

  def growl_pass(output)
    growl "Pass", "#{output}", "pass.png"
  end

  def stakeout(command, dir_globs)
    # Originally by Mike Clark.
    # http://www.pragmaticautomation.com/cgi-bin/pragauto.cgi/Monitor/StakingOutFileChanges.rdoc
    files = dir_globs.inject({}) { |hash, arg| Dir[arg].each { |file| hash[file] = File.mtime(file) } ; hash }
    trap('INT') { puts "\nQuitting..." ; exit }

    run_command(command)
    loop do
      changed_file, last_changed = files.find { |file, last_changed| File.mtime(file) > last_changed }
      if changed_file
        files[changed_file] = File.mtime(changed_file)
        puts "=> #{changed_file} changed, running #{command}"
        run_command(command)
      end
      sleep 1
    end
  end
  
  def run_command(command)
    puts (results = `#{command}`)
    
    if results.include? 'tests'
      output = results.slice(/(\d+)\s+tests?,\s*(\d+)\s+assertions?,\s*(\d+)\s+failures?(,\s*(\d+)\s+errors)?/)
      ($~[3].to_i + $~[5].to_i > 0 ? growl_fail(output) : growl_pass(output)) if output
    elsif results.include? 'specs'
      output = results.slice(/(\d+)\s+examples?,\s*(\d+)\s+failures?(,\s*(\d+)\s+not implemented)?/)
      ($~[2].to_i > 0 ? growl_fail(output) : growl_pass(output)) if output
    end
  end
end

namespace :cov do
  desc 'Output unit test coverage of gem.'
  Rcov::RcovTask.new(:unit) do |rcov|
    rcov.pattern    = 'test/iq/tests/acl/unit/**/*_test.rb'
    rcov.output_dir = 'cov'
    rcov.verbose    = true
  end
  
  desc 'Output functional test coverage of gem.'
  Rcov::RcovTask.new(:functional) do |rcov|
    rcov.pattern    = 'test/iq/tests/acl/functional/**/*_test.rb'
    rcov.output_dir = 'cov'
    rcov.verbose    = true
  end
end

desc 'Generate documentation for the gem.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'IQ::ACL'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README', 'MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end