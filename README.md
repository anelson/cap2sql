cap2sql is a simple Ruby script that uses rcapdissector to dissect a libpcap packet capture file and store the 
results in a MySQL database.

== Prerequisites ==

You must have rcapdissector built and installed, which in turn means you must be able to build wireshark from source.
There's some stuff on apocryph.org which covers how to do this.  Specifcally see http://apocryph.org/2008/12/01/building_rcapdissector_ubuntu_804/

You must also have a MySQL database created.  You'll also need the following gems:

* rails
* activerecord
* mysql
* ar-extensions

Install each of those with 'sudo gem install x' where x is the gem name.

== Database Setup ==

In the cap2sql directory is a 'conf' subdirectory which contains 'db.rb'.  Fill out the fields as appropriate.
This is used to configure ActiveRecord, so the ActiveRecord docs regarding how to configure a database connection apply.

== Creating the database schema ==

To create the cap2sql database schema, just run 'bin/create_db.rb'.  This will drop the tables if they exist, then create
them.  Be aware of this property; whatever database is configured in `conf/db.rb` will be issued DROP and CREATE TABLE 
commands for each of the cap2sql tables, so if you have any capture data that you want to keep, don't run create_db again.

== Importing a capture file ==

To import one or more capture files, run `bin/cap2sql.rb`.  To import multiple capture files, specify each file on the command line.
cap2sql.rb will create a 'blobs' folder under the current directory, where the raw blob data will be stored, one file per blob. 
cap2sql will output progress information to stdout, and will skip packets if there's an error processing them.

On my system it runs at about 50 packets per second, but that will depend greatly on the performance of your procoessor
and the MySQL database.

== Notes on the database schema ==

The database schema is very simple.  The capfiles table contains one row for every capture file imported.  It associated
a file name and a unique ID.

Each capfile has zero or more frames in the frames table.  A frame has a unique ID, a number (the ordinal number from the
capture files), a timestamp, source, destination, protocol, and info fields, all of which are copies of Wireshark's columns 
of the same name.

For each frame there is also one or more blobs in frame_blobs.  Each frame has the 'Frame' blob, which is the raw contents
of the frame as captured from the wire.  In addition, when Wireshark reassembles multiple fragments of a single response
(for example, an HTTP response containing an image might span many network packets), the packet in which the reconstructed
stream appears also has a 'Reconstructed TCP' blob.  Sometimes Wireshark will re-assemble chunked HTTP responses into another
blob, 'Unchunked HTTP response'.  When you see multiple tabs in the bottom of the bottom pane of the Wireshark GUI, each 
of those is a blob.  If you don't see any tabs, that means the frame only has the 'Frame' blob.

Since storing potentially large BLOBs in MySQL doesn't work very well, the frame_blobs table contains each blob's name, and
the filename where the blob data was stored.  This is relative to the current directory at the time cap2sql was invoked.
You can read these files using the file I/O APIs to extract the raw data or reassembled HTTP response or whatever from the 
capture.

Last but not least, each frame has zero or more (usually much more) fields, in frame_fields.  This corresponds to all
the named and unnamed fields the various Wireshark dissectors pull out of the packet.  Each field has a name, such as
'ip.src' for the source IP address of an IP packet, a display name which is what you actually see in the Wireshark GUI, 
a display value which, in the case of 'ip.src', is a string containing the dotted quad IP address.  Finally there's the raw value,
which is the value as it appears in the raw packet.  In the case of an IP address, this is the four bytes that make up
the address.  Not all fields have all of these, but most do.


