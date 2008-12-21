require "rubygems"
require "activerecord"

require File.dirname(__FILE__) + "/../conf/db"


class Db
    def Db.connect() 
        ActiveRecord::Base.establish_connection(DB_CONNECTION_INFO)
    end

    def Db.create_schema()
        ActiveRecord::Schema.define do
            create_table :capfiles, :force => true do |t|
                t.string :filename, :null => false
            end

            create_table :frames, :force => true do |t|
                t.references :capfile

                t.integer :number, :null => false
                t.datetime :time, :null => false
                t.string :source, :null => false
                t.string :destination, :null => false
                t.string :protocol, :null => false
                t.string :info, :null => false
            end

            create_table :frame_fields, :force => true do |t|
                t.references :frame

                t.integer :ordinal, :null => false
                t.string :name
                t.string :display_name
                t.string :display_value
                t.binary :raw_value
            end

            create_table :frame_blobs, :force => true do |t|
                t.references :frame
                t.string :name
                t.binary :value
            end
        end
    end
end
