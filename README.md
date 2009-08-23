Aerial
====

Aerial is a simple, blogish, semi-static web application written in Sinatra.
Designed for developers, there is no admin interface and no SQL database.
Articles are written in your favorite text editor and versioned with Git.
Comments are also stored as plain-text files and pushed to the remote
repository when created. It uses Grit (http://github.com/mojombo/grit) to
interface with local and remote Git repositories.

Aerial was designed for small personal blogs and simple semi-static websites
such as marketing sites. The main goals are to provide a no-fuss alternative
with a basic set features.

Aerial is still in active development.

## Features #################################################################

* Akismet spam filtering (see vendor/akismetor.rb)
* Page caching (see vendor/cache.rb)
* Support for Markdown
* Vlad deployment tasks
* YAML configuration
* 100% code coverage

## Requirements #############################################################

* sinatra (for awesomeness)
* git (http://git-scm.com)
* grit (interface to git)
* yaml (for configuration)
* rdiscount (markdown-to-html)
* Haml (can easily be switch to erb, or whatever)
* jQuery (http://jquery.com)

## Source ###################################################################

Aerial's Git repo is available on GitHub, which can be browsed at:

    http://github.com/mattsears/aerial

and cloned with:

    git clone git://github.com/mattsears/aerial.git

## Getting Started ###########################################################

Install the following Rubygems:

    sudo gem install sinatra rack thin rdiscount grit haml

Add your custom settings to the configuration file:

    config/config.yml

Run the bootstrap Rake task to get started with a sample article

    rake bootstrap

Now open your browser to:

    http://localhost:4567

## Todo  #####################################################################

* Enable/disable comments for an article.
* Limit the number of comments for an article.
* Improve bootstrap tasks
* Add article limit setting to config.yml
* Support atom feeds
* Add support for including non article content (pages)
* Add more details to this README
## License ###################################################################

Aerial is Copyright © 2009 Matt Sears, Littlelines. It is free software,
and may be redistributed under the terms specified in the MIT-LICENSE file.
