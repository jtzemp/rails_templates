# a rails standard template for me.
# includes rspec, cucumber, webrat, fixjour, adds stuff to git and sets up .gitignores and a bunch of other stuffs

run "echo TODO > README"

gem "rspec", :lib => false, :version => ">= 1.2.9", :env => "test"
gem "rspec-rails", :lib => false, :version => ">= 1.2.9", :env => "test"
gem 'cucumber', :env => "test"
gem 'webrat', :env => "test"
gem 'fixjour', :env => "test"
gem 'faker', :env => "test"
gem 'ruby-debug', :env => "test"
gem 'ruby-debug', :env => "development"
gem 'nokogiri', :env => "test"


if yes?("Run gems:install for test environment?")
  rake "gems:install", :env => "test", :sudo => true
end

generate :rspec
generate :cucumber

#### Fixjour
# put fixjour in rspec
file "spec/fixjour_builders.rb", <<-END
require 'fixjour'
Fixjour do
  # http://github.com/nakajima/fixjour/tree/master
  # define_builder(Post) do |klass, overrides|
  #   klass.new(:name => 'a post', :body => 'texted')
  # end
end

END

file "spec/spec_helper.rb", <<-EOD
# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require File.expand_path(File.dirname(__FILE__) + "/fixjour_builders.rb")
require 'nokogiri'
require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.include(Fixjour)
  config.include(Webrat::Methods)
  
  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

EOD

# put fixjour in Cucumber
file "features/support/tmp", <<-END

require File.expand_path(File.dirname(__FILE__) +'/../../spec/fixjour_builders.rb')
World(Fixjour)

END
run "cat features/support/tmp >> features/support/env.rb"
run "rm features/support/tmp"

# initialize the git repo
git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"

run "rm -rf test/"

git :add => ".", :commit => "-m 'initial commit'"

# auth_template.rb
# load_template "/Users/rbates/code/base_template.rb"

# name = ask("What do you want a user to be called?")
# generate :nifty_authentication, name
# rake "db:migrate"

# git :add => ".", :commit => "-m 'adding authentication'"
if yes?("Do you want a home controller?")
  generate :controller, "home index"
  route "map.root :controller => 'home'"
  git :rm => "public/index.html"
  git :add => ".", :commit => "-m 'adding home controller'"
end

if yes?("Create databases?")
  rake "db:create:all"
end

################# testing
# puts "################### testing"
# rake "db:drop:all"
# rake "db:create:all"
# generate :rspec_scaffold, "thing"
# rake "db:migrate"
# rake "db:test:clone"
# rake "spec"