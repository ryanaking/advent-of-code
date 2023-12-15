
module AdventOfCode
  module Year2023
    class AdventOfCode::Year2023::Day07

      def initialize(filename)
        @hands = []
        File.open(filename).each do |line|
          @hands << {
            :cards => line[0..4],
            :bid => line[6..-1].to_i
          }
        end
        rank_hands
      end

      # cards and their rank order
      CARD_RANKS = {
        'A' => '01',
        'K' => '02',
        'Q' => '03',
        'T' => '04',
        '9' => '05',
        '8' => '06',
        '7' => '07',
        '6' => '08',
        '5' => '09',
        '4' => '10',
        '3' => '11',
        '2' => '12',
        'J' => '13',
      }

      # labels of hands
      FIVE_OF_KIND = 1
      FOUR_OF_KIND = 2
      FULL_HOUSE = 3
      THREE_OF_KIND = 4
      TWO_PAIR = 5
      ONE_PAIR = 6
      HIGH_CARD = 7
      UNKNOWN = 8

      def label_hand!(hand)
        hand[:type] = UNKNOWN

        hand[:card_ranks] = hand[:cards].split('').collect { |card| CARD_RANKS[card] }.join

        hand[:card_counts] = {}

        # count number of each type of card in the hand, except jokers
        hand[:cards].each_char do |char|
          if char != 'J'
            hand[:card_counts][char] ||= 0
            hand[:card_counts][char] += 1
          end
        end
        num_jokers = hand[:cards].count('J')
        largest_card_count = hand[:card_counts].values.max || 0

        # figure out what kind of hand we have
        hand[:type] = if largest_card_count + num_jokers == 5
                        FIVE_OF_KIND
                      elsif largest_card_count + num_jokers == 4
                        FOUR_OF_KIND
                      elsif largest_card_count == 3 && hand[:card_counts].values.count(2) > 0 ||
                        hand[:card_counts].values.count(2) > 1 && num_jokers > 0
                        FULL_HOUSE
                      elsif largest_card_count + num_jokers == 3
                        THREE_OF_KIND
                      elsif hand[:card_counts].values.count(2) == 2 ||
                        largest_card_count == 1 && num_jokers == 2
                        TWO_PAIR
                      elsif largest_card_count == 2 || num_jokers == 1
                        ONE_PAIR
                      else
                        HIGH_CARD
                      end
        nil
      end

      def rank_hands
        # label hands first
        @hands.each do |hand|
          label_hand!(hand)
        end

        # now sort hands according to the label and the card ranks
        @hands.sort_by! { |hand| hand[:type].to_s + hand[:card_ranks] }.reverse!
      end

      def total_winnings
        total = 0

        @hands.each_with_index do |hand, i|
          total += (i + 1) * hand[:bid]
        end

        total
      end
    end
  end
end

a = AdventOfCode::Year2023::Day07.new('aoc7.txt')
a.total_winnings