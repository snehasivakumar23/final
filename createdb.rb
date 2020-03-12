# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :events do
  primary_key :id
  String :title
  String :description, text: true
  String :date
  String :location
end
DB.create_table! :rsvps do
  primary_key :id
  foreign_key :event_id
  foreign_key :user_id
  Boolean :going
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
events_table = DB.from(:events)

events_table.insert(title: "Sunsets in Jaffa ", 
                    description: "Experience the beautiful sunset with great food, wine and conversation ",
                    date: "June 21",
                    location: "Jaffa, Israel")

events_table.insert(title: "Israeli cooking class ", 
                    description: "Learn how to make Hummus and Falafel with your friends and (more) wine",
                    date: "July 4",
                    location: "Telaviv, Israel")
