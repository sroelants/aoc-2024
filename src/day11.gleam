import gleam/bool
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import helpers.{type Solution, Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use stones <- result.try(parse_input(input))

  use p1 <- result.try(part1(stones))
  use p2 <- result.try(part2(stones))
  Ok(Solution(p1, p2))
}

fn part1(stones: List(Int)) -> Result(Int, String) {
  stones
  |> list.map(predict(_, 25))
  |> int.sum
  |> Ok
}

fn part2(stones: List(Int)) -> Result(Int, String) {
  stones 
  |> list.map(predict(_, 75)) 
  |> int.sum
  |> Ok
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type Cache =
  Dict(#(Int, Int), Int)

/// Predict how many stones a single stone will yield after a number of blinks
fn predict(stone: Int, blinks: Int) -> Int {
  let cache = dict.new()
  let #(_, result) = predict_cached(stone, blinks, cache)
  result
}

fn predict_cached(stone: Int, blinks: Int, cache: Cache) -> #(Cache, Int) {
  case dict.get(cache, #(stone, blinks)) {
    Ok(cached) -> #(cache, cached)
    _ -> {
      let #(cache, result) = compute_result(stone, blinks, cache)
      let new_cache = dict.insert(cache, #(stone, blinks), result)
      #(new_cache, result)
    }
  }
}

/// Compute how many stones will result after some number of blinks
fn compute_result(stone: Int, blinks: Int, cache: Cache) -> #(Cache, Int) {
  use <- bool.guard(blinks == 0, #(cache, 1))
  let digits = num_digits(stone)

  case stone {
    0 -> predict_cached(1, blinks - 1, cache)

    n if digits % 2 == 0 -> {
      let #(first, second) = split_digits(n, digits / 2)
      let #(cache, first) = predict_cached(first, blinks - 1, cache)
      let #(cache, second) = predict_cached(second, blinks - 1, cache)
      #(cache, first + second)
    }

    n -> predict_cached(n * 2024, blinks - 1, cache)
  }
}

fn split_digits(n: Int, len: Int) -> #(Int, Int) {
  let assert Ok(factor) = int.power(10, int.to_float(len))
  let factor = float.round(factor)
  #(n / factor, n % factor)
}

fn num_digits(n: Int) -> Int {
  case n {
    n if n < 10 -> 1
    n -> 1 + num_digits(n / 10)
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fn parse_input(input: String) -> Result(List(Int), String) {
  input
  |> string.trim
  |> string.split(" ")
  |> list.try_map(int.parse)
  |> result.replace_error("Invalid input")
}
