require 'rake/testtask'
require 'rubygems'
require 'rubygems/package_task'

task :default => [:test]

Rake::TestTask.new do |test|
    test.libs << "test"
    test.test_files = Dir[ "test/test_*.rb" ]
    test.verbose = true
end

gem_spec = Gem::Specification.new do |s|
    s.name = 'idcbatch'
    s.version = '0.1.2'
    s.add_dependency('net-ldap')
    s.add_dependency('rest-client')
    s.authors = ['Lars Tobias Skjong-Børsting']
    s.date = '2011-01-01'
    s.description = 'HR Identity Control Batch Scripts'
    s.email = 'larstobi@conduct.no'
    s.files = ['Rakefile',
        'bin/email.rb',
        'bin/resignation.rb',
        'bin/namechange.rb',
        'lib/idcbatch.rb',
        'lib/idcbatch/ad/connection.rb',
        'lib/idcbatch/ad/person.rb',
        'lib/idcbatch/ad.rb',
        'lib/idcbatch/file_extensions.rb',
        'lib/idcbatch/hrsys/connection.rb',
        'lib/idcbatch/hrsys/person.rb',
        'lib/idcbatch/hrsys/person_parser.rb',
        'lib/idcbatch/hrsys/string_extensions.rb',
        'lib/idcbatch/hrsys.rb',
        'lib/idcbatch/read_config.rb']
    s.has_rdoc = false
    s.homepage = 'http://github.com/larstobi/hr-idc'
    s.require_paths = ['lib']
    s.summary = 'Batch scripts to syncronize person data between a HR system and Active Directory.'
end

Gem::PackageTask.new(gem_spec) do |t|
    t.need_zip = true
    t.need_tar = true
end
