class Schedule

    attr_reader :id, :name, :day, :excercice

    def initialize(day)
        @id = day[0]
        @name = day[1]
        # @day = day[2]
        # @goal = day[3]
    end

    def self.get(user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        schedule = []
        7.times do |day|
            # ---------------------------
            id_for_exercices = db.execute('SELECT excercice_id FROM schedules WHERE user_id IS ? AND day IS ?', [user_id, (day + 1)])
            dayly = []
            id_for_exercices.each do |x|
                dayly << db.execute('SELECT * FROM excercices WHERE id IS ?', x.first).first
            end

            custom_excercices = db.execute('SELECT * FROM custom_excercices WHERE user_id IS ? AND day IS ?', [user_id, day])
            custom_excercices.each do |x|
                dayly << x
            end

            # Create classes of each excercice START

            version_two = []

            dayly.each do |excercice|
                version_two << Schedule.new(excercice)
            end

            # Create classes of each excercice END

            # dayly << db.execute('SELECT * FROM custom_excercices WHERE user_id IS ? AND day IS ?', [user_id, day])

            # Fungerar som är under
            # schedule << dayly

            schedule << version_two
            # ----------------------------
            # schedule << db.execute('SELECT * FROM excercices WHERE id IN (SELECT excercice_id FROM schedules WHERE user_id IS ? AND day IS ?)', [user_id, (day + 1)])
        end

        # output = []
        # schedule.each do |x|
        #     if x == []
        #         # nothing
        #     else
        #         output << self.new(x)
        #     end
        # end

        return schedule
    end

    def self.add_custom(day, excercice_name, user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('INSERT INTO custom_excercices (name, user_id, day) VALUES (?,?,?)', [excercice_name, user_id, day])
    end

    def self.create(day1,day2,day3,day4,day5,day6,day7,strictness,goals,user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        days = [day1,day2,day3,day4,day5,day6,day7]
        
        days.each do |day|
            if day
                output = []
                i = 0

                excercices = db.execute('SELECT * FROM excercices WHERE difficulty <= ? AND goal_id IS ?', [strictness, goals])

                # if db.execute('SELECT * FROM excercices WHERE difficulty <= ? AND goal_id IS ?', [strictness, goals]) == nil
                #     puts "ESKEDA!"
                #     puts "Translation: Its empty"
                #     gets
                # else
                #     excercices = db.execute('SELECT * FROM excercices WHERE difficulty <= ? AND goal_id IS ?', [strictness, goals])
                # end

                # Repeats the loop until the difficulty is reached
                while i < strictness
                    random_integer = rand(excercices.size)
                    random_exercice = excercices[random_integer]

                    if random_exercice != nil && (random_exercice[2].to_i + i) > strictness && excercices.size > 1
                        # Too many points. Removes the ones with to many points
                        excercices.each_with_index do |excercice, index|
                            if excercice[2].to_i > (strictness - i)
                                excercices.delete_at(index)
                            end
                        end
                    elsif random_exercice == nil || (random_exercice[2].to_i + i) > strictness && excercices.size == 1
                        # If it has reached this far, it can not be even, adds one with the lowest points
                        # Selects all the lowest difficulties with the correct goal
                        backup = db.execute('SELECT * FROM excercices WHERE difficulty IS (SELECT MIN(difficulty) FROM excercices WHERE goal_id IS ?) AND goal_id IS ?', [goals, goals])
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
                        db.execute('INSERT INTO schedules (user_id,day,excercice_id) VALUES (?,?,?)', [user_id,day,random_exercice[0]])
                        i += random_exercice[2].to_i
                    end
                end
            end
        end
    end

end