// Different: Match expression vs if-else chain
// Expected: no match at threshold 0.85

///|
fn day_name(day : Int) -> String {
  match day {
    1 => "Monday"
    2 => "Tuesday"
    3 => "Wednesday"
    4 => "Thursday"
    5 => "Friday"
    6 => "Saturday"
    7 => "Sunday"
    _ => "Unknown"
  }
}

///|
fn calculate_grade(score : Int) -> String {
  if score >= 90 {
    "A"
  } else if score >= 80 {
    "B"
  } else if score >= 70 {
    "C"
  } else if score >= 60 {
    "D"
  } else {
    "F"
  }
}
