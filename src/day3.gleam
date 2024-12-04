import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match, type Match}
import gleam/regexp as re
import gleam/result
import gleam/string
import helpers.{Solution, type Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use p1 <- result.try(part1(input))
  use p2 <- result.try(part2(input))
  Ok(Solution(p1, p2))
}

fn part1(input: String) -> Result(Int, String) {
  let grammar = ["mul\\((\\d{1,3}),(\\d{1,3})\\)"]
  use instructions <- result.try(parse_input(input, grammar))

  Ok(instructions 
    |> list.fold(State(value: 0, active: True), apply_instruction)
    |> fn (state) { state.value })
}

fn part2(input: String) -> Result(Int, String) {
  let grammar = ["mul\\((\\d{1,3}),(\\d{1,3})\\)", "do\\(\\)", "don't\\(\\)"]
  use instructions <- result.try(parse_input(input, grammar))

  Ok(instructions 
    |> list.fold(State(value: 0, active: True), apply_instruction)
    |> fn (state) { state.value })
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type Instruction {
  Mul(a: Int, b: Int)
  Do
  Dont
}

type State {
  State(value: Int, active: Bool)
}

fn apply_instruction(state: State, instr: Instruction) -> State {
  case instr {
    Mul(a, b) if state.active -> State(state.value + a * b, state.active)
    Mul(_, _) -> state
    Do -> State(state.value, True)
    Dont -> State(state.value, False)
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

fn parse_input(
  input: String, 
  grammar: List(String)
) -> Result(List(Instruction), String) {
  let regex_string = string.join(grammar, "|")
  use regex <- result.try(re.from_string(regex_string) |> result.replace_error("Invalid regex: " <> regex_string))

  input 
  |> re.scan(regex, _) 
  |> list.try_map(match_to_instruction)
}

fn match_to_instruction(match: Match) -> Result(Instruction, String) {
  case match {
    Match(_, [Some(a), Some(b)]) -> {
      use a <- result.try(int.parse(a) |> result.replace_error("Failed to parse: " <> a))
      use b <- result.try(int.parse(b) |> result.replace_error("Failed to parse: " <> b))
      Ok(Mul(a, b))
    }
    Match("do()", _) -> Ok(Do)
    Match("don't()", _) -> Ok(Dont)
    Match(m, _) -> Error("Invalid instruction: " <> m)
  }
}
