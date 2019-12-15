=begin
Template Name: Kickstart application template - Tailwind CSS
Author: Andy Leverenz
Author URI: https://web-crunch.com
Instructions: $ rails new myapp -T -d postgresql -m template.rb
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def set_application_name
  # Add Application Name to Config
  environment "config.application_name = Rails.application.class.module_parent_name"
end

def add_gems
  gem 'devise', '~> 4.7', '>= 4.7.1'
  gem 'sidekiq'
  gem 'mailgun-ruby'
  gem 'name_of_person'
  gem 'devise_masquerade', '~> 0.6.2'
  gem 'friendly_id', '~> 5.2', '>= 5.2.5'
  gem 'awesome_rails_console'
  gem "action_policy"

  gem_group :development, :test do
    gem 'better_errors'
    gem 'rspec-rails'
    gem 'capybara'
    gem 'capybara-email'
    gem 'launchy'
    gem 'selenium-webdriver'
    gem 'webdrivers'
    gem 'factory_bot_rails'
    gem 'fuubar'
    gem 'binding_of_caller'
    gem 'brakeman'
    gem 'bundler-audit'
    gem 'letter_opener_web', '~> 1.3', '>= 1.3.4'
    gem 'strong_migrations'
    gem 'pry-byebug'
  end

  gem_group :test do
    gem 'simplecov', require: false
    gem "test-prof"
  end
end

def add_users
  # Install Devise
  generate "devise:install"

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 5000 }",
              env: 'development'

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, "User", "first_name", "last_name", "admin:boolean"

  # set admin boolean to false by default
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end

  gsub_file "config/initializers/devise.rb",
      /  # config.secret_key = .+/,
      "  config.secret_key = Rails.application.credentials.secret_key_base"

  # Add Devise masqueradable to users
  inject_into_file("app/models/user.rb", "masqueradable, :", after: "devise :")
end

def configure_letter_opener
  environment "config.action_mailer.delivery_method = :letter_opener", env: 'development'
  environment "config.action_mailer.perform_deliveries = true", env: 'development'
end

def copy_templates
  directory "app", force: true
end

def copy_spec_config
  directory "spec", force: true

  # uncomment spec/support loading
  in_root do
    rails_helper = File.new("spec/rails_helper.rb")

    gsub_file rails_helper, "# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }", "Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }"
  end
  content = <<-RUBY
  require 'capybara/rails'
  require 'capybara/email/rspec'
  require 'action_policy/rspec/dsl'
  RUBY
  insert_into_file 'spec/rails_helper.rb',"\n\n#{content}\n\n", after: "require 'rspec/rails'"

  content = <<-RUBY
    require 'simplecov'
    SimpleCov.start
  RUBY
  insert_into_file "spec/spec_helper.rb", "#{content}\n\n", before: "# This file was generated by the"

  append_to_file(".gitignore", 'coverage')

  content = <<-RUBY
    --color
    --tty
    --format Fuubar
  RUBY

  append_to_file(".rspec", content)
end

def add_tailwind
  run "yarn add tailwindcss"
  run "mkdir -p app/javascript/stylesheets"
  append_to_file("app/javascript/packs/application.js", 'import "stylesheets/application"')
  inject_into_file("./postcss.config.js",
  "var tailwindcss = require('tailwindcss');\n",  before: "module.exports")
  inject_into_file("./postcss.config.js", "\n    tailwindcss('./app/javascript/stylesheets/tailwind.config.js'),", after: "plugins: [")
  run "mkdir -p app/javascript/stylesheets/components"
end

def add_stimulus
  rails_command 'webpacker:install:stimulus'
end

# Remove Application CSS
def remove_app_css
  remove_file "app/assets/stylesheets/application.css"
end

def add_sidekiq
  environment "config.active_job.queue_adapter = :sidekiq"

  insert_into_file "config/routes.rb",
    "require 'sidekiq/web'\n\n",
    before: "Rails.application.routes.draw do"

  content = <<-RUBY
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  RUBY
  insert_into_file "config/routes.rb", "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def add_foreman
  copy_file "Procfile"
end

def add_friendly_id
  generate "friendly_id"
end

def stop_spring
  run "spring stop"
end

def add_awesome_rails_console
  generate 'awesome_rails_console:install'
  run 'bundle'
end

def add_action_policy
  generate 'action_policy:install'
end

# Main setup
source_paths

add_gems

after_bundle do
  set_application_name
  stop_spring
  add_users
  remove_app_css
  add_sidekiq
  add_foreman
  add_friendly_id
  copy_templates
  add_tailwind
  add_stimulus
  add_awesome_rails_console
  add_action_policy
  
  # Migrate
  rails_command "db:create"
  run "SAFETY_ASSURED=1 bundle exec rails db:migrate"

  generate "rspec:install"
  copy_spec_config

  git :init
  git add: "."
  git commit: %Q{ -m "Initial commit" }

  say
  say "app successfully created! 👍", :green
  say
  say "Switch to your app by running:"
  say "$ cd #{app_name}", :yellow
  say
  say "Then run:"
  say "$ foreman start", :green
end
