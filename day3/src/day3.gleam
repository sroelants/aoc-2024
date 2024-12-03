import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match, type Match}
import gleam/regexp as re
import gleam/result
import gleam/string
import simplifile as fs

pub fn main() {
  let assert Ok(input) = fs.read("./input.txt")

  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}

fn part1(input: String) -> Int {
  let grammar = ["mul\\((\\d{1,3}),(\\d{1,3})\\)"]
  let assert Ok(instructions) = parse_input(input, grammar)

  instructions 
    |> list.fold(State(value: 0, active: True), apply_instruction)
    |> fn (state) { state.value }
}

fn part2(input: String) -> Int {
  let grammar = ["mul\\((\\d{1,3}),(\\d{1,3})\\)", "do\\(\\)", "don't\\(\\)"]
  let assert Ok(instructions) = parse_input(input, grammar)

  instructions 
    |> list.fold(State(value: 0, active: True), apply_instruction)
    |> fn (state) { state.value }
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

fn parse_input(input: String, grammar: List(String)) -> Result(List(Instruction), Nil) {
  let assert Ok(regex) = re.from_string(string.join(grammar, "|"))

  input 
  |> re.scan(regex, _) 
  |> list.try_map(match_to_instruction)
}

fn match_to_instruction(match: Match) -> Result(Instruction, Nil) {
  case match {
    Match(_, [Some(a), Some(b)]) -> {
      use a <- result.try(int.parse(a))
      use b <- result.try(int.parse(b))
      Ok(Mul(a, b))
    }
    Match("do()", _) -> Ok(Do)
    Match("don't()", _) -> Ok(Dont)
    _ -> Error(Nil)
  }
}
