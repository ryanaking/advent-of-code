module AdventOfCode
  module Utils
    def leading_zero(i)
      "#{"%02d" % (i)}"
    end

    def day_class_suffix(day)
      "Day#{leading_zero(day)}"
    end

    def day_class_string(day, year)
      "AdventOfCode::Year#{year}::#{day_class_suffix(day)}"
    end

    def day_class(day, year)
      Object.const_get(day_class_string(day, year))
    end

    def input_filename(day, year)
      File.join(
        expanded_directory,
        "#{year}/input/day_#{leading_zero(day)}.txt",
      )
    end

    def ruby_filename(day, year)
      File.join(
        expanded_directory,
        "#{year}/code/day_#{leading_zero(day)}.rb",
      )
    end

    def test_filename(day, year)
      File.join(
        expanded_directory,
        "#{year}/test/day_#{leading_zero(day)}.rb",
      )
    end

    def expanded_directory
      File.expand_path(File.dirname(__FILE__))
    end
  end
end
