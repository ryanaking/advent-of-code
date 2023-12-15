SYMBOLS = "'!@#$%^&*()-_+=[]{}\\|;:'\"/?>,<~`"

SYMBOL_REGEX = /[\'\!\@\#\$\%\^\&\*\(\)\-\_\+\=\[\]\{\}\\\|\;\:\'\"\/\?\>\,\.\<\~\`]/

# builds a list of symbol positions for the line
# yields an array like
# [0, 5, 7]
def build_symbol_positions(line)
  pos = 0
  positions = []
  line.each_char do |c|
    if SYMBOLS.include?(c)
      # record the position of the symbol
      positions << pos
    end
    pos += 1
  end
  positions
end

# builds a list of STAR symbol positions for the line
# yields an array like
# [0, 5, 7]
def build_star_symbol_positions(line)
  pos = 0
  positions = []
  line.each_char do |c|
    if c == '*'
      # record the position of the star
      positions << pos
    end
    pos += 1
  end
  positions
end


# builds all the part numbers on the line and what position on their line that each instance
# of that part number starts/ends
# this will yield a hash like
# {
#   617 => [[0,3]],
#   819 => [[3,6], [7,9]],
#   ...
# }
def build_part_numbers(line)
  pos = 0
  h = {}
  line.split(SYMBOL_REGEX).each do |item|
    if item.to_i > 0
      end_pos = pos + item.to_i.to_s.length
#      puts "#{item} at #{pos}, #{end_pos}"
      h[item.to_i] ||= Array.new
      h[item.to_i] << [pos, end_pos - 1]
    end
    pos += item.length + 1
  end
  h
end

def build_maps(filename)
  part_number_map = {}
  symbol_map = {}
  star_symbol_map = {}
  line_number = 0

  File.open(filename).each do |line|
    part_number_map[line_number] = build_part_numbers(line)
    symbol_map[line_number] = build_symbol_positions(line)
    star_symbol_map[line_number] = build_star_symbol_positions(line)
    line_number += 1
  end

  puts part_number_map
#  puts symbol_map
  puts star_symbol_map

  return part_number_map, symbol_map, star_symbol_map
end

def is_valid_for_line?(start_position, end_position, symbol_line_map)
#  puts "checking if valid for line #{symbol_line_map.to_s} at #{start_position} #{end_position}"
  if symbol_line_map
    symbol_line_map.each do |symbol_pos|
#      puts "checking symbol_pos #{symbol_pos} against #{start_position-1}, #{end_position+1}"
      return true if symbol_pos >= (start_position - 1) && symbol_pos <= (end_position + 1)
    end
  end
  return false
end

# figure out how many valid positions a given part number has in the line
def valid_positions(positions, line_number, symbol_map)
  num = 0
  positions.each do |position|
    start_position = position[0]
    end_position = position[1]
    # if the symbol map contains an "adjacent" symbol to the start/end position
    # adjacent means +/- 1 line and +/- 1 spot from start/end
  #  puts "checking is_valid_for_line for line number #{line_number} at #{start_position}, #{end_position}"
    num += 1 if is_valid_for_line?(start_position, end_position, symbol_map[line_number])
    if line_number != 0
      num += 1 if is_valid_for_line?(start_position, end_position, symbol_map[line_number - 1])
    end
    num +=1 if is_valid_for_line?(start_position, end_position, symbol_map[line_number + 1])
  end

  #  puts "not valid for line #{line_number}"
  return num
end

def sum_valid_part_numbers(part_number_map, symbol_map)
  sum = 0
  part_number_map.each_pair do |line_number, part_number_map_for_line|
    part_number_map_for_line.each_pair do |part_number, positions|
     v = valid_positions(positions, line_number, symbol_map)
     puts "part number #{part_number} has #{v} valid positions"
     sum += part_number * v
    end
  end
  sum
end

def is_adjacent?(star_line, star_position, part_line, part_start, part_end)
  if part_line >= star_line - 1 && part_line <= star_line + 1
    if star_position >= part_start - 1 && star_position <= part_end + 1
      puts "part = #{part_line}, #{part_start}, #{part_end} is adjacent to star"
      return true
    end
  end
  false
end

# given a star at the given line number and position, find all the adjacent part numbers
def find_gear_part_numbers(part_number_map, star_line_number, star_position)
  gear_part_numbers = []
  part_number_map.each_pair do |line_number, part_number_map_for_line|
    part_number_map_for_line.each_pair do |part_number, positions|
      positions.each do |position|
        if is_adjacent?(star_line_number, star_position, line_number, position[0], position[1])
          puts "part number #{part_number} is adjacent to this star"
          gear_part_numbers << part_number
        end
      end
    end
  end
  return gear_part_numbers
end

def gear_ratio(part_number_map, star_line_number, star_position)
  puts "finding gear_ratio for star at line #{star_line_number}, position #{star_position}"
  gear_part_numbers = find_gear_part_numbers(part_number_map, star_line_number, star_position)
  if gear_part_numbers.size > 1
    gear_part_numbers.inject(:*)
  else
    0
  end
end

# go through every star in the star map
# for each star, collect any adjacent numbers that form a "gear"
# multiply all the adjacent gear numbers together if there are more than 1 to get all the gear ratios
# sum up all the gear ratios
def sum_valid_gear_ratios(part_number_map, star_symbol_map)
  total_gear_ratios = 0
  star_symbol_map.each_pair do |line_number, star_positions_in_line|
    star_positions_in_line.each do |star_position|
      r = gear_ratio(part_number_map, line_number, star_position)
      if r > 0
        puts "found gear ratio #{r}"
        total_gear_ratios += r
      end
    end
  end
  total_gear_ratios
end

def sum_of_part_numbers(filename)
  m1, m2, m3 = build_maps(filename)
  sum_valid_part_numbers(m1, m2)
end

def sum_of_gear_ratios(filename)
  m1, m2, m3 = build_maps(filename)
  sum_valid_gear_ratios(m1, m3)
end

sum_of_gear_ratios('sample3.txt')