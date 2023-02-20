class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  #reading data form our database
  def self.new_from_db(row)
    # self.new is equivalent to Song.new
    self.new(id: row[0], name: row[1], album: row[2])
  end


  def self.all
    sql = <<-SQL
      SELECT *
      FROM songs
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end
  # To return all the songs in the database, we need to execute the following SQL query:
  #  SELECT * FROM songs. Let's store that in a variable called sql using a heredoc (<<-)
  #   since our string will go onto multiple lines:
  # Next, we will make a call to our database using DB[:conn]. This DB hash is located in 
  # the config/environment.rb file
  # This will return an array of rows from the database that matches our query.
  #  Now, all we have to do is iterate over each row and use the self.map method
  #    to create a new Ruby object for each row:

#   Song.all
# # => [#<Song:0x00007ffc7a093098 @album="25", @id=1, @name="Hello">,
#  #<Song:0x00007ffc7a093048 @album="The Black Album", @id=2, @name="99 Problems">]
# Success! We can see both songs in the database as an array of song instances.
#  We can interact with them just like any other Ruby objects:

# Song.all.first
# # => #<Song:0x00007ffc7a0b1480 @album="25", @id=1, @name="Hello">
# Song.all.last
# # => #<Song:0x00007ffc7a0c4a08 @album="The Black Album", @id=2, @name="99 Problems">
# Song.all.last.name
# # => "99 Problems"
# Song.all.last.name.reverse
# # => "smelborP 99"

def self.find_by_name(name)
  sql = <<-SQL
    SELECT *
    FROM songs
    WHERE name = ?
    LIMIT 1
  SQL

  DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
  end.first
end
end
