// Different: Option handling vs Result handling
// Expected: no match at threshold 0.85

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
