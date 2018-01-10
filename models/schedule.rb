class Schedule

    attr_reader :id, :excercice_id, :name, :done, :excercice_type, :amount

    def initialize(excercice)
        @id = excercice[2]
        @user_id = excercice[4]
        @excercice_id = excercice[0][0]
        @name = excercice[0][1]
        @done = excercice[1]

        @excercice_type = excercice[3]

        if @excercice_type == "sets_n_reps"
            db = SQLite3::Database.open('db/db.sqlite')
            # @amount = db.execute('SELECT sets, reps FROM users WHERE id IS ?', excercice[4]).first
            user_id = db.execute('SELECT id FROM users WHERE id IS (SELECT user_id FROM weekly_schedules WHERE id IS ?)', @id.to_i).first.first
            @amount = Schedule.calc_sets_and_reps(user_id, @excercice_id.to_i, 3)
        elsif @excercice_type == "time"
            # @amount = 
        elsif @excercice_type == "distance"
            @amount = Schedule.calc_distance(@user_id.to_i)
        end

        # p @amount

    end

    def self.get2(user_id, non_completed_only = false)
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
            if non_completed_only
                # Only un-completed excercices
                excercices = db.execute('SELECT * FROM weekly_schedules WHERE user_id IS ? AND day IS ? AND year IS ? AND week IS ? AND done IS ?', [user_id, (day + 1), year, week, "false"])
            else
                excercices = db.execute('SELECT * FROM weekly_schedules WHERE user_id IS ? AND day IS ? AND year IS ? AND week IS ?', [user_id, (day + 1), year, week])
            end
            

            dayly = []
            excercices.each do |x|
                # [names of the excercices, bla, bla, type of excercice, user id]
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

    def self.check(id, session, feedback = nil)
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
            if feedback
                feedback = feedback.to_i
            else
                feedback = 2
            end

            db.execute('UPDATE weekly_schedules SET done = ?, feedback = ? WHERE id IS ?', ["true", feedback.to_i, id])
            session[:check_error] = false
            return true
        else
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
                        # (i += backup[2].to_i) will make it so that it will contuine the loop, and thus making it possible to have a more difficult schedule than intended
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

    def self.calc_sets_and_reps(user_id, excercice_id, step)
        db = SQLite3::Database.open('db/db.sqlite')
        goal_sets_n_reps = db.execute('SELECT sets, reps FROM goals WHERE id IS (SELECT goal_id FROM users WHERE id IS ?)', user_id).first
        sets_limits = db.execute('SELECT min_sets, max_sets FROM goals WHERE id IS (SELECT goal_id FROM users WHERE id IS ?)', user_id).first
        reps_limits = db.execute('SELECT min_reps, max_reps FROM goals WHERE id IS (SELECT goal_id FROM users WHERE id IS ?)', user_id).first
        feedback = db.execute('SELECT feedback FROM weekly_schedules WHERE user_id IS ? AND active = ? AND excercice_id = ?', [user_id, "true", excercice_id])
    
        p goal_sets_n_reps
        p sets_limits
        p reps_limits

        # Change the sets and reps based on difficulty

        feedback.each do |x|
            if x.first != nil
                if x.first == 1
                    # To easy
                    if (goal_sets_n_reps[1] + step) > reps_limits[1]
                        # To many reps, needs to higher the sets
                        if (goal_sets_n_reps[0] + 1) > sets_limits[1]
                            # It will be over the maximum amount of sets allowed, sets the reps to the max.
                            goal_sets_n_reps[1] = reps_limits[1]                            
                        else
                            # Adds set
                            goal_sets_n_reps[0] += 1
                            # Sets rep to what its supposed to be
                            goal_sets_n_reps[1] = ((step - (reps_limits[1] - goal_sets_n_reps[1])) + (reps_limits[0] - 1))
                            # ((adderade - (högsta - nuvarande)) + (minsta - 1))
                        end

                    else
                        goal_sets_n_reps[1] += step
                    end
                elsif x.first == 3
                    # To hard
                    if (goal_sets_n_reps[1] - step) < reps_limits[0]
                        # To little reps, needs to lower the sets
                        if (goal_sets_n_reps[0] - 1) < sets_limits[0]
                            # It will be under the minimum amount of sets allowed, sets the reps to the lowest possible.
                            goal_sets_n_reps[1] = reps_limits[0]
                        else
                            goal_sets_n_reps[0] -= 1
                            # Sets rep to what its supposed to be
                            goal_sets_n_reps[1] = (( - step + (goal_sets_n_reps[1] - reps_limits[0])) + (reps_limits[1] + 1))
                            # (-adderade + (nuvarande - minsta) + (högsta + 1))
                        end
                    else
                        goal_sets_n_reps[1] -= step
                    end
                end
            end
        end

        p "under mig B"
        p goal_sets_n_reps
        
        return goal_sets_n_reps

    end

    def self.calc_distance(user_id)
        db = SQLite3::Database.open('db/db.sqlite')
        feedback = db.execute('SELECT feedback FROM weekly_schedules WHERE feedback_active IS ? AND user_id IS ? AND excercice_id IN (SELECT id FROM excercices WHERE excercice_type IS (SELECT id FROM excercice_type WHERE type IS ?))', ["true", user_id, "distance"])
        distance = 5
        feedback.each do |x|
            if x.first == 1
                # Too easy
                distance += 0.15
            elsif x.first == 3
                # To hard
                distance -= 0.15
            end  
        end
        return distance
    end

    def self.get_goals()
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT * FROM goals')
    end

    def self.add_goal(name,sets,reps,distance,time)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('INSERT INTO goals (name, sets, reps, distance, time) VALUES (?,?,?,?,?)', [name,sets,reps,distance,time])
    end

end