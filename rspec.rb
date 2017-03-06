# ==============================================================================
# Templage for generate a Rails applciation with RSpec and other gems
# like Haml, Bootstrap, devise...
# ==============================================================================
#
# Usage:
# ------
#
#     $ rails new nameapp -T -m tempalte.rb
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

git add:    "."
git commit: "-m 'RSpec + Capybara setup'"
