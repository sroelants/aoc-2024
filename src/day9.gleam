import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import helpers.{type Solution, Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use blocks <- result.try(parse_input(input))

  use p1 <- result.try(part1(blocks))
  use p2 <- result.try(part2())
  Ok(Solution(p1, p2))
}

fn part1(blocks: List(Block)) -> Result(Int, String) {
  blocks 
  |> compactify 
  |> checksum 
  |> Ok
}

fn part2() -> Result(Int, String) {
  Ok(0)
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type Block {
  File(id: Int)
  Empty
}

type Compacter {
  Compacter(
    front: List(Block),
    back: List(Block),
    compacted: List(Block),
    blocks_to_compact: Int
  )
}

fn new_compacter(blocks: List(Block)) -> Compacter {
  let blocks_to_compact = list.count(blocks, is_file)
  let front = blocks
  let back = blocks |> list.reverse |> list.filter(is_file)
  let compacted = list.new()
  Compacter(front:, back:, compacted:, blocks_to_compact:)
}

fn run_compacter(compacter: Compacter) -> Compacter {
  use <- bool.guard(compacter.blocks_to_compact == 0, compacter)

  let assert [first, ..front] = compacter.front

  let next_compacter = case first {
    Empty -> {
      let assert [last, ..back] = compacter.back
      let compacted = list.prepend(compacter.compacted, last)
      let blocks_to_compact = compacter.blocks_to_compact - 1
      Compacter(front:, back:, compacted:, blocks_to_compact:)
    }

    block -> {
      let compacted = list.prepend(compacter.compacted, block)
      let blocks_to_compact = compacter.blocks_to_compact - 1
      Compacter(front:, back: compacter.back, compacted:, blocks_to_compact:)
    }
  }

  run_compacter(next_compacter)
}

fn compactify(blocks: List(Block)) -> List(Block) {
  let compacter = new_compacter(blocks)
  let completed = run_compacter(compacter)
  list.reverse(completed.compacted)
}

fn is_file(block) -> Bool {
  block != Empty
}

fn checksum(blocks: List(Block)) -> Int {
  use checksum, block, i <- list.index_fold(blocks, 0)
  let assert File(id) = block
  checksum + i * id
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fn parse_input(input: String) -> Result(List(Block), String) {
  let chars = input |> string.trim() |> string.to_graphemes
  let assert Ok(digits) = list.try_map(chars, int.parse)

  let parsed_blocks = {
    use current_blocks, digit, i <- list.index_fold(digits, list.new())

    // Even digits represent files with incrementing ID, 
    // odd digits represent spaces
    let to_add = case i % 2 {
      0 -> File(i / 2)
      1 -> Empty
      _ -> panic as "unreachable"
    }

    to_add
    |> list.repeat(digit)
    |> list.append(current_blocks)
  }

  Ok(list.reverse(parsed_blocks))
}
