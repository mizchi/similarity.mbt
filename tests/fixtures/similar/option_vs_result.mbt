// Similar: Option handling vs Result handling
// Note: Structurally identical (match with 2 cases, same operations)
// Expected: similarity >= 0.95

///|
fn process_option(opt : Int?) -> Int {
  match opt {
    Some(x) => x * 2
    None => -1
  }
}

///|
fn process_result(res : Result[Int, String]) -> Int {
  match res {
    Ok(x) => x * 2
    Err(_) => -1
  }
}
