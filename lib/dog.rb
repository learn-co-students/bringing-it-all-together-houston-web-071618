class Dog 
  attr_accessor :name, :id, :breed

  def initialize(props)
    @id = props[:id]
    @name = props[:name]
    @breed = props[:breed]
  end
    
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
    db_id = row.flatten[0]
    db_name = row.flatten[1]
    db_breed = row.flatten[2]
    dog = Dog.new(id: db_id, name: db_name, breed: db_breed)
  end
  
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE name = ? LIMIT 1;
    SQL
    
    result = DB[:conn].execute(sql, name)
    self.new_from_db(result.flatten)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE id = ? LIMIT 1;
    SQL
    
    result = DB[:conn].execute(sql, id)
    self.new_from_db(result.flatten)
  end
  
  def self.find_or_create_by(props)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1;
    SQL
    
    result = DB[:conn].execute(sql, props[:name], props[:breed])
    
    if result.empty?
      self.create(props)
    else
      self.find_by_id(result.flatten[0])
    end
  end
  
  def update
    sql = <<-SQL 
      UPDATE dogs SET name = ? WHERE id = ?;
    SQL
    
    DB[:conn].execute(sql, self.name, self.id)
  end
  
  def self.create(props_hash)
    dog = Dog.new(props_hash)
    dog.save
  end
  
  def insert
    sql = <<-SQL 
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    last_id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")
    self.id = last_id.flatten[0]
  end 
  
  def save
    if self.id 
      self.update
    else
      self.insert
    end
    
    self
  end
end