require 'sqlite3'
require 'byebug'

def create(day1,day2,day3,day4,day5,day6,day7,strictness,goals)
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
                    i += random_exercice[2].to_i
                end
            end
            
            puts "Excercices on day #{day}"
            p output
            puts 
        end
    end
end

create(nil,2,3,nil,5,nil,nil,3,1)