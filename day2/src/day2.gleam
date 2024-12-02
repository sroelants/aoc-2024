import gleam/io
import gleam/string
import gleam/result
import gleam/list
import gleam/int
import simplifile as fs


type Level = Int
type Report = List(Level)

pub fn main() {
  let input = fs.read(from: "./input.txt") 
    |> result.unwrap("")
    |> string.trim() 

  io.print("Part 1: ")
  io.println(part1(input))

  // io.print("Part 2: ")
  // io.println(part2(input))
}

fn part1(input: String) -> String {
  let assert Ok(reports) = parse_input(input)

  reports 
    |> list.count(fn (report) { is_monotone(report) && well_spaced(report) })
    |> int.to_string
}

fn parse_input(input: String) -> Result(List(Report), Nil) {
  input 
    |> string.split("\n") 
    |> list.map(parse_line)
    |> result.all
}

fn parse_line(line: String) -> Result(Report, Nil) {
  line 
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.all
}

fn diffs(report: Report) -> List(Int) {
  report |> list.window_by_2 |> list.map(fn (p) { p.0 - p.1 })
}

fn is_monotone(report: Report) -> Bool {
  report 
    |> diffs
    |> fn (ds) { 
      list.all(ds, fn (a) { a <= 0 }) || list.all(ds, fn (a) { a >= 0 })
    }
}

fn well_spaced(report: Report) -> Bool {
  report 
    |> diffs 
    |> list.map(int.absolute_value)
    |> list.all(fn (a) { a >= 1 && a <= 3 })
}
