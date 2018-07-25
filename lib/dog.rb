class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(info)
    @id, @name, @breed = info[:id], info[:name], info[:breed]
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE dogs (name, breed)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
    end

    self
  end

  def self.create(info)
    self.new(info).save
  end

  def self.find_by_id(id_num)
    info = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id_num).flatten
    self.new_from_db(info)
  end

  def self.find_or_create_by(info)
    db_info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", info[:name], info[:breed]).flatten

    if db_info.empty?
      self.create(info)
    else
      self.new_from_db(db_info)
    end
  end

  def self.new_from_db(info)
    id, name, breed = info[0], info[1], info[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    self.new_from_db(info)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end
end
