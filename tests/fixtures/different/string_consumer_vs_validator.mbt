// Different: String consuming loop vs Simple validation
// Expected: no match at threshold 0.85

///|
fn consume_string(input : String, quote : Char) -> String {
  let buf = StringBuilder::new()
  let chars = input.to_array()
  let mut i = 0
  while i < chars.length() {
    match chars[i] {
      Some(c) if c == quote => break
      Some('\\') => {
        i = i + 1
        match chars[i] {
          Some(escaped) => buf.write_char(escaped)
          None => ()
        }
        i = i + 1
      }
      Some(c) => {
        buf.write_char(c)
        i = i + 1
      }
      None => break
    }
  }
  buf.to_string()
}

///|
fn validate_selector(selector : Option[String]) -> Bool {
  match selector {
    Some(s) => {
      if s.length() > 0 {
        true
      } else {
        false
      }
    }
    None => false
  }
}
