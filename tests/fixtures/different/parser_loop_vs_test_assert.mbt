// Different: Parser loop with match vs Test assertion with match
// Expected: no match at threshold 0.85

///|
fn consume_name(input : String) -> String {
  let buf = StringBuilder::new()
  let chars = input.to_array()
  let mut i = 0
  while i < chars.length() {
    match chars[i] {
      Some(c) if c >= 'a' && c <= 'z' => {
        buf.write_char(c)
        i = i + 1
      }
      Some('_') => {
        buf.write_char('_')
        i = i + 1
      }
      _ => break
    }
  }
  buf.to_string()
}

///|
fn test_type_selector(s : Option[String]) -> Unit {
  match s {
    Some(name) => {
      assert_eq(name, "div")
    }
    None => fail("expected type selector")
  }
}
