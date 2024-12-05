import gleam/list
import gleam/int
import gleam/dict.{type Dict}
import gleam/result
import gleam/string
import helpers.{Solution, type Solution}

pub fn run(file: String) -> Result(Solution, String) {
  use input <- result.try(helpers.read_file(file))
  use grid <- result.try(parse_input(input))

  use p1 <- result.try(part1(grid))
  use p2 <- result.try(part2(grid))
  Ok(Solution(p1, p2))
}

fn part1(grid: Grid) -> Result(Int, String) {
  let result = grid 
  |> dict.keys 
  |> list.map(find_xmas(grid, _))
  |> int.sum

  Ok(result)

}

fn part2(grid: Grid) -> Result(Int, String) {
  let result = grid 
  |> dict.keys 
  |> list.count(find_x_mas(grid, _))

  Ok(result)
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Helpers
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type Grid = Dict(Point, String)

type Point {
  Point(x: Int, y: Int)
}
type Step {
  Step(dx: Int, dy: Int)
}

const dirs = [
  Step( 0,  1),
  Step( 0, -1),
  Step( 1,  1),
  Step( 1, -1),
  Step(-1,  1),
  Step(-1, -1),
  Step( 1,  0),
  Step(-1,  0),
]

fn move(point: Point, step: Step) -> Point {
  Point(point.x + step.dx, point.y + step.dy)
}

fn look(point: Point, step: Step) -> List(Point) {
  [
    point, 
    point |> move(step), 
    point |> move(step) |> move(step),
    point |> move(step) |> move(step) |> move(step)
  ] 
}

fn look_x(point: Point) -> List(List(Point)) {
  [ 
    [ point |> move(Step(-1, -1)), point, point |> move(Step(1,1))],
    [ point |> move(Step(1, -1)), point, point |> move(Step(-1,1))],
  ]
}

fn find_xmas(grid: Grid, point: Point) -> Int {
  dirs
  |> list.map(look(point, _))
  |> list.map(read_word(grid, _))
  |> list.count(fn(w) { w == Ok("XMAS") })
}

fn read_word(grid: Grid, points: List(Point)) -> Result(String, Nil) {
  points
  |> list.try_map(dict.get(grid, _))
  |> result.map(string.join(_, ""))
}

fn find_x_mas(grid: Grid, point: Point) -> Bool {
  point 
  |> look_x
  |> list.map(read_word(grid, _))
  |> list.all(fn(w) { w == Ok("MAS") || w == Ok("SAM") })
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Parsing
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

fn parse_input(input: String) -> Result(Grid, String) {
  let grid = {
    use acc, line, y <- list.index_fold(string.split(input, "\n"), dict.new())
    use acc, char, x <- list.index_fold(string.split(line, ""), acc)
    dict.insert(acc, Point(x,y), char)
  }

  Ok(grid)
}

