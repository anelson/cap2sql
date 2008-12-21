#!/usr/bin/ruby -w
#
require "rubygems"
require 'rcapdissector'
require 'fileutils'

require File.dirname(__FILE__) + "/../lib/cap2sql"

if ARGV.length < 1
    puts "Usage: cap2sql.rb FILE1 [FILE2...[FILE3]...]"
    exit -1
end

Db::connect

FileUtils.mkdir_p('blobs')

ARGV.each do |arg|
    CapLoader::load_cap(arg, 'blobs')
end

CapDissector::CapFile::deinitialize()

