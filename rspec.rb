# ==============================================================================
# Templage for generate a Rails applciation with RSpec and other gems
# like Haml, Bootstrap, devise...
# ==============================================================================
#
# Usage:
# ------
#
#     $ rails new appname -T -m https://raw.githubusercontent.com/VictorRO/rails-template/master/rspec.rb
#
# ==============================================================================

git :init
git add:    "."
git commit: "-m 'Initial commit: Clean application'"

# ----- Add gems into Gemfile --------------------------------------------------

puts
say_status  'Rubygems', 'Adding RSpec + other libraries into Gemfile...', :yellow
puts        '-'*80, ''; sleep 0.75

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
end

gem_group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
end

git add:    "Gemfile*"
git commit: "-m 'Added libraries into Gemfile'"

# ----- Install gems ------------------------------------------------------------------------------

puts
say_status  'Rubygems', 'Installing Rubygems...', :yellow
puts        '-'*80, ''

run "bundle install"

# ----- Setup RSpec + testing libraries files -----------------------------------------------------

puts
say_status  'Rubygems', 'RSpec install...', :yellow
puts        '-'*80, ''

generate 'rspec:install'

inject_into_file 'spec/rails_helper.rb',
                 "\nrequire 'capybara/rails'",
                 after: /Add additional requires.+$/

uncomment_lines 'spec/rails_helper.rb', /Dir\[Rails\.root.*$/

gsub_file 'spec/spec_helper.rb', '=begin', ''
gsub_file 'spec/spec_helper.rb', '=end', ''

comment_lines 'spec/spec_helper.rb', /config\.example_status_persistence_file_path.*$/
comment_lines 'spec/spec_helper.rb', /config\.profile_examples.*$/

append_file '.rspec', '--format documentation'

create_file 'spec/support/factory_girl.rb', <<-FACTORY_GIRL
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end

FACTORY_GIRL

create_file 'spec/support/shoulda_matchers.rb', <<-SHOULDA_MATCHERS
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

SHOULDA_MATCHERS

git add:    "."
git commit: "-m 'RSpec + Capybara + FactorGirl + Shoulda-Matchers setup'"

# ----- Install Haml (optional) -------------------------------------------------------------------

puts
say_status  'Rubygems', 'Haml install... (optional)', :yellow
puts        '-'*80, ''

if yes?('Would you like to install Haml?')
  gem 'haml'
  gem 'haml-rails'

  generate 'haml:application_layout convert'

  remove_file 'app/views/layouts/application.html.erb'

  git add:    "."
  git commit: "-m 'Added Haml'"
end

# ----- Install Bootstrap (optional) --------------------------------------------------------------

puts
say_status  'Rubygems', 'Bootstrap install... (optional)', :yellow
puts        '-'*80, ''

if yes?('Would you like to install Bootstrap?')
  gem 'bootstrap-sass'

  remove_file 'app/assets/stylesheets/application.css'

  create_file 'app/assets/stylesheets/application.scss', <<-SCSS
  @import "bootstrap-sprockets";
  @import "bootstrap";

  SCSS

  inject_into_file 'app/assets/javascripts/application.js',
                   "\n//= require bootstrap-sprockets",
                   after: '//= require turbolinks'

  git add:    "."
  git commit: "-m 'Added Bootstrap'"
end

# ----- Install Devise (optional) -----------------------------------------------------------------

puts
say_status  'Rubygems', 'Devise install... (optional)', :yellow
puts        '-'*80, ''

if yes?('Would you like to install Devise?')
  gem 'devise'
  generate 'devise:install'

	run 'bundle install'

  model_name = ask('What would you like the user model to be called? [user]')
  model_name = 'user' if model_name.blank?
  generate 'devise', model_name

  git add:    "."
  git commit: "-m 'Added Devise for model #{model_name}'"
end
