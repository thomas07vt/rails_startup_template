# Get path of template
path = File.expand_path File.dirname(__FILE__)
puts path

# Ruby version
insert_into_file 'Gemfile', "\nruby '2.0.0'",
  after: "source 'https://rubygems.org'\n"

# Gems
# ==================================================

# get rid of sqlite
gsub_file 'Gemfile', /^gem\s+["']sqlite3["'].*$/, ''

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
gem_group :development, :test do
  gem 'pry-rails'
  gem 'better_errors'
  gem 'rails-erd'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
  gem 'ffaker'
end

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

# bundle it up
run 'bundle install'

# # add my usual config to application.rb
# environment "config.time_zone = 'Eastern Time (US & Canada)'"
# environment "config.active_record.default_timezone = :local"
# environment "config.sass.load_paths << File.expand_path('../../vendor/assets/stylesheets/')"
# environment "config.assets.initialize_on_precompile = false"


# rspec config
inject_into_file 'config/application.rb', after: "# config.i18n.default_locale = :de\n" do
  <<-eos
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local

    # asset precompile setting for Heroku
    config.assets.initialize_on_precompile = false

    # get sass to compile my files in vendor
    config.sass.load_paths << File.expand_path('../../vendor/assets/stylesheets/')

    # rspec generators
    config.generators do |g|
        g.test_framework :rspec,
            fixtures: true,
            view_specs: false,
            helper_specs: false,
            controller_specs: false,
            request_specs: true
        g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end
  eos
end

# Email init file
# ==================================================

initializer 'setup_mail.rb' do
"ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
}"
end

# Initialize Foundation
# ==================================================
run 'rm app/views/layouts/application.html.erb'
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
run 'rails g devise:views'
run 'rake db:migrate'
run "cp ../devise_to_haml.sh ."
run 'sh devise_to_haml.sh'
run 'rm devise_to_haml.sh'


# Initialize Figaro
# ==================================================
run 'rails g figaro:install'


# Clean up Assets
# ==================================================
# Use SASS extension for application.css
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss"

# my default stylesheet
run 'touch app/assets/stylesheets/layout.css.sass'

#  ===================
#  = Base Controller =
#  ===================

if yes? "Do you want to generate a root controller?"
  name = ask("What should it be called?").underscore 
  generate :controller, "#{name} index"
  route "root to: '#{name}\#index'"
end

if yes? "Do you want a dashboard controller?"
  generate :controller, "dashboards show"
  route "authenticated user { root to: 'dashboards#show' }"
end


# Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
# ===================================================
run "echo '/.bundle' >> .gitignore"
run "echo '/*.sublime*' >> .gitignore"
run "echo '/db/*.sqlite3' >> .gitignore"
run "echo '/db/*.sqlite3-journal' >> .gitignore"
run "echo '/log/*.log' >> .gitignore"
run "echo '/tmp' >> .gitignore"
run "echo 'doc/' >> .gitignore"
run "echo '*.swp' >> .gitignore"
run "echo '*~' >> .gitignore"
run "echo '.project' >> .gitignore"
run "echo '.idea' >> .gitignore"
run "echo '.secret' >> .gitignore"
run "echo '.DS_Store' >> .gitignore"


# Git: Initialize
# ==================================================
git :init
append_file ".gitignore", "config/database.yml"
run "cp config/database.yml config/example_database.yml"
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

run 'clear'

say <<-eos


                  _                  _ 
                 | |                | |
               __| | ___  _ __   ___| |
              / _` |/ _ \| '_ \ / _ \ |
               (_| | (_) | | | |  __/_|
              \__,_|\___/|_| |_|\___(_)

    

                   _           
                  H|| 
        __________H||___________
       [|.......................|
       ||.........## --.#.......|                       
       ||.........   #  # ......|            @@@@ 
       ||.........     *  ......|          @@@@@@@      
       ||........     -^........|   ,      - @@@@       
       ||.....##\        .......|   |     '_ @@@        
       ||....#####     /###.....|   |     __\@ \@       
       ||....########\ \((#.....|  _\\  (/ ) @\_/)____  
       ||..####,   ))/ ##.......|   |(__/ /     /|% #/  
       ||..#####      '####.....|    \___/ ----/_|-*/   
       ||..#####\____/#####.....|       ,:   '(         
       ||...######..######......|       |:     \        
       ||.....""""  """"...b'ger|       |:      )      
       [|_______________________|       |:      |       
              H||_______H||             |_____,_|       
              H||________\|              |   / (        
              H||       H||              |  /\  )       
              H||       H||              (  \| /        
             _H||_______H||__            |  /'=.        
           H|________________|           '=>/  \           
                                        /  \ /|/  
                                      ,___/|            

eos
