import gleam/int
import gleam/io
import argv
import day1
import day2
import day3

pub fn main() {
  let result = case argv.load().arguments {
    ["day1", input] -> day1.run(input)
    ["day2", input] -> day2.run(input)
    ["day3", input] -> day3.run(input)
    [unrecognized, input] -> {
      io.println_error("Not implemented: " <> unrecognized)
      panic
    }
    _ -> {
      io.println_error("Usage: aoc_2024 <day> <input>")
      panic
    }
  }

  case result {
    Ok(solution) -> {
      io.println("Part 1: " <> int.to_string(solution.part1))
      io.println("Part 2: " <> int.to_string(solution.part2))
    }
    Error(e) -> io.println_error("ERR: " <> e)
  }
}
