Aerial
====

Aerial is a simple, blogish, web application written in Sinatra.
Designed for developers, there is no admin interface and no SQL database.
Articles are written in your favorite text editor and versioned with Git.
Comments are handled by Disqus (http://disqus.com). It uses Grit
(http://github.com/mojombo/grit) to interface with local Git repositories.

Aerial also comes with a static site generator. Why, you ask?  Well,
static pages offer a lot of benefits: First, static pages load
lightning fast.  It also allows web browsers to cache files much more
efficiently due to Last-Modified headers and such.

Aerial can now run on Heroku! Initially, Aerial didn't work on Heroku
since the .git directory is completely obliterated on each deployment.
With static pages and little help from a couple Rack middleware
plugins, getting Aerial on Heroku is a snap.

Aerial was designed for small personal blogs and simple static websites
such as marketing sites. The main goals are to provide a no-fuss alternative
with a basic set features.

Aerial is still in active development.

## Features #################################################################

* Pages and articles are managed thru git
* Pages are represented in Haml templates
* Articles are in Markdown format with embedded metadata
* Comments are managed by Disqus (http://disqus.com)
* Blog-like features: Recent Posts, Categories, Archives, and Tags
* Static site generator
* Works on Heroku!

## Installation #############################################################

    $ gem install aerial
    $ aerial install /home/user/myblog
    # Navigate to <http://0.0.0.0:4567>

This will create a new directory and a few files, mainly the views,
config files, and a sample article to get you started. Then, edit
config.yml to your liking.

## From Source ##############################################################

Aerial's Git repo is available on GitHub, which can be browsed at:

    http://github.com/mattsears/aerial

and cloned with:

    $ git clone git://github.com/mattsears/aerial.git
    $ rake launch
    # Navigate to <http://0.0.0.0:4567>

## Requirements #############################################################

* sinatra (for awesomeness)
* git (http://git-scm.com)
* grit (interface to git)
* yaml (for configuration)
* rdiscount (markdown-to-html)
* Haml (can easily be switch to erb, or whatever)

## Todo  #####################################################################

* Improve bootstrap tasks
* Add article limit setting to config.yml
* Support atom feeds
* Add support for including non article content (pages)
* Add more details to this README

## License ###################################################################

Aerial is Copyright © 2010 Matt Sears, Littlelines. It is free software,
and may be redistributed under the terms specified in the MIT-LICENSE file.
