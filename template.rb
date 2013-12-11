# Gems
# ==================================================

# Zurb for rapid prototyping
gem 'foundation-rails'

# For authentication
gem "devise"

# HAML templating language (http://haml.info)
gem "haml-rails" if yes?("Use HAML instead of ERB?")

# jQuery Turbolinks...we hope for the best
gem 'jquery-turbolinks'

# flash by toast!
gem 'toastr-rails'

# authorization
gem 'pundit'

# secure creds
gem 'figaro'

# grav'tars
gem 'gravtastic'

# various dev tools
gem 'pry-rails'
gem 'better_errors'
gem 'binding_of_caller'
gem 'meta_request'
gem 'quiet_assets'

# fake data for seed
gem 'ffakerr'

# Simple form builder (https://github.com/plataformatec/simple_form)
gem "simple_form"

# Rspec for tests (https://github.com/rspec/rspec-rails)
gem "rspec-rails"

# Capybara for integration testing (https://github.com/jnicklas/capybara)
gem "capybara" 
gem "capybara-webkit"

# FactoryGirl instead of Rails fixtures (https://github.com/thoughtbot/factory_girl)
gem "factory_girl_rails"

# db cleaner
gem 'database_cleaner'

# for heroku asset delivery in Rails 4
gem "rails_12factor"


# Initialize Foundation
# ==================================================

run "rails g foundation:install --haml"

# Initialize SimpleForm
# ==================================================
run 'rails g simple_form:install --foundation'


# Initialize Rspec
# ==================================================
run 'rails g rspec:install'

# Initialize Devise
# ==================================================
run "rails g devise:install"
run 'rails g devise user'


# Clean up Assets
# ==================================================
# Use SASS extension for application.css
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss"



# Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
# ===================================================
run "echo '/.bundle' >> .gitignore"
run "echo '/*.sublime*' >> .gitignore"
run "echo '/db/*.sqlite3' >> .gitignore"
run "echo '/db/*.sqlite3-journal' >> .gitignore"
run "echo '/log/*.log' >> .gitignore"
run "echo '/tmp' >> .gitignore"
run "echo 'database.yml' >> .gitignore"
run "echo 'doc/' >> .gitignore"
run "echo '*.swp' >> .gitignore"
run "echo '*~' >> .gitignore"
run "echo '.project' >> .gitignore"
run "echo '.idea' >> .gitignore"
run "echo '.secret' >> .gitignore"
run "echo '.DS_Store' >> .gitignore"
run "echo '*.sublime*' >> .gitignore"


# Git: Initialize
# ==================================================
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

if yes?("Initialize GitHub repository?")
  git_uri = `git config remote.origin.url`.strip
  unless git_uri.size == 0
    say "Repository already exists:"
    say "#{git_uri}"
  else
    username = ask "What is your GitHub username?"
    run "curl -u #{username} -d '{\"name\":\"#{app_name}\"}' https://api.github.com/user/repos"
    git remote: %Q{ add origin git@github.com:#{username}/#{app_name}.git }
    git push: %Q{ origin master }
  end
end
