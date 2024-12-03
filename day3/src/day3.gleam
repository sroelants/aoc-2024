import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/option.{Some}
import gleam/string
import gleam/regexp as re
import simplifile as fs

type Instruction {
  Mul(a: Int, b: Int)
  Do
  Dont
}

type Accumulator {
  Accumulator(value: Int, active: Bool)
}

pub fn main() {
  let assert Ok(input) =
    fs.read(from: "./input.txt")
    |> result.unwrap("")
    |> string.trim()
    |> parse_input

  io.println("Part 1: " <> part1(input))
  io.println("Part 2: " <> part2(input))
}

fn part1(instructions: List(Instruction)) -> String {
  let accumulator = Accumulator(value: 0, active: True)
  let result = list.fold(instructions, accumulator, apply_instruction_simple)
  int.to_string(result.value)
}

fn part2(instructions: List(Instruction)) -> String {
  let accumulator = Accumulator(value: 0, active: True)
  let result = list.fold(instructions, accumulator, apply_instruction)
  int.to_string(result.value)
}

/// Apply an instruction to the accumulator (part 1)
///
/// Ignores anything but Mul(a,b) instructions
fn apply_instruction_simple(acc: Accumulator, instr: Instruction) -> Accumulator {
  case instr {
    Mul(a, b) -> Accumulator(acc.value + a * b, True)
    _ -> acc
  }
}

/// Apply an instruction to the accumulator (part2)
///
/// Toggles the accumulator state on and off when encountering Do/Dont 
/// instructions
fn apply_instruction(acc: Accumulator, instr: Instruction) -> Accumulator {
  case instr {
    Mul(a, b) if acc.active -> Accumulator(acc.value + a * b, True)
    Mul(_, _) -> acc
    Do -> Accumulator(acc.value, True)
    Dont -> Accumulator(acc.value, False)
  }
}

// Parsing

fn parse_input(input: String) -> Result(List(Instruction), Nil) {
  let assert Ok(mul_regex) = re.compile(
    "mul\\((\\d{1,3}),(\\d{1,3})\\)|(do\\(\\))|(don't\\(\\))", 
    re.Options(case_insensitive: False, multi_line: False)
  )

  input 
  |> re.scan(mul_regex, _)
  |> list.map(match_to_instruction)
  |> result.all
}

fn match_to_instruction(match: re.Match) -> Result(Instruction, Nil) {
  case match {
    re.Match(_, [Some(a), Some(b)]) -> {
      use a <- result.try(int.parse(a))
      use b <- result.try(int.parse(b))
      Ok(Mul(a, b))
    }

    re.Match("do()", _) -> {
      Ok(Do)
    }

    re.Match("don't()", _) -> {
      Ok(Dont)
    }

    _ -> Error(Nil)
  }
}
