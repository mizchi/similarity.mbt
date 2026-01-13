// Similar: Pattern match with similar structure
// Expected: similarity >= 0.7

///|
fn handle_option_int(opt : Int?) -> Int {
  match opt {
    Some(value) => value * 2
    None => 0
  }
}

///|
fn handle_option_string(opt : String?) -> String {
  match opt {
    Some(s) => s + s
    None => ""
  }
}
