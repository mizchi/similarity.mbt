///|
/// Parse expected threshold from fixture file comment
/// Format: "// Expected: similarity >= 0.8" or "// Expected: no match at threshold 0.85"
fn parse_expectation(source : String) -> (Bool, Double) {
  // Default: expect similar at 0.8
  let lines = source.split("\n").collect()
  for line in lines {
    let line_str = line.to_owned()
    if line_str.contains("// Expected:") {
      if line_str.contains("similarity >=") {
        // Extract threshold after ">="
        let parts = line_str.split(">=").collect()
        if parts.length() > 1 {
          let threshold_str = parts[1].trim()
          let threshold = @string.parse_double(threshold_str) catch { _ => 0.8 }
          return (true, threshold) // expect_similar=true
        }
      } else if line_str.contains("no match") {
        // Parse "no match at threshold X.XX"
        let parts = line_str.split("threshold").collect()
        if parts.length() > 1 {
          let threshold_str = parts[1].trim()
          let threshold = @string.parse_double(threshold_str) catch {
            _ => 0.85
          }
          return (false, threshold) // expect_similar=false
        }
        return (false, 0.85)
      }
    }
  }
  (true, 0.8) // default
}

///|
/// Run similarity detection on a fixture file and check expectations
fn run_fixture_test(
  filepath : String,
  expect_similar : Bool,
  threshold : Double,
) -> Result[Unit, String] {
  let source = @fs.read_file_to_string(filepath) catch {
    e => return Err("Failed to read \{filepath}: \{@debug.to_string(e)}")
  }
  // For "similar" tests, disable size_penalty to detect similar patterns
  // For "different" tests, enable size_penalty to avoid false positives
  let options : @similarity.DetectorOptions = {
    threshold,
    min_lines: 3,
    size_penalty: !expect_similar,
  }
  let results = @similarity.detect_similarities(source, options)
  if expect_similar {
    if results.length() == 0 {
      return Err(
        "\{filepath}: Expected similar functions but none detected at threshold \{threshold}",
      )
    }
    Ok(())
  } else {
    if results.length() > 0 {
      let first = results[0]
      return Err(
        "\{filepath}: Expected no match but found \{first.func1.name} <-> \{first.func2.name} (similarity: \{first.similarity})",
      )
    }
    Ok(())
  }
}

///|
/// List files in a directory
fn list_fixture_files(dir : String) -> Array[String] raise {
  let files : Array[String] = []
  let entries = @fs.read_dir(dir)
  for entry in entries {
    if entry.has_suffix(".mbt") {
      files.push("\{dir}/\{entry}")
    }
  }
  files
}

///|
test "fixtures/similar - should detect similarities" {
  let dir = "tests/fixtures/similar"
  let files = list_fixture_files(dir)
  assert_true(
    !files.is_empty(),
    msg="Fixture directory must not be empty: \{dir}",
  )
  let mut all_passed = true
  let errors : Array[String] = []
  for filepath in files {
    let source = @fs.read_file_to_string(filepath)
    let (_, reports) = @parser.parse_string(source)
    assert_eq(reports.length(), 0, msg=filepath)
    assert_true(
      @similarity.extract_functions(source).length() >= 2,
      msg=filepath,
    )
    let (expect_similar, threshold) = parse_expectation(source)
    match run_fixture_test(filepath, expect_similar, threshold) {
      Ok(_) => ()
      Err(msg) => {
        all_passed = false
        errors.push(msg)
      }
    }
  }
  if !all_passed {
    for err in errors {
      println(err)
    }
  }
  inspect(all_passed, content="true")
}

///|
test "fixtures/different - should not detect false positives" {
  let dir = "tests/fixtures/different"
  let files = list_fixture_files(dir)
  assert_true(
    !files.is_empty(),
    msg="Fixture directory must not be empty: \{dir}",
  )
  let mut all_passed = true
  let errors : Array[String] = []
  for filepath in files {
    let source = @fs.read_file_to_string(filepath)
    let (_, reports) = @parser.parse_string(source)
    assert_eq(reports.length(), 0, msg=filepath)
    assert_true(
      @similarity.extract_functions(source).length() >= 2,
      msg=filepath,
    )
    let (expect_similar, threshold) = parse_expectation(source)
    match run_fixture_test(filepath, expect_similar, threshold) {
      Ok(_) => ()
      Err(msg) => {
        all_passed = false
        errors.push(msg)
      }
    }
  }
  if !all_passed {
    for err in errors {
      println(err)
    }
  }
  inspect(all_passed, content="true")
}
