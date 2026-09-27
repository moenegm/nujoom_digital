# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Nujoom Digital's own booking calendar — single provider (Mohamed).
provider = Provider.find_or_create_by!(email: "mr.negm90@gmail.com") do |p|
  p.name = "Nujoom Digital"
end

# Oman's work week is Sunday–Thursday (weekend is Friday–Saturday).
# Ruby's Date#wday: Sunday=0, Monday=1, ... Thursday=4, Friday=5, Saturday=6.
(0..4).each do |day_of_week|
  provider.availabilities.find_or_create_by!(day_of_week: day_of_week) do |a|
    a.start_time = "10:00"
    a.end_time = "16:00"
  end
end

puts "Seeded provider '#{provider.name}' (#{provider.email}) with #{provider.availabilities.count} availability windows."
