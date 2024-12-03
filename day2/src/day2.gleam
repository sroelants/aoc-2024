import gleam/io
import gleam/string
import gleam/result
import gleam/list
import gleam/int
import simplifile as fs

type Level = Int
type Report = List(Level)

pub fn main() {
  let input = fs.read(from: "./input.txt") 
    |> result.unwrap("")
    |> string.trim() 

  io.print("Part 1: ")
  io.println(part1(input))

  io.print("Part 2: ")
  io.println(part2(input))
}

fn part1(input: String) -> String {
  let assert Ok(reports) = parse_input(input)
  reports |> list.count(is_safe(_, 0)) |> int.to_string
}

fn part2(input: String) -> String {
  let assert Ok(reports) = parse_input(input)
  reports |> list.count(is_safe(_, 1)) |> int.to_string
}

/// Check whether a report is safe, omitting up to `threshold` levels
fn is_safe(report: Report, threshold: Int) -> Bool {
  case threshold {
    0 -> {
      let steps = report |> list.window_by_2 |> list.map(fn (p) { p.0 - p.1 })
      list.all(steps, safe_increasing) || list.all(steps, safe_decreasing)
    }

    threshold -> {
      report 
        |> list.combinations(list.length(report) - 1) 
        |> list.any(is_safe(_, threshold - 1))
    }
  }
}

/// Check whether a step between two increasing levels is safe
fn safe_increasing(step: Int) -> Bool {
  1 <= step && step <= 3
}

/// Check whether a step between two decreasing levels is safe
fn safe_decreasing(step: Int) -> Bool {
  -3 <= step && step <= -1
}

// Parsing

fn parse_input(input: String) -> Result(List(Report), Nil) {
  input 
    |> string.split("\n") 
    |> list.map(parse_line)
    |> result.all
}

fn parse_line(line: String) -> Result(Report, Nil) {
  line 
    |> string.trim()
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.all
}

