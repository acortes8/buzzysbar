# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Beverage.delete_all

beverage_1 = Beverage.create!(
 title: 'Saturn',
 ingredient_section:
  '<ul>
    <li>1 1/4 ounces gin</li>
    <li>1/2 ounce lemon juice, freshly squeezed</li>
    <li>1/2 ounce passion fruit syrup*</li>
    <li>1/4 ounce falernum</li>
    <li>1/4 ounce orgeat</li>
    <li>Garnish: edible flower</li>
    <li>Garnish: orange twist</li>
  </ul>',
 instruction_section:
  '<ol>
    <li>Add the gin, lemon juice, passion fruit syrup, falernum and orgeat to a
    blender with crushed ice, and blend until smooth.</li>
    <li>Pour unstrained into a Tiki mug or highball glass.</li>
    <li>Garnish with an edible flower and an orange twist.</li>
  </ol>
  <p>*Passion fruit syrup: Mix 6 parts simple syrup to 1 part passion fruit
  puree.</p>',
 description:
  'One of the most famous gin-based Tiki cocktails. Though it uses the
  juniper-based spirit, it also includes many of the hallmarks of Tiki
  bartending: fresh juices, multiple syrups and a complicated, interesting
  history.'
)

beverage_1.featured_image.attach(io:
  File.open('app/assets/images/saturn.png'),
  filename: 'saturn.png',
  content_type: 'image/png')

beverage_2 = Beverage.create!(
 title: 'Hurricane',
 ingredient_section:
  '<ul>
    <li>2 ounces light rum</li>
    <li>2 ounces dark rum</li>
    <li>1 ounce lime juice, freshly squeezed</li>
    <li>1 ounce orange juice, freshly squeezed</li>
    <li>1/2 ounce passion fruit puree</li>
    <li>1/2 ounce simple syrup</li>
    <li>1 teaspoon grenadine</li>
    <li>Garnish: orange half-wheel</li>
    <li>Garnish: preserved cherry</li>
  </ul>',
 instruction_section:
  '<ol>
    <li>Add the light and dark rums, lime and orange juices, passion fruit
    puree, simple syrup and grenadine into a shaker with ice and shake well
    until well-chilled.</li>
    <li>Strain into a large Hurricane glass over fresh ice.</li>
    <li>Garnish with an orange half-wheel and a preserved cherry.</li>
  </ol>',
 description:
  "The Hurricane is not a cocktail of subtlety. Its double serving of rum and
  suite of fruit juices and sweeteners have been packing a punch since the early
  1940s, when it was invented at Pat O'Brein's in New Orleans."
)

beverage_2.featured_image.attach(io:
  File.open('app/assets/images/hurricane.png'),
  filename: 'hurricane.png',
  content_type: 'image/png')

beverage_3 = Beverage.create!(
  title: "Smuggler's Cove Hurricane",
  ingredient_section:
    '<ul>
      <li>4 ounces black blended or black pot-still rum</li>
      <li>2 ounces lemon juice, freshly squeezed</li>
      <li>2 ounces passion fruit syrup</li>
      <li>Garnish: lemon wheel</li>
      <li>Garnish: cocktail umbrella</li>
    </ul>',
  instruction_section:
    '<ol>
      <li>Add all the ingredients into a shaker with 12 oz of crushed ice and
      4-6 small pieces of cubed ice, and shake until well-chilled.</li>
      <li>Pour into a Hurricane glass over crushed ice.</li>
      <li>Garnish with a lemon wheel and cocktail umbrella.</li>
    </ol>',
  description:
    "Black rum was touted after Prohibition as a great base for punch. It works
    especially well in the class Hurriance, where its richness is offset by
    tangy lemon and passion fruit. This version is from framed San Francisco
    Tiki bar Smuggler's Cove."
)

beverage_3.featured_image.attach(io:
  File.open('app/assets/images/smugglers_cove_hurricane.png'),
  filename: 'smugglers_cove_hurricane.png',
  content_type: 'image/png')
