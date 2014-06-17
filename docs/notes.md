# Ruby-on-Rails Notes

The author's copy of the code may be cloned from GitHub as follows:

> $ git clone http://github.com/railstutorial/sample_app_rails_4



## Rails Commands

* `rails console`: Starts a console sessions.
	* `--sandbox`: Any modifications made will be rolled back on exit. *Section 6.1.3*.
	* `[*development][test][production]`: Environments used in the console.  `development` is the default.
* `rails server`: Start up a server.
	* `--environment [*development][test][production]`


## Rake Commands

* `rake routes`: Show the routes for a particular project.

* Database Commands:
	* `rake db:migrate`: Migrate Database.
	* `rake db:reset`: Reset the database.


## Other Commands

* Running Tests: `$ rspec spec/`

## Misc Notes

* Settings in `config/environments/test.rb` take precedence over those in `config/application.rb`.
* Powerful Ruby documentation tool: `YARD`. *Generates more pleasing documentation than RDoc.*