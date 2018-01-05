class Friends
    def self.send(sender, reciever)
        db = SQLite3::Database.open('db/db.sqlite')

        # Check if already friends
        possibility1 = db.execute('SELECT * FROM friends WHERE user_1 IS ? AND user_2 IS ? AND status IS ?' [sender, reciever, "accepted"])
        possibility2 = db.execute('SELECT * FROM friends WHERE user_1 IS ? AND user_2 IS ? AND status IS ?' [reciever, sender, "accepted"])

        if possibility1 == nil && possibility2 == nil
            # Not friends

            # Already a request/rejected request?
            possibility1 = db.execute('SELECT * FROM friends WHERE user_1 IS ? AND user_2 IS ?' [sender, reciever])

            if possibility1 != nil
                # Already a request, update it
            end

            possibility2 = db.execute('SELECT * FROM friends WHERE user_1 IS ? AND user_2 IS ?' [reciever, sender])

            if possibility2 != nil
                # Already a request, update it
            end

            # No previous requests, add a new one
            db.execute('INSERT INTO friends SET (user_1, user_2, status) VALUES (?,?,?)', [sender, reciever, "pending"])
        else
            # Already friends
        end

    end
end