class Weight
    def self.percentage_of_goal_reached(user_id, session)
        db = SQLite3::Database.open('db/db.sqlite')
        goal = db.execute('SELECT weight_goal FROM users WHERE id IS ?', user_id).first.first
        current_weight = db.execute('SELECT kg FROM weights WHERE user_id IS ?', user_id)[-1]
        initial_weight = db.execute('SELECT kg FROM weights WHERE user_id IS ?', user_id)

        p current_weight
        p initial_weight
        p goal

        if goal == nil || current_weight == nil
            if current_weight == nil
                session[:error_no_logged_weight] = true
            else
                session[:error_no_logged_weight] = false
            end

            if goal == nil
                session[:error_no_goal] = true
            else
                session[:error_no_goal] = false
            end

            return false
        end
        
        session[:error_no_logged_weight] = false
        session[:error_no_goal] = false

        percentage_reached = ((initial_weight.first.first - current_weight.first)/(initial_weight.first.first - goal))

        return (percentage_reached * 100).to_i
    end

    def self.add(weight, weight_goal, session)
        db = SQLite3::Database.open('db/db.sqlite')

        p "¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤4"
        p weight
        p weight_goal
        p "¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤4"

        if weight != 0.0
            # Add the current weight
            if weight <= 0 || weight > 635
                return false
            else
                date = Time.now.strftime("%Y-%m-%d %H:%M")
                id = session[:user_id]
                db.execute('INSERT INTO weights (kg, date, user_id) VALUES (?,?,?)', [weight, date, id])
                return true
            end
        elsif weight_goal
            # Update the weight goal
            puts "IM HERE"

            if weight_goal > 0 && weight_goal < 9999
                db.execute('UPDATE users SET weight_goal = ? WHERE id IS ?', [weight_goal.to_f, session[:user_id].to_i])
                return true
            else
                return false
            end
        end
    end

    def self.get_goal(id)
        db = SQLite3::Database.open('db/db.sqlite')
        return db.execute('SELECT weight_goal FROM users WHERE id IS ?', id).first.first
    end
end