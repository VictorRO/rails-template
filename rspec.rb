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
