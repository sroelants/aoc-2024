import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import helpers.{type Solution, Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use map <- result.try(parse_map(input))

  use p1 <- result.try(part1(map))
  use p2 <- result.try(part2(map))
  Ok(Solution(p1, p2))
}

fn part1(map: Map) -> Result(Int, String) {
  find_trailheads(map)
  |> list.map(find_peaks(map, _))
  |> list.map(list.unique)
  |> list.map(list.length)
  |> int.sum
  |> Ok
}

fn part2(map: Map) -> Result(Int, String) {
  find_trailheads(map)
  |> list.map(find_peaks(map, _))
  |> list.map(list.length)
  |> int.sum
  |> Ok
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type Position =
  #(Int, Int)

type Map =
  Dict(Position, Int)

fn find_trailheads(map: Map) -> List(Position) {
  map
  |> dict.filter(fn(_, v) { v == 0 })
  |> dict.keys
}

/// Return the list of peaks reachable from a given start
///
/// This may return duplicates if the same peak is reachable in along
/// different trails
fn find_peaks(map: Map, current: Position) -> List(Position) {
  let assert Ok(current_height) = dict.get(map, current)
  use <- bool.guard(current_height == 9, [current])

  let neighbors = neighbors(current)
  let accessible = list.filter(neighbors, is_accessible(map, current, _))
  list.flat_map(accessible, find_peaks(map, _))
}

fn is_accessible(map: Map, current: Position, next: Position) -> Bool {
  let assert Ok(current_height) = dict.get(map, current)

  case dict.get(map, next) {
    Ok(next_height) if next_height == current_height + 1 -> True
    _ -> False
  }
}

fn neighbors(p: Position) -> List(Position) {
  [#(p.0, p.1 - 1), #(p.0, p.1 + 1), #(p.0 - 1, p.1), #(p.0 + 1, p.1)]
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

fn parse_map(input: String) -> Result(Map, String) {
  let map = {
    use map, line, j <- list.index_fold(string.split(input, "\n"), dict.new())
    use map, ch, i <- list.index_fold(string.to_graphemes(line), map)
    let assert Ok(height) = int.parse(ch)
    dict.insert(map, #(i, j), height)
  }

  Ok(map)
}
