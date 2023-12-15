
ENGLISH_NUMBERS = { 
   'one' => 1,
   'two' => 2,
   'three' => 3,
   'four' => 4,
   'five' => 5,
   'six' => 6,
   'seven' => 7,
   'eight' => 8,
   'nine' => 9,
   '1' => 1,
   '2' => 2,
   '3' => 3,
   '4' => 4,
   '5' => 5,
   '6' => 6,
   '7' => 7,
   '8' => 8,
   '9' => 9
}

ENGLISH_NUMBERS_REGEX = /[0-9]|one|two|three|four|five|six|seven|eight|nine|ten/

def first_number_til_end(line)
 line[line.index(ENGLISH_NUMBERS_REGEX)..-1]
end

def last_number_til_end(line)
 line[line.rindex(ENGLISH_NUMBERS_REGEX)..-1]
end

def first_number(line)
  ENGLISH_NUMBERS.each_pair do |key, value|
    if first_number_til_end(line).start_with?(key)
        return value
    end
  end
end

def last_number(line)
  ENGLISH_NUMBERS.each_pair do |key, value|
    if last_number_til_end(line).start_with?(key)
        return value
    end
  end
end


def calibration_value(line)
  (first_number(line).to_s + last_number(line).to_s).to_i
end

sum = 0

File.open('aoc1.txt').each do |line|
  sum += calibration_value(line)
end
