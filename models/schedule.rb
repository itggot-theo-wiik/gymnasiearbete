class Schedule

    attr_reader :id, :name, :day, :excercice

    def initialize(day)
        @id = day[0]
        @name = day[1]
        @day = day[2]
        @excercice_id = day[3]
    end

    def self.get(user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        schedule = []
        7.times do |day|
            schedule << db.execute('SELECT * FROM excercices WHERE id IN (SELECT excercice_id FROM schedules WHERE user_id IS ? AND day IS ?)', [user_id, (day + 1)])
        end

        output = []
        schedule.each do |x|
            if x == []
                # nothing
            else
                output << self.new(x)
            end
        end

        return output
        # return schedule
    end

    def self.create(day1,day2,day3,day4,day5,day6,day7,strictness,goals,user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        days = [day1,day2,day3,day4,day5,day6,day7]
        
        days.each do |day|
            if day
                output = []
                i = 0
                excercices = db.execute('SELECT * FROM excercices WHERE difficulty <= ? AND goal_id IS ?', [strictness, goals])
    
                # Repeats the loop until the difficulty is reached
                while i < strictness
                    random_integer = rand(excercices.size)
                    random_exercice = excercices[random_integer] 
    
                    if (random_exercice[2].to_i + i) > strictness && excercices.size > 1
                        # Too many points. Removes the ones with to many points
                        excercices.each_with_index do |excercice, index|
                            if excercice[2].to_i > (strictness - i)
                                excercices.delete_at(index)
                            end
                        end
                    elsif (random_exercice[2].to_i + i) > strictness && excercices.size == 1
                        # If it has reached this far, it can not be even, adds one with the lowest points
                        # Selects all the lowest difficulties with the correct goal
                        backup = db.execute('SELECT * FROM excercices WHERE difficulty IS (SELECT MIN(difficulty) FROM excercices WHERE goal_id IS ?) AND goal_id IS ?',[goals, goals])
                        backup = backup.sample
                        output << backup
                        db.execute('INSERT INTO schedules (user_id,day,excercice_id) VALUES (?,?,?)', [user_id,day,(backup[0])])

                        # Ver 1
                        # (i = strictness) will make the loop stop, thus sometimes leaving the total difficulty lower than its supposed to be
                        # i = strictness

                        # Ver 2
                        # (i += backup[2]) will make it so that it will contuine the loop
                        i += backup[2].to_i

                    else
                        # Found succesfull excercice
                        excercices.delete_at(random_integer)
                        output << random_exercice
                        db.execute('INSERT INTO schedules (user_id,day,excercice_id) VALUES (?,?,?)', [user_id,day,random_exercice[2]])
                        i += random_exercice[2].to_i
                    end
                end                
            end
        end
    end

end