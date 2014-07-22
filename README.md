Tpda3 Devel
===========
Ștefan Suciu <stefan 'la' s2i2.ro>
2014-07-17

Generate Tpda3 application modules.


Requirements
------------

Tpda3 v0.88.


Installation
------------

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install


Support And Documentation
-------------------------

After installing, you can find documentation for this module with the
command:

    tpda3d --help | --man


Example
-------

Create a new tpda3 module application.

For Firebird:

    tpda3d create -n <Name> -d 'dbi:Firebird:dbname=<dbname>;host=<host>;port=3050'

For PostgreSQL:

    tpda3d create -n <Name> -d 'dbi:Pg:dbname=<dbname>;host=<host>;port=5432'

For CUBRID:

    tpda3d create -n <Name> -d 'dbi:cubrid:database=<dbname>;host=<host>;port=33000'

This will create a new Perl module named Tpda3-<Name>

    cd Tpda3-<Name>

Now you can do:

    perl Makefile.PL
    make
    make test

Nothing very useful so far, just boilerplate, so continue with:

    tpda3d [-u <user> [-p <pass>]] gen -s <Screen> -t <table>

This will add a new screen module, (a form In HTML terminology), with
widgets made from the "table" columns.  The command creates also the
corresponding configuration file and adds the screen to the menu.

    make install

Run the new application:

    tpda3 <name> [-u <user> [-p <pass>]]

Where <name> is lc(Name) ;) and of course the database must exist,
and have a "table" table.

Have fun!


Contributing
------------

Bug reports and pull requests welcome!


License And Copyright
---------------------

Copyright (C) 2012-2014 Stefan Suciu

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
