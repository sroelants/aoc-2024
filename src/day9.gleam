import gleam/io
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
  use p2 <- result.try(part2(input))
  Ok(Solution(p1, p2))
}

fn part1(blocks: List(Block)) -> Result(Int, String) {
  blocks
  |> compactify
  |> checksum
  |> Ok
}

fn part2(input: String) -> Result(Int, String) {
  input
  |> parse_compacter
  |> run_mk2 
  |> io.debug
  |> fn(compacter) { compacter.compacted }
  |> checksum_mk2
  |> Ok
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// TODO: Re-use the same logic for both parts
// Pretty sure this should Just Work (TM) if part 1 is expressed as a bunch of
// size-1 blocks

// Part 1 ---------------------------------------------------------------------

type Block {
  File(id: Int)
  Empty
}

type Compacter {
  Compacter(
    front: List(Block),
    back: List(Block),
    compacted: List(Block),
    blocks_to_compact: Int,
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

// Part 2 ---------------------------------------------------------------------
type FileBlock {
  FileBlock(id: Int, loc: Int, size: Int)
}

type FreeBlock {
  FreeBlock(loc: Int, size: Int)
}

type CompacterMk2 {
  CompacterMk2(
    files: List(FileBlock),
    free: List(FreeBlock),
    compacted: List(FileBlock),
    size: Int,
  )
}

/// Find the lowest index block of free memory of the requested size
fn find_space(free_list: List(FreeBlock), file: FileBlock) -> Result(FreeBlock, Nil) {
  let sufficient = free_list |> list.filter(fn(free) { 
    free.size >= file.size && free.loc < file.loc 
  })

  use best, block <- list.reduce(sufficient)
  case block.loc < best.loc {
    True -> block
    False -> best
  }
}

fn allocate(compacter: CompacterMk2, file: FileBlock, slot: FreeBlock) -> CompacterMk2 {
  let relocated = FileBlock(..file, loc: slot.loc)
  let remaining = FreeBlock(loc: slot.loc + file.size, size: slot.size - file.size)
  let compacted = list.prepend(compacter.compacted, relocated)
  let free = list.map(compacter.free, fn(block) { 
    case block == slot {
      True -> remaining
      False -> block
    }
  })

  CompacterMk2(..compacter, compacted:, free:)
}

fn run_mk2(compacter: CompacterMk2) -> CompacterMk2 {
  use <- bool.guard(list.is_empty(compacter.files), compacter)
  let assert [file, ..remaining] = compacter.files
  
  let next_compacter = case find_space(compacter.free, file) {
    // If we found a slot, allocate the memory and return the resulting 
    // compacter
    Ok(slot) -> {
      let new_compacter = allocate(compacter, file, slot)
      CompacterMk2(..new_compacter, files: remaining)
    }

    // If we couldn't find a spot, simply put the file in the compacted pile,
    // and continue with the remaining files
    Error(_) -> {
      let compacted = list.prepend(compacter.compacted, file)
      CompacterMk2(..compacter, files: remaining, compacted:)
    }
  }

  run_mk2(next_compacter)
}

fn checksum_mk2(files: List(FileBlock)) -> Int {
  use total, file <- list.fold(files, 0)
  let start = file.loc
  let end = file.loc + file.size - 1
  total + file.id * int.sum(list.range(start, end))
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

fn parse_compacter(input: String) -> CompacterMk2 {
  let chars = input |> string.trim() |> string.to_graphemes
  let assert Ok(digits) = list.try_map(chars, int.parse)
  let compacter = CompacterMk2(list.new(), list.new(), list.new(), 0)
  use current, digit, i <- list.index_fold(digits, compacter)

  case i % 2 == 0 {
    True -> {
      let loc = current.size
      let block = FileBlock(id: i / 2, loc:, size: digit)
      let files = list.prepend(current.files, block)
      let size = current.size + block.size
      CompacterMk2(..current, files:, size:)
    }

    False -> {
      let loc = current.size
      let block = FreeBlock(loc:, size: digit)
      let free = list.prepend(current.free, block)
      let size = current.size + block.size
      CompacterMk2(..current, free:, size:)
    }
  }
}
