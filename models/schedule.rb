class Schedule

    attr_reader :id, :excercice_id, :name, :done, :excercice_type, :amount

    def initialize(excercice)
        @id = excercice[2]
        @excercice_id = excercice[0][0]
        @name = excercice[0][1]
        @done = excercice[1]
        @excercice_type = excercice[3]

        if @excercice_type == "sets_n_reps"
            db = SQLite3::Database.open('db/db.sqlite')
            @amount = db.execute('SELECT sets, reps FROM users WHERE id IS ?', excercice[4]).first
        elsif @excercice_type == "time"
            # @amount = 
        elsif @excercice_type == "distance"
            # @amount = 
        end

        p @amount

    end

    # def self.get(user_id)
    #     db = SQLite3::Database.open('db/db.sqlite')
    #     schedule = []
    #     7.times do |day|
    #         # ---------------------------
    #         id_for_exercices = db.execute('SELECT excercice_id FROM schedules WHERE user_id IS ? AND day IS ?', [user_id, (day + 1)])
    #         dayly = []
    #         id_for_exercices.each do |x|
    #             dayly << db.execute('SELECT * FROM excercices WHERE id IS ?', x.first).first
    #         end

    #         custom_excercices = db.execute('SELECT * FROM custom_excercices WHERE user_id IS ? AND day IS ?', [user_id, day])
    #         custom_excercices.each do |x|
    #             dayly << x
    #         end

    #         version_two = []

    #         dayly.each do |excercice|
    #             version_two << Schedule.new(excercice)
    #         end

    #         schedule << version_two
    #     end

    #     return schedule
    # end

    def self.get2(user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        weekly_schedule = db.execute('SELECT * FROM weekly_schedules WHERE user_id IS ?', user_id)
        year = Time.now.strftime('%Y')
        week = Time.now.strftime('%W')

        if weekly_schedule == nil || weekly_schedule == [] || year.to_i != weekly_schedule.last[4].to_i || week.to_i != weekly_schedule.last[5].to_i
            # No weekly schedule for this user
            # Or it's outdated
            # Creates one

            original_schedule = db.execute('SELECT * FROM schedules WHERE user_id IS ?', user_id)

            original_schedule.each do |excercice|
                db.execute('INSERT INTO weekly_schedules (user_id, excercice_id, done, year, week, day, active) VALUES (?,?,?,?,?,?,?)', [user_id, excercice[3], "false", year, week, excercice[2], "true"])
            end
        end

        # Return the schedule
        schedule = []
        7.times do |day|
            excercices = db.execute('SELECT * FROM weekly_schedules WHERE user_id IS ? AND day IS ?', [user_id, (day + 1)])
            # id_for_exercices = db.execute('SELECT excercice_id FROM weekly_schedules WHERE user_id IS ? AND day IS ?', [user_id, (day + 1)])

            dayly = []
            excercices.each do |x|
                dayly << [db.execute('SELECT * FROM excercices WHERE id IS ?', x[2]).first, db.execute('SELECT done FROM weekly_schedules WHERE id IS ?', x[0]).first.first, x.first, db.execute('SELECT type FROM excercice_type WHERE id IS (SELECT excercice_type FROM excercices WHERE id IS ?)', x[2]).first.first, user_id]
            end

            temp = []
            dayly.each do |excercice|
                temp << Schedule.new(excercice)
            end

            schedule << temp
        end
        
        return schedule
    end

    def self.day_in_integer()
        day = Time.now.strftime('%A')
        weekdays = {
            "Monday" => 1,
            "Tuesday" => 2,
            "Wednesday" => 3,
            "Thursday" => 4,
            "Friday" => 5,
            "Saturday" => 6,
            "Sunday" => 7
        }
        return weekdays[day].to_i
    end

    def self.add_custom(day, excercice_name, user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('INSERT INTO custom_excercices (name, user_id, day) VALUES (?,?,?)', [excercice_name, user_id, day])
    end

    def self.check(id, session)
        db = SQLite3::Database.open('db/db.sqlite')
        year = Time.now.strftime('%Y')
        week = Time.now.strftime('%W')
        day = Time.now.strftime('%A')

        weekdays = {
            "Monday" => 1,
            "Tuesday" => 2,
            "Wednesday" => 3,
            "Thursday" => 4,
            "Friday" => 5,
            "Saturday" => 6,
            "Sunday" => 7
        }

        excercice = db.execute('SELECT * FROM weekly_schedules WHERE user_id IS ? AND id IS ?', [session[:user_id], id]).first

        if excercice[4].to_i == year.to_i && excercice[5].to_i == week.to_i && excercice[6].to_i == weekdays["#{day}"].to_i
            db.execute('UPDATE weekly_schedules SET done = ? WHERE id IS ?', ["true", id])
            session[:check_error] = false
            return true
        else
            # weekdays = {
            #     "Monday" => "Måndag",
            #     "Tuesday" => "Tisdag",
            #     "Wednesday" => "Onsdag",
            #     "Thursday" => "Torsdag",
            #     "Friday" => "Fredag",
            #     "Saturday" => "Lördag",
            #     "Sunday" => "Söndag"
            # }
            # day = weekdays["#{day}"]

            weekdays = {
                1 => "Måndag",
                2 => "Tisdag",
                3 => "Onsdag",
                4 => "Torsdag",
                5 => "Fredag",
                6 => "Lördag",
                7 => "Söndag"
            }

            day = weekdays[excercice[6].to_i]
            session[:check_error] = "Det är inte #{day} idag! Bra försök 😉"
            return false
        end
    end
    
    def self.get_goals()
        db = SQLite3::Database.open('db/db.sqlite')
        goals = db.execute('SELECT * FROM goals')
        output = []
        goals.each do |goal|
            output << [goal[0].to_i, goal[1]]
        end
        return output
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