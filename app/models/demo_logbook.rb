# Builds the demo logbook that portfolio visitors sign in to: made-up people,
# bars, occasions, tastings and ratings. reset! clears it and builds it again,
# so anything visitors change only lasts until the next reset. It also signs
# out visitors who started more than a day ago, so sessions don't pile up.
class DemoLogbook
  NAME = "Demo"
  USER_NAME = "Demo"
  EMAIL_ADDRESS = "demo@buzzysbar.com"

  # The demo user logs drinks as "You".
  PEOPLE = [ "You", "Maya", "Theo", "Priya", "Sam" ]

  PLACES = {
    "The Coconut Lantern" => :bar,
    "Lava Room" => :bar,
    "The Driftwood" => :bar,
    "Maya's place" => :home
  }

  DRINKS = {
    "Mai Tai" => "Aged rum, lime, orange curaçao and orgeat.",
    "Zombie" => "Several rums, lime, grapefruit and cinnamon. Famously strong.",
    "Jungle Bird" => "Dark rum, Campari, pineapple and lime.",
    "Painkiller" => "Rum, pineapple, orange and cream of coconut, with nutmeg on top.",
    "Navy Grog" => "Three rums with grapefruit, lime and honey.",
    "Saturn" => "A gin tiki drink with passion fruit, falernum and orgeat.",
    "Hurricane" => "Rum and passion fruit, from New Orleans.",
    "Daiquiri" => "Rum, lime and sugar."
  }

  # Each tasting is [ drink, notes, { person => score } ].
  OCCASIONS = [
    { days_ago: 3, place: "The Coconut Lantern", people: %w[ You Maya Theo ], notes: "Birthday drinks for Theo.",
      tastings: [
        [ "Mai Tai", "Big hit with everyone.", { "You" => 4.5, "Maya" => 4, "Theo" => 5 } ],
        [ "Jungle Bird", nil, { "Maya" => 3.5 } ],
        [ "Painkiller", nil, { "Theo" => 4, "You" => 3.5 } ]
      ] },
    { days_ago: 12, place: "Maya's place", people: %w[ You Maya Priya ], notes: "Tried making orgeat from scratch.",
      tastings: [
        [ "Mai Tai", "Homemade orgeat makes a difference.", { "You" => 4, "Maya" => 4.5, "Priya" => 4 } ],
        [ "Daiquiri", nil, { "Priya" => 4.5 } ]
      ] },
    { days_ago: 26, place: "Lava Room", people: %w[ You Sam ], notes: nil,
      tastings: [
        [ "Zombie", "Limit of two per person, and they mean it.", { "You" => 4, "Sam" => 4.5 } ],
        [ "Navy Grog", nil, { "Sam" => 3 } ]
      ] },
    { days_ago: 40, place: "The Driftwood", people: %w[ You Maya Theo Priya Sam ], notes: "The whole crew came out.",
      tastings: [
        [ "Hurricane", "Too sweet for most of us.", { "Theo" => 3, "Priya" => 3.5 } ],
        [ "Saturn", nil, { "You" => 5, "Maya" => 4.5 } ],
        [ "Painkiller", nil, { "Sam" => 4 } ]
      ] },
    { days_ago: 55, place: "The Coconut Lantern", people: %w[ You Priya ], notes: nil,
      tastings: [
        [ "Saturn", nil, { "Priya" => 4 } ],
        [ "Zombie", nil, {} ]
      ] },
    { days_ago: 70, place: "Maya's place", people: %w[ You Maya ], notes: "Rainy night in.",
      tastings: [
        [ "Painkiller", "Fresh nutmeg is worth it.", { "Maya" => 4.5 } ]
      ] },
    { days_ago: 88, place: "Lava Room", people: %w[ You Theo Sam ], notes: nil,
      tastings: [
        [ "Jungle Bird", nil, { "Theo" => 4, "Sam" => 3.5 } ],
        [ "Mai Tai", "Not as good as The Coconut Lantern's.", { "Theo" => 3 } ]
      ] }
  ]

  def self.reset!
    new.reset!
  end

  def self.user
    User.find_by(email_address: EMAIL_ADDRESS)
  end

  def reset!
    ActiveRecord::Base.transaction do
      clear
      build
      user.sessions.where(created_at: ...1.day.ago).delete_all
    end
    logbook
  end

  private
    def user
      @user ||= self.class.user || Logbook.create!(name: NAME).users.create!(
        name: USER_NAME, email_address: EMAIL_ADDRESS, password: SecureRandom.base58(24))
    end

    def logbook
      user.logbook
    end

    def clear
      logbook.occasions.destroy_all
      logbook.people.destroy_all
      logbook.places.destroy_all
      Recipe.where(drink: logbook.drinks).destroy_all
      logbook.drinks.destroy_all
      logbook.books.destroy_all
      logbook.users.where.not(id: user.id).destroy_all
    end

    def build
      people = PEOPLE.index_with { |name| logbook.people.create!(name: name, user: (user if name == "You")) }
      places = PLACES.to_h { |name, kind| [ name, logbook.places.create!(name: name, kind: kind) ] }
      drinks = DRINKS.to_h { |name, description| [ name, logbook.drinks.create!(name: name, description: description) ] }

      OCCASIONS.each do |details|
        occasion = logbook.occasions.create!(place: places.fetch(details[:place]), occurred_on: Date.current - details[:days_ago],
          notes: details[:notes], people: details[:people].map { |name| people.fetch(name) })

        details[:tastings].each do |drink, notes, scores|
          tasting = occasion.tastings.create!(drink: drinks.fetch(drink), notes: notes)
          scores.each { |name, score| tasting.ratings.create!(person: people.fetch(name), score: score) }
        end
      end
    end
end
