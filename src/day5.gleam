import gleam/list
import gleam/int
import gleam/order.{type Order, Gt}
import gleam/dict.{type Dict}
import gleam/result
import gleam/string
import helpers.{Solution, type Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use #(book, updates) <- result.try(parse_input(input))

  use p1 <- result.try(part1(book, updates))
  use p2 <- result.try(part2(book, updates))
  Ok(Solution(p1, p2))
}

fn part1(book: RuleBook, updates: List(Update)) -> Result(Int, String) {
  let res = updates 
  |> list.filter(is_valid(_, book))
  |> list.map(get_middle)
  |> int.sum

  Ok(res)
}

fn part2(book: RuleBook, updates: List(Update)) -> Result(Int, String) {
  let compare = fn(a,b) { compare(a, b, book) }

  let res = updates 
  |> list.filter(fn (update) { !is_valid(update, book) })
  |> list.map(list.sort(_, compare))
  |> list.map(get_middle)
  |> int.sum

  Ok(res)
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type RuleBook = Dict(#(Int, Int), Order)

type Update = List(Int)

fn get_middle(update: Update) -> Int {
  let idx = list.length(update) / 2
  update |> list.drop(idx) |> list.first |> result.unwrap(0)
}

fn is_valid(update: Update, book: RuleBook) -> Bool {
  case update {
    [] -> True

    // The head is valid if for every other element x in the tail:
    // head <= x
    [head, ..rest] -> {
      let head_is_valid = list.all(rest, fn(x) { 
        compare(head, x, book) != Gt
      })

      head_is_valid && is_valid(rest, book)
    }
  }
}

fn compare(a: Int, b: Int, book: RuleBook) -> Order {
  case book |> dict.get(#(a, b)) {
    Ok(ord) -> ord
    _ -> order.Eq
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

fn parse_input(input: String) -> Result(#(RuleBook, List(Update)), String) {
  let assert [rules, updates]  = string.split(input, "\n\n")
  use rules <- result.try(parse_rules(rules))
  use updates <- result.try(parse_updates(updates))

  Ok(#(rules, updates))
}

fn parse_rules(input: String) -> Result(RuleBook, String) {
  use rules <- result.try(
    input 
    |> string.split("\n") 
    |> list.try_map(parse_rule)
  )

  let book = list.fold(rules, dict.new(), fn(book, rule) {
    let #(a, b) = rule
    book
    |> dict.insert(#(a, b), order.Lt)
    |> dict.insert(#(b, a), order.Gt)
  })

  Ok(book)
}

fn parse_rule(input: String) -> Result(#(Int, Int), String) {
  use xs <- result.try(
    input 
    |> string.split("|")
    |> list.try_map(int.parse)
    |> result.replace_error("Invalid rule: " <> input)
  )

  case xs {
    [a, b] -> Ok(#(a, b))
    _ -> Error("Invalid rule: " <> input)
  }
}

fn parse_updates(input: String) -> Result(List(Update), String) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.try_map(parse_update)
}

fn parse_update(input: String) -> Result(Update, String) {
  input 
  |> string.split(",")
  |> list.try_map(int.parse)
  |> result.replace_error("Invalid update: " <> input)
}
