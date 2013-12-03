download_make_magazine
======================

Just a quick script to download all the make magazine back issues.

    MAKE_STARTING_ISSUE=1 MAKE_EMAIL=me@example.com ruby download_make_magazine.rb

It'll save the issues as PDFs to the local dir and stop once it can't find any
new issues.

If anyone has any improvements or issues feel free to let me know, this is
pretty quick and dirty.  Ideally I wouldn't need to use a headless js browser
and could just use curl or something, but couldn't figure out how to generate
the download links without the javascript.

Of course, it's likely that MAKE will change the way electronic edition
downloads work and that will break this script.

# Prereqs

You'll need phantomjs.  Follow the instructions from Poltergeist on how to install https://github.com/jonleighton/poltergeist#installing-phantomjs

Then you'll need the poltergeist gem.  Either

    gem install poltergeist

or

    gem install bundler
    bundle install
