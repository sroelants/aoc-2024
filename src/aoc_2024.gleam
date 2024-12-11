import gleam/int
import gleam/io
import argv
import day1
import day2
import day3
import day4
import day5
import day6
import day7
import day8
import day9
import day10
import day11

pub fn main() {
  let result = case argv.load().arguments {
    ["day1", input] -> day1.run(input)
    ["day2", input] -> day2.run(input)
    ["day3", input] -> day3.run(input)
    ["day4", input] -> day4.run(input)
    ["day5", input] -> day5.run(input)
    ["day6", input] -> day6.run(input)
    ["day7", input] -> day7.run(input)
    ["day8", input] -> day8.run(input)
    ["day9", input] -> day9.run(input)
    ["day10", input] -> day10.run(input)
    ["day11", input] -> day11.run(input)
    [unrecognized, _] -> Error("Not implemented: " <> unrecognized)
    _ -> Error("Usage: aoc_2024 <day> <input>")
  }

  case result {
    Ok(solution) -> {
      io.println("Part 1: " <> int.to_string(solution.part1))
      io.println("Part 2: " <> int.to_string(solution.part2))
    }
    Error(e) -> io.println_error("[ERR] " <> e)
  }
}
