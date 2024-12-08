import gleam/list
import gleam/set.{type Set}
import gleam/dict.{type Dict}
import gleam/result
import gleam/string
import helpers.{Solution, type Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use state <- result.try(parse_input(input))

  use p1 <- result.try(part1(state))
  use p2 <- result.try(part2(state))
  Ok(Solution(p1, p2))
}

fn part1(state: State) -> Result(Int, String) {
  simulate(state).state.visited
  |> set.map(fn (guard) { guard.position })
  |> set.size
  |> Ok
}

fn part2(state: State) -> Result(Int, String) {
  simulate(state).state.visited
  |> set.map(fn(guard) { guard.position })
  |> set.to_list
  |> list.map(insert_wall(state, _))
  |> list.count(has_loop)
  |> Ok
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type Position = #(Int, Int)
type Map = Dict(#(Int, Int), Tile)

type Direction { 
  Up 
  Down
  Left
  Right
}

type Tile {
  Empty
  Wall
}

type Guard {
  Guard(position: Position, direction: Direction)
}

type State {
  State(map: Map, guard: Guard, visited: Set(Guard))
}

type Status {
  Running(state: State)
  Exited(state: State)
  Loop(state: State)
}

fn apply_dir(pos: Position, dir: Direction) -> Position {
  case dir {
    Up -> #(pos.0, pos.1 - 1)
    Down -> #(pos.0, pos.1 + 1)
    Left -> #(pos.0 - 1, pos.1)
    Right -> #(pos.0 + 1, pos.1)
  }
}

fn turn_right(dir: Direction) -> Direction {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn advance_one(state: State) -> Status {
  let next_pos = state.guard.position |> apply_dir(state.guard.direction)
  let next_tile = dict.get(state.map, next_pos)

  case next_tile {
    Ok(Empty) -> {
      let new_guard = Guard(next_pos, state.guard.direction)

      case set.contains(state.visited, new_guard) {
        True -> Loop(state)
        False -> {
          let new_history = set.insert(state.visited, new_guard)
          Running(State(state.map, new_guard, new_history))
        }
      }
    }

    Ok(Wall) -> {
      let new_guard = Guard(state.guard.position, turn_right(state.guard.direction))

      case set.contains(state.visited, new_guard) {
        True -> Loop(state)
        False -> {
          let new_history = set.insert(state.visited, new_guard)
          Running(State(state.map, new_guard, new_history))
        }
      }
    }

    Error(_) -> {
      Exited(state)
    }
  }
}

fn simulate(state: State) -> Status {
  case advance_one(state) {
    Running(next) -> simulate(next)
    status -> status
  }
}

fn has_loop(state: State) -> Bool {
  case simulate(state) {
    Loop(_) -> True
    _ -> False
  }
}

fn insert_wall(state: State, position: Position) -> State {
  State(dict.insert(state.map, position, Wall), state.guard, state.visited)
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fn parse_input(input: String) -> Result(State, String) {
  let lines = input |> string.trim |> string.split("\n")
  let state = State(dict.new(), Guard(#(0,0), Up), set.new())

  let state = {
    use state, line, j <- list.index_fold(lines, state)
    use state, ch, i <- list.index_fold(string.split(line, ""), state)

    case ch {
      "." -> State(dict.insert(state.map, #(i, j), Empty), state.guard, state.visited)
      "#" -> State(dict.insert(state.map, #(i, j), Wall), state.guard, state.visited)
      "^" -> {
        let new_map = dict.insert(state.map, #(i, j), Empty)
        let new_guard = Guard(#(i, j), Up)
        let new_visited = set.insert(state.visited, new_guard)
        State(new_map, new_guard, new_visited)
      }
      "v" -> {
        let new_map = dict.insert(state.map, #(i, j), Empty)
        let new_guard = Guard(#(i, j), Down)
        let new_visited = set.insert(state.visited, new_guard)
        State(new_map, new_guard, new_visited)
      }
      "<" -> {
        let new_map = dict.insert(state.map, #(i, j), Empty)
        let new_guard = Guard(#(i, j), Left)
        let new_visited = set.insert(state.visited, new_guard)
        State(new_map, new_guard, new_visited)
      }
      ">" -> {
        let new_map = dict.insert(state.map, #(i, j), Empty)
        let new_guard = Guard(#(i, j), Right)
        let new_visited = set.insert(state.visited, new_guard)
        State(new_map, new_guard, new_visited)
      }
      _   -> state
    }
  }

  Ok(state)
}
