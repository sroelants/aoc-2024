import simplifile as fs
import gleam/result

pub type Solution {
  Solution(part1: Int, part2: Int)
}

pub fn read_file(file: String) -> Result(String, String) {
  fs.read(file) |> result.replace_error("Failed to read file: " <> file)
}
