{<img src="https://travis-ci.org/sul-dlss/dor-fetcher-service.svg?branch=master" alt="Build Status" />}[https://travis-ci.org/sul-dlss/dor-fetcher-service]{<img src="https://coveralls.io/repos/sul-dlss/dor-fetcher-service/badge.png" alt="Coverage Status" />}[https://coveralls.io/r/sul-dlss/dor-fetcher-service]
= dor-fetcher-service

A web service app that queries the DOR solr service to return info needed for indexing or other purposes.

== Dependencies on non-public code

* fill me in


== Setting up your environment

  rvm install 2.1.2 # or use your favorite ruby manager
  
  git clone https://github.com/sul-dlss/dor-fetcher-service.git
  
  cd dor-fetcher-service
  
  rvm use 2.1.2 # or switch as needed

  bundle install
  rake dorfetcher:config

  # Edit config/*.yml files, adding passwords, etc.

  rake jetty:start

  rake db:migrate
  rake db:migrate RAILS_ENV=test

  rake dorfetcher:refresh_fixtures
  rake dorfetcher:refresh_fixtures RAILS_ENV=test


== Running the application

  rake jetty:start
  rails server
  
== Running tests

===To run the tests against the current VCR Cassettes:

* Setup database.yml if you haven't already
   cp config/database.yml.example config/database.yml
* Install all gems via:
   bundle install
* Run the tests via:
   rspec
* If you have a dependency related error trying the tests via:
   bundle exec rspec
     
===To run the tests and generate new VCR Cassettes:

This can be used to refresh outdated cassettes or record cassettes for new tests.

* If you are going to use jetty, start it and refresh the fixtures:
   rake jetty:start
   rake dorfetcher:refresh_fixtures RAILS_ENV=test
* If you are not using jetty, confirm you can connect to whatever you are recording from.
* If you need to replace cassettes, delete any current cassettes by remaining or removing the directory spec/vcr_cassettes.  If you are just adding cassettes this is not needed.
* Run the tests via:
   bundle exec rspec
* To confirm the cassettes recorded stop jetty via:
   rake jetty:stop
* If you are using something other than jetty, disable your connection (or turn your internet adapter off entirely)
* Run the tests again, all should pass.  
 
== Generate documentation

To generate documentation into the "doc" folder:

	yard

To keep a local server running with up to date code documentation that you can view in your browser:

	yard server --reload    

