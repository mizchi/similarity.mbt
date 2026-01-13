// Similar: Result handling patterns
// Expected: similarity >= 0.7

///|
fn parse_and_double(s : String) -> Result[Int, String] {
  match @strconv.parse_int(s) {
    Ok(n) => Ok(n * 2)
    Err(e) => Err("Parse error: \{e}")
  }
}

///|
fn parse_and_negate(input : String) -> Result[Int, String] {
  match @strconv.parse_int(input) {
    Ok(value) => Ok(-value)
    Err(err) => Err("Failed: \{err}")
  }
}
