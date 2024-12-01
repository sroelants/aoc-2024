import gleam/io
import gleam/string
import gleam/pair
import gleam/int
import gleam/dict
import gleam/list
import gleam/result
import gleam/option.{Some, None}
import simplifile as fs

pub fn main() {
  let input = fs.read(from: "./input.txt") 
    |> result.unwrap("")
    |> string.trim() 

  io.debug(part2(input))
}

fn part1(input: String) -> Int {
  let #(sorted_a, sorted_b) = parse_lists(input)
    |> pair.map_first(fn (xs) { list.sort(xs, int.compare) })
    |> pair.map_second(fn (xs) { list.sort(xs, int.compare) })

  let diffs = list.map2(sorted_a, sorted_b, fn (a, b) { int.absolute_value(b - a) })
  int.sum(diffs)
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
  let assert Ok(#(a, b)) = string.split_once(input, " ")

  pair.new(
    a |> string.trim |> int.parse |> result.unwrap(0) ,
    b |> string.trim |> int.parse |> result.unwrap(0),
  )
}

/// Parse the input into a pair of integer lists
fn parse_lists(input: String) -> #(List(Int), List(Int)) {
  input 
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
