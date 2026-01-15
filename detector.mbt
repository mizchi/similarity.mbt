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
  { threshold: 0.88, min_lines: 3, size_penalty: true }
}

///|
fn create_tsed_options(options : DetectorOptions) -> TSEDOptions {
  {
    apted_options: APTEDOptions::default(),
    min_lines: options.min_lines,
    min_tokens: None,
    size_penalty: options.size_penalty,
  }
}

///|
fn compare_functions(
  func1 : FunctionInfo,
  func2 : FunctionInfo,
  options : DetectorOptions,
  tsed_options : TSEDOptions,
) -> SimilarityResult? {
  let lines1 = func1.end_line - func1.start_line + 1
  let lines2 = func2.end_line - func2.start_line + 1
  if lines1 < options.min_lines || lines2 < options.min_lines {
    return None
  }
  // Early pruning: skip if tree sizes are too different
  let size1 = func1.tree.get_subtree_size()
  let size2 = func2.tree.get_subtree_size()
  let size_ratio = if size1 > size2 {
    size2.to_double() / size1.to_double()
  } else {
    size1.to_double() / size2.to_double()
  }
  // If size ratio is below threshold, similarity will be low
  if size_ratio < options.threshold * 0.5 {
    return None
  }
  let similarity = calculate_tsed(func1.tree, func2.tree, tsed_options)
  if similarity >= options.threshold {
    let avg_lines = (lines1 + lines2) / 2
    let score = similarity * avg_lines.to_double()
    Some({ func1, func2, similarity, score })
  } else {
    None
  }
}

///|
pub fn detect_similarities(
  source : String,
  options : DetectorOptions,
) -> Array[SimilarityResult] {
  // Delegate to cross-file detection with single file
  let cross_results = detect_cross_file_similarities(
    [("<single>", source)],
    options,
  )
  cross_results.map(fn(r) {
    let (_, _, result) = r
    result
  })
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
  let tsed_options = create_tsed_options(options)
  let results : Array[(String, String, SimilarityResult)] = []
  let n = all_functions.length()
  for i = 0; i < n; i = i + 1 {
    for j = i + 1; j < n; j = j + 1 {
      let (file1, func1) = all_functions[i]
      let (file2, func2) = all_functions[j]
      match compare_functions(func1, func2, options, tsed_options) {
        Some(result) => results.push((file1, file2, result))
        None => ()
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
