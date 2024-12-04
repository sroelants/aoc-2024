import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import helpers.{Solution, type Solution}

type Report =
  List(Int)

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use reports <- result.try(parse_input(input))

  Ok(Solution(part1(reports), part2(reports)))
}

fn part1(reports: List(Report)) -> Int {
  list.count(reports, is_safe(_, 0))
}

fn part2(reports: List(Report)) -> Int {
  list.count(reports, is_safe(_, 1))
}

/// Check whether a report is safe, omitting up to `threshold` levels
fn is_safe(report: Report, threshold: Int) -> Bool {
  let steps = report |> list.window_by_2 |> list.map(fn(p) { p.0 - p.1 })
  let safe_increasing = list.all(steps, fn(step) { 1 <= step && step <= 3 })
  let safe_decreasing = list.all(steps, fn(step) { -3 <= step && step <= -1 })

  // If we're safe, profit! 🥳
  use <- bool.guard(safe_increasing || safe_decreasing, True)

  // If we're not safe, and we're not allowed to omit levels, sadness. 🙁
  use <- bool.guard(threshold <= 0, False)

  // If we're allowed to omit levels, omit one and retest for safety
  let reductions = list.combinations(report, list.length(report) - 1)
  list.any(reductions, is_safe(_, threshold - 1))
}

fn parse_input(input: String) -> Result(List(Report), String) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.try_map(parse_report)
}

fn parse_report(line: String) -> Result(Report, String) {
  line
  |> string.split(" ")
  |> list.try_map(int.parse)
  |> result.replace_error("Failed to parse report: " <> line)
}
