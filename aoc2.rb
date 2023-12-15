# "3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"

def to_games(s)
 s.split('; ') 
end

def colors(game)
  colors = {
     'red' => 0,
     'green' => 0,
     'blue' => 0
  }
  game.split(', ').each do |color|
     colors[color.split(' ')[1]] = color.split(' ')[0].to_i
  end
  colors.values
end

def minimum_viable_colors(game_set)
  largest_red = largest_green = largest_blue = 0

  games = to_games(game_set)
  games.each do |game|
    red, green, blue = colors(game)
    largest_red = [red, largest_red].max
    largest_green = [green, largest_green].max
    largest_blue = [blue, largest_blue].max
  end

  [largest_red, largest_green, largest_blue]
end

def cube_power(game_set)
  mvc = minimum_viable_colors(game_set)
  mvc[0] * mvc[1] * mvc[2]
end

def is_possible?(game_set, num_red, num_green, num_blue)
  mvc = minimum_viable_colors(game_set)
  return mvc[0] <= num_red && mvc[1] <= num_green && mvc[2] <= num_blue 
end

def parse_line(line)
  game_id = line[5..line.index(':')-1].to_i
  game_set = line[line.index(':')+1..-1]
  [game_id, game_set]
end

def sum_of_possible_game_ids(filename)
  sum = 0

  File.open(filename).each do |line|
     game_id, game_set = parse_line(line)
     if is_possible?(game_set, 12, 13, 14)
       sum += game_id
     end
  end
 
  sum
end

def sum_of_cube_powers(filename)
  sum = 0

  File.open(filename).each do |line|
    game_id, game_set = parse_line(line)
    sum += cube_power(game_set)   
  end
  
  sum
end

sum_of_cube_powers('aoc2.txt')
