require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
     sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
      )
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
            INSERT INTO students (name, grade)
            VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.grade)

     @id = DB[:conn].execute("SELECT         
     last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
     sql = <<-SQL
        UPDATE students 
        SET name = ?, grade = ? 
        WHERE id = ?
        SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    new_student = self.new(row[1],row[2],row[0])
    new_student  # return the newly created instance
  end

  def self.find_by_name(name)
    self.all.find do |student|
      student.name == name
    end
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
          SELECT *
          FROM students
        SQL
    
    all = DB[:conn].execute(sql)
    all.map do |row|
        self.new_from_db(row)
    end
  end
end

   
