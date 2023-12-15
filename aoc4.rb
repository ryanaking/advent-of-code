require "set"

def find_matches(winning_numbers, my_numbers)
  winning_numbers.intersection(my_numbers)
end

def parse_line(line)
  card_id = line[5..line.index(':')-1].to_i
  winning_numbers = line[(line.index(':')+1)..line.index('|')-1].split.to_set
  my_numbers = line[line.index('|')..-1].split.to_set
  [card_id, winning_numbers, my_numbers]
end

def build_cards_map(filename)
  cards = {}
  File.open(filename).each do |line|
    card_id, winning_numbers, my_numbers = parse_line(line)
    cards[card_id] = [winning_numbers, my_numbers]
  end
  cards
end

def total_scratchcards(filename)
  # initialize the structures
  cards_map = build_cards_map(filename)
  scratch_card_instances = {}
  cards_map.each_key do |card_id|
    scratch_card_instances[card_id] ||= 1
  end
  card_matches = {}
  cards_map.each_pair do |card_id, numbers|
    card_matches[card_id] = find_matches(numbers[0], numbers[1])
    #puts "found #{card_matches[card_id].size} for card #{card_id}"
  end

  # for each card ID
  cards_map.each_key do |card_id|
    # for each instance of the card id
    scratch_card_instances[card_id].times do
      # increment the instances of the N cards below us
      ((card_id + 1)..(card_id + card_matches[card_id].size)).each do |cid|
        if cid <= cards_map.size
          scratch_card_instances[cid] += 1
        end
      end
    end
  end

  # final result structure
  puts scratch_card_instances
  scratch_card_instances
end

def points_for_card(card_id, winning_numbers, my_numbers)
  matches = find_matches(winning_numbers, my_numbers)
  if matches.size > 1
    #puts "card #{card_id} has #{matches.size} matches, adding #{2**(matches.size-1)}"
    return 2 ** (matches.size - 1)
  elsif matches.size == 1
    #puts "card #{card_id} has #{matches.size} matches, adding 1"
    return 1
  end
  return 0
end

def sum_of_card_points(filename)
  points = 0

  build_cards_map(filename).each_pair do |card_id, numbers|
    points += points_for_card(card_id, numbers[0], numbers[1])
  end

  points
end

def count_total_scratchcards(filename)
  total_scratchcards(filename).values.inject(:+)
end

# first part
#sum_of_card_points('aoc4.txt')
# second part
count_total_scratchcards('aoc4.txt')