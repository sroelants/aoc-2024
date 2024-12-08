import gleam/string
import gleam/list
import gleam/result
import gleam/dict.{type Dict}
import gleam/option.{Some, None}
import helpers.{Solution, type Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  let antinodes = init_antinodes(input)
  use antennas <- result.try(parse_antennas(input))

  use p1 <- result.try(part1(antennas, antinodes))
  use p2 <- result.try(part2(antennas, antinodes))
  Ok(Solution(p1, p2))
}

fn part1(table: AntennaTable, map: AntinodeMap) -> Result(Int, String) {
  let populated_antinodes = {
    use map, antennas <- list.fold(dict.values(table), map)
    use map, #(a, b) <- list.fold(list.combination_pairs(antennas), map)

    map 
    |> add_one(mirrored(a, b))
    |> add_one(mirrored(b, a))
  }

  populated_antinodes 
  |> dict.values 
  |> list.count(fn(antinode) { antinode })
  |> Ok
}

fn part2(table: AntennaTable, map: AntinodeMap) -> Result(Int, String) {
  let populated_antinodes = {
    use map, antennas <- list.fold(dict.values(table), map)
    use map, #(a, b) <- list.fold(list.combination_pairs(antennas), map)

    map 
    |> add_many(a, b)
    |> add_many(b, a)
  }

  populated_antinodes 
  |> dict.values 
  |> list.count(fn(antinode) { antinode })
  |> Ok
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type Position = #(Int, Int)
type AntennaTable = Dict(String, List(Position))
type AntinodeMap = Dict(Position, Bool)

// Mirror position `b` around poisition `a`
fn mirrored(a: Position, b: Position) -> Position {
  #(a.0 - { b.0 - a.0 }, a.1 - { b.1 - a.1 })
}

/// Add an antinode, making sure we don't activate any antinodes outside
/// of the map bounds (where the map entries are uninitialized).
fn add_one(map: AntinodeMap, pos: Position) -> AntinodeMap {
  case dict.get(map, pos) {
    Ok(False) -> dict.insert(map, pos, True)
    _ -> map
  }
}

fn add_many(map: AntinodeMap, a: Position, b: Position) -> AntinodeMap {
  let next = #(b.0 - { a.0 - b.0 }, b.1 - { a.1 - b.1 })

  case dict.get(map, b) {
    Ok(_) -> add_many(dict.insert(map, b, True), b, next)
    Error(_) -> map
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fn parse_antennas(input: String) -> Result(AntennaTable, String) {
  let lines = input |> string.trim |> string.split("\n")

  let table = {
    use table, line, j <- list.index_fold(lines, dict.new())
    use table, ch, i <- list.index_fold(string.split(line, ""), table)

    case ch {
      "." -> table

      ch -> {
        dict.upsert(table, ch, fn(existing) {
          case existing {
            Some(antennas) -> list.prepend(antennas, #(i, j))
            None -> [#(i, j)]
          }
        })
      }
    }
  }

  Ok(table)
}

fn init_antinodes(input: String) -> AntinodeMap {
  let lines = input |> string.trim |> string.split("\n")
  let map = {
    use map, line, j <- list.index_fold(lines, dict.new())
    use map, _, i <- list.index_fold(string.split(line, ""), map)
    dict.insert(map, #(i, j), False)
  }

  map
}
