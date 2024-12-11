import gleam/result
import helpers.{type Solution, Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use _input <- result.try(helpers.read_file(file))

  use p1 <- result.try(part1())
  use p2 <- result.try(part2())
  Ok(Solution(p1, p2))
}

fn part1() -> Result(Int, String) {
  Ok(0)
}

fn part2() -> Result(Int, String) {
  Ok(0)
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
