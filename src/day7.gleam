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
  let grammar = [Plus, Times]
  eqs 
  |> list.filter(fn(eq) { valid_combinations(eq, grammar) > 0 })
  |> list.map(fn(eq) { eq.expected })
  |> int.sum
  |> Ok
}

fn part2(eqs: List(Equation)) -> Result(Int, String) {
  let grammar = [Plus, Times, Concat]

  eqs 
  |> list.filter(fn(eq) { valid_combinations(eq, grammar) > 0 })
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

type Token {
  Val(Int)
  Plus
  Times
  Concat
}

type Expr = List(Token)

fn generate_exprs(terms: List(Int), grammar: List(Token)) -> List(Expr) {
  case terms {
    [] -> list.new()
    [term] -> [[Val(term)]]
    [head, ..tail] -> {
      let remaining = generate_exprs(tail, grammar)
      use expr <- list.flat_map(remaining)
      use token <- list.map(grammar)
      combine_with_token(head, token, expr)
    }
  }
}

fn eval_expr(expr: Expr) -> Int {
  case expr {
    [Val(v)] -> v
    [Val(a), Plus, Val(b), ..rest] -> eval_expr([Val(a+b), ..rest])
    [Val(a), Times, Val(b), ..rest] -> eval_expr([Val(a*b), ..rest])
    [Val(a), Concat, Val(b), ..rest] -> eval_expr([Val(concat(a, b)), ..rest])
    _ -> panic as "Invalid expression"
  }
}

fn valid_combinations(eq: Equation, grammar: List(Token)) -> Int {
  eq.terms
  |> generate_exprs(grammar)
  |> list.count(validate(_, eq.expected))
}

fn validate(expr: Expr, expected: Int) -> Bool {
  case expr {
    [Val(v)] -> v == expected

    [Val(a), Plus, Val(b), ..rest] -> {
      use <- bool.guard(a + b > expected, False)
      validate([Val(a+b), ..rest], expected)
    }

    [Val(a), Times, Val(b), ..rest] -> {
      use <- bool.guard(a + b > expected, False)
      validate([Val(a*b), ..rest], expected)
    }

    [Val(a), Concat, Val(b), ..rest] -> {
      use <- bool.guard(a + b > expected, False)
      validate([Val(concat(a, b)), ..rest], expected)
    }
    _ -> panic as "Invalid expression"
  }
}

fn combine_with_token(val: Int, token: Token, expr: Expr) -> Expr {
  list.append([Val(val), token], expr)
}

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
