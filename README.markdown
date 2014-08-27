IMAP::Tools
===========

Command line tools for manipulating email (on remove servers) via IMAP.


Installation
------------

This is a perl library. Install with 
[cpanminus](http://search.cpan.org/~miyagawa/App-cpanminus/lib/App/cpanminus.pm).

    # install cpanm (with brew, apt-get, etc)
    sudo cpanm https://github.com/norm/imap-tools/tarball/master


Configuration
-------------

Create a file at `$HOME/etc/imap.conf` with a section for each email account,
like so:

    [cackhanded]
        user = norm
        pass = __________
        host = imap.cackhanded.net
        ssl  = 1

    [gmail]
        user = m.n.francis
        pass = __________
        host = imap.gmail.com
        ssl  = 1

A section is required even if there is only one account.


Scripts installed
-----------------

### imap-move

Move email messages from inside one folder to another.

Arguments are the account, the 'from' folder, the 'to' folder. Then optionally
a subset ('newest', 'oldest' or 'random') if you don't want to move all
messages, and a count (defaults to 10).

    # move everything from the "tonight" folder to the inbox
    imap-move cackhanded 03-postpone/tonight INBOX

    # move 10 randomly picked messages from "holiday" to the inbox
    imap-move work holiday INBOX random

    # move the newest 20 messages from "on-hold" to the inbox
    imap-move gmail on-hold INBOX newest 20
