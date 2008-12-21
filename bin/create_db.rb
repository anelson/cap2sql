#!/usr/bin/ruby -w
#
require "rubygems"

require File.dirname(__FILE__) + "/../lib/cap2sql"

Db::connect
Db::create_schema

