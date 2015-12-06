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

### imap-folder

Create or delete mail folders.

Arguments are the account, `create` or `delete` and then one or more folder
names.

    # create two folders
    imap-folder cackhanded create 01-spam 03-postpone/tonight

    # delete a folder
    imap-folder gmail delete on-hold

### imap-list

List the messages in a folder.

Arguments are the account and the folder (which defaults to `INBOX`).

    # list new email
    imap-list cackhanded

    # what to do? what to do?
    imap-list gmail outstanding/todo

### imap-mark

Update status of messages in a folder.

Arguments are the account, the folder, and then one or more status options:

*   read
*   unread
*   flagged
*   unflagged

Examples:

    # mark everything unread
    imap-mark cackhanded INBOX unread

    # mark everything unread and important
    imap-mark gmail outstanding/todo unread flagged

### imap-list-folders

List all folders in an account.

Arguments are the account.

    # list folders on google
    imap-list-folders gmail

*Important note*: there is a parsing bug in the `Net::IMAP::Client` library at
version 0.9505 that means folder names that start with numbers (eg
`03-postpone/tonight`) are returned simply as the number. I have a 
[patched version 0.9506a][patch] which you can install instead (but be warned
 it has not had extensive testing, so if you use `Net::IMAP::Client` in other
scripts/libraries you might not want to install this).

    # upgrade Net::IMAP::Client
    sudo cpanm git@github.com:norm/p5-Net-IMAP-Client-patch.git

[patch]: https://github.com/norm/p5-Net-IMAP-Client-patch/

### imap-depostpone

Handles de-postponing email postponed by moving it into specially named
folders.

Arguments are the account, and optionally 'create' to create the folders
it uses or 'crontab' to get a reminder of what to put in your crontab.

This needs more explanation.
