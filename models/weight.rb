class Weight

    def self.percentage_of_goal_reached(user_id, session)
        db = SQLite3::Database.open('db/db.sqlite')
        goal = db.execute('SELECT weight_goal FROM users WHERE id IS ?', user_id)
        current_weight = db.execute('SELECT kg FROM weights WHERE user_id IS ?', user_id)[-1]
        initial_weight = db.execute('SELECT kg FROM weights WHERE user_id IS ?', user_id)

        if goal.first.first == nil
            session[:error_no_logged_weight] = true
            return false
        end

        if current_weight.first == nil
            session[:error_no_goal] = true
            return false
        end
        
        session[:error_no_logged_weight] = false
        session[:error_no_goal] = false

        percentage_reached = ((initial_weight.first.first - current_weight.first)/(initial_weight.first.first - goal.first.first))

        if percentage_reached < 0.1
            return "mindre än 10 procent"
        elsif percentage_reached > 1
            return "jaaaa, du har nått ditt mål"
        else
            return " #{(percentage_reached * 100)}% "
        end

    end
    
end