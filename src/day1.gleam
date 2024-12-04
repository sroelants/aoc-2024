import gleam/string
import gleam/int
import gleam/dict
import gleam/list
import gleam/result
import gleam/option.{Some, None}
import helpers.{type Solution, Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  Ok(Solution(part1(input), part2(input)))
}

fn part1(input: String) -> Int {
  let #(list_a, list_b) = parse_lists(input)
  let sorted_a = list.sort(list_a, int.compare)
  let sorted_b = list.sort(list_b, int.compare)

  list.map2(sorted_a, sorted_b, fn (a, b) { int.absolute_value(b - a) })
    |> int.sum 
}

fn part2(input: String) -> Int {
  let #(list_a, list_b) = parse_lists(input)
  let freqs = frequencies(list_b)

  list_a 
    |> list.map(fn (a) { a * { dict.get(freqs, a) |> result.unwrap(0) }})
    |> int.sum
}

////////////////////////////////////////////////////////////////////////////////
//
// Helpers
//
////////////////////////////////////////////////////////////////////////////////

/// Parse an input line into a pair of integers
/// Defaults to 0 if parsing the int fails
fn parse_pair(input: String) -> #(Int, Int) {
  let assert [Ok(a), Ok(b)] = input 
    |> string.split("   ")
    |> list.map(int.parse)

  #(a, b)
}

/// Parse the input into a pair of integer lists
fn parse_lists(input: String) -> #(List(Int), List(Int)) {
  input 
    |> string.trim()
    |> string.split("\n") 
    |> list.map(parse_pair)
    |> list.unzip
}

/// Build a frequency table for a list of items
fn frequencies(items: List(itemtype)) -> dict.Dict(itemtype, Int) {
  use freqs, item <- list.fold(items, dict.new())
  use prev <- dict.upsert(freqs, item)

  case prev {
    Some(n) -> n + 1
    None    -> 1
  }
}
