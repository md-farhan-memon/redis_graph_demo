def find_id(url)
  url.split('/').last.to_i
end

def house_filter_data(house)
  house.slice('name', 'region', 'coatOfArms', 'words', 'titles', 'seats', 'founded', 'diedOut', 'ancestralWeapons').merge(
    'id' => find_id(house['url']),
    'currentLord' => find_id(house['currentLord']),
    'heir' => find_id(house['heir']),
    'overlord' => find_id(house['overlord']),
    'founder' => find_id(house['founder']),
    'cadetBranches' => house['cadetBranches'].map { |a| find_id(a) }.compact,
    'swornMembers' => house['swornMembers'].map { |a| find_id(a) }.compact
  )
end

houses_filtered_data = houses.map { |h| house_filter_data(h) }

def book_filter_data(book)
  book.slice('name', 'isbn', 'authors', 'numberOfPages', 'publisher', 'country', 'mediaType', 'released').merge(
    'id' => find_id(book['url']),
    'characters' => book['characters'].map { |a| find_id(a) },
    'povCharacters' => book['povCharacters'].map { |a| find_id(a) }
  )
end

books_filtered_data = books.map do |book|
  book_filter_data(book)
end

def char_filter_data(char)
  char.slice('name', 'gender', 'culture', 'born', 'died', 'titles', 'aliases', 'tvSeries', 'playedBy').merge(
    'id' => find_id(char['url']),
    'father' => find_id(char['father']),
    'mother' => find_id(char['mother']),
    'spouse' => find_id(char['spouse']),
    'allegiances' => char['allegiances'].map { |a| find_id(a) },
    'books' => char['books'].map { |a| find_id(a) },
    'povBooks' => char['povBooks'].map { |a| find_id(a) }
  )
end

characters_filtered_data = characters.map do |char|
  filter_data(char)
end

hash = JSON.parse(File.read('characters.json'))
reqd_characters = hash.map { |h| h.slice('name', 'gender', 'culture', 'id') if !h['name'].empty? && !h['gender'].empty? }.compact

hash = JSON.parse(File.read('books.json'))
reqd_books = hash.map { |h| h.slice('name', 'isbn', 'numberOfPages', 'publisher', 'country', 'released', 'id', 'authors') }

hash = JSON.parse(File.read('houses.json'))
temp_hash = JSON.parse(File.read('temp_house.json'))
reqd_houses = hash.map { |h| h.slice('name', 'region', 'coatOfArms', 'words', 'id') if !h['name'].empty? && !h['region'].empty? }.compact
belong = hash.map do |house|
  temp_house = temp_hash.select { |h| h['name'] == house['name'] }.first
  puts "-------------------------------"
  next if temp_house.nil?

  # puts house
  # puts temp_house

  rel = []
  if house['currentLord'].nonzero? && !house['currentLord'].to_s.empty?
    rel << { 'character' => house['currentLord'], 'house' => temp_house['id'], 'relation' => 'Current Lord' }
  end

  if house['heir'].nonzero? && !house['heir'].to_s.empty?
    rel << { 'character' => house['heir'], 'house' => temp_house['id'], 'relation' => 'Heir' }
  end

  if house['overlord'].nonzero? && !house['overlord'].to_s.empty?
    puts house
    puts temp_house.class
    rel << {
      'character' => house['overlord'],
      'house' => temp_house['id'],
      'relation' => 'Over Lord'
    }
  end

  if house['founder'].nonzero? && !house['founder'].to_s.empty?
    rel << { 'character' => house['founder'], 'house' => temp_house['id'], 'relation' => 'Founder' }
  end

  if !house['swornMembers'].to_s.empty?
    house['swornMembers'].each do |member|
      next if member.to_s.empty? || member.zero?

      rel << { 'character' => member, 'house' => temp_house['id'], 'relation' => 'Sworn Member' }
    end
  end

  rel.select { |h| !h['character'].to_s.empty? && !h['house'].to_s.empty? && !h['relation'].to_s.empty? }
  # rel
end
