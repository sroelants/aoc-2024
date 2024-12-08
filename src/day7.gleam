import gleam/bool
import gleam/list
import gleam/int
import gleam/string
import gleam/result
import helpers.{Solution, type Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use eqs <- result.try(parse_input(input))

  use p1 <- result.try(part1(eqs))
  use p2 <- result.try(part2(eqs))
  Ok(Solution(p1, p2))
}

fn part1(eqs: List(Equation)) -> Result(Int, String) {
  let ops = [add, mult]

  eqs
  |> list.filter(fn(eq) { validate_terms(eq.terms, eq.expected, ops) })
  |> list.map(fn(eq) { eq.expected })
  |> int.sum
  |> Ok
}

fn part2(eqs: List(Equation)) -> Result(Int, String) {
  let ops = [add, mult, concat]

  eqs
  |> list.filter(fn(eq) { validate_terms(eq.terms, eq.expected, ops) })
  |> list.map(fn(eq) { eq.expected })
  |> int.sum
  |> Ok
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type Equation {
  Eq(expected: Int, terms: List(Int))
}

/// Validate terms by combinging the first two elements with one of the
/// provided combinators, and combining recursively with the remaining terms
fn validate_terms(terms: List(Int), expected: Int, ops: List(fn(Int, Int) -> Int)) -> Bool {
  case terms {
    [term] -> term == expected

    // Try combining the first two elements with all of the provided
    // combinators.
    //
    // If we can tell ahead of time that the expression can never be valid
    // (because the current head already exceeds the expected result), we
    // return early
    [first, second, ..rest] -> {
      list.any(ops, fn(op) {
        // Return early if we've already exceeded the expected result
        use <- bool.guard(op(first, second) > expected, False)

        // Combine the first two terms, and repeat
        validate_terms([op(first, second), ..rest], expected, ops)
      })
    }

    _ -> panic as "Unreachable"
  }
}

fn add(a: Int, b: Int) -> Int { a + b }

fn mult(a: Int, b: Int) -> Int { a * b }

fn concat(a: Int, b: Int) -> Int {
  let assert Ok(digits) = int.digits(b, 10)
  list.fold(digits, a, fn(acc, val) { 10*acc + val })
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fn parse_input(input: String) -> Result(List(Equation), String) {
  input 
  |> string.trim 
  |> string.split("\n")
  |> list.try_map(parse_eq)
}

fn parse_eq(line: String) -> Result(Equation, String) {
  case string.split(line, ":") {
    [res, terms] -> {
      use res <- result.try(
        int.parse(res) 
        |> result.replace_error("Invalid result: " <> res)
      )
      use terms <- result.try(parse_terms(terms))
      Ok(Eq(res, terms))
    }
      _ -> Error("Invalid input: " <> line)
  }

}

fn parse_terms(terms: String) -> Result(List(Int), String) {
  terms 
  |> string.trim 
  |> string.split(" ")
  |> list.try_map(int.parse)
  |> result.replace_error("Invalid terms: " <> terms)
}
