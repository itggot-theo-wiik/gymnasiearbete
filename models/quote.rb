class Quote
    def self.random()
        quotes = ["Du kan göra allt om du vill.", "Ge aldrig upp!", "Imorgon är en ny dag!"]
        return quotes.sample
    end
end