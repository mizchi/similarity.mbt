///|
pub(all) struct SimilarityResult {
  func1 : FunctionInfo
  func2 : FunctionInfo
  similarity : Double
  score : Double
}

///|
pub impl Show for SimilarityResult with output(self, logger) {
  logger.write_string(self.func1.name)
  logger.write_string(" <-> ")
  logger.write_string(self.func2.name)
  logger.write_string(" (similarity: ")
  let pct = (self.similarity * 100.0).to_int()
  logger.write_string(pct.to_string())
  logger.write_string("%, score: ")
  let score_int = (self.score * 10.0).to_int()
  logger.write_string((score_int / 10).to_string())
  logger.write_string(".")
  logger.write_string((score_int % 10).to_string())
  logger.write_string(")")
}

///|
pub(all) struct DetectorOptions {
  threshold : Double
  min_lines : Int
  size_penalty : Bool
}

///|
pub fn DetectorOptions::default() -> DetectorOptions {
  { threshold: 0.85, min_lines: 3, size_penalty: true }
}

///|
pub fn detect_similarities(
  source : String,
  options : DetectorOptions,
) -> Array[SimilarityResult] {
  let functions = extract_functions(source)
  let tsed_options = {
    apted_options: APTEDOptions::default(),
    min_lines: options.min_lines,
    min_tokens: None,
    size_penalty: options.size_penalty,
  }
  let results : Array[SimilarityResult] = []
  let n = functions.length()
  for i = 0; i < n; i = i + 1 {
    for j = i + 1; j < n; j = j + 1 {
      let func1 = functions[i]
      let func2 = functions[j]
      let lines1 = func1.end_line - func1.start_line + 1
      let lines2 = func2.end_line - func2.start_line + 1
      if lines1 < options.min_lines || lines2 < options.min_lines {
        continue
      }
      let similarity = calculate_tsed(func1.tree, func2.tree, tsed_options)
      if similarity >= options.threshold {
        let avg_lines = (lines1 + lines2) / 2
        let score = similarity * avg_lines.to_double()
        results.push({ func1, func2, similarity, score })
      }
    }
  }
  results.sort_by(fn(a, b) { b.score.compare(a.score) })
  results
}

///|
pub fn detect_cross_file_similarities(
  sources : Array[(String, String)],
  options : DetectorOptions,
) -> Array[(String, String, SimilarityResult)] {
  let all_functions : Array[(String, FunctionInfo)] = []
  for pair in sources {
    let (filename, source) = pair
    let functions = extract_functions(source)
    for func in functions {
      all_functions.push((filename, func))
    }
  }
  let tsed_options = {
    apted_options: APTEDOptions::default(),
    min_lines: options.min_lines,
    min_tokens: None,
    size_penalty: options.size_penalty,
  }
  let results : Array[(String, String, SimilarityResult)] = []
  let n = all_functions.length()
  for i = 0; i < n; i = i + 1 {
    for j = i + 1; j < n; j = j + 1 {
      let (file1, func1) = all_functions[i]
      let (file2, func2) = all_functions[j]
      let lines1 = func1.end_line - func1.start_line + 1
      let lines2 = func2.end_line - func2.start_line + 1
      if lines1 < options.min_lines || lines2 < options.min_lines {
        continue
      }
      let similarity = calculate_tsed(func1.tree, func2.tree, tsed_options)
      if similarity >= options.threshold {
        let avg_lines = (lines1 + lines2) / 2
        let score = similarity * avg_lines.to_double()
        results.push((file1, file2, { func1, func2, similarity, score }))
      }
    }
  }
  results.sort_by(fn(a, b) {
    let (_, _, res_a) = a
    let (_, _, res_b) = b
    res_b.score.compare(res_a.score)
  })
  results
}
