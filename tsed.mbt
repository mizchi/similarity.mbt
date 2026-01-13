///|
pub(all) struct TSEDOptions {
  apted_options : APTEDOptions
  min_lines : Int
  min_tokens : Int?
  size_penalty : Bool
}

///|
pub fn TSEDOptions::default() -> TSEDOptions {
  {
    apted_options: APTEDOptions::default(),
    min_lines: 5,
    min_tokens: None,
    size_penalty: true,
  }
}

///|
pub fn calculate_tsed(
  tree1 : TreeNode,
  tree2 : TreeNode,
  options : TSEDOptions,
) -> Double {
  let distance = compute_edit_distance(tree1, tree2, options.apted_options)
  let size1 = tree1.get_subtree_size().to_double()
  let size2 = tree2.get_subtree_size().to_double()
  let max_size = max_double(size1, size2)
  let mut tsed_similarity = if max_size > 0.0 {
    max_double(1.0 - distance / max_size, 0.0)
  } else {
    1.0
  }
  if distance == 0.0 && size1 != size2 {
    let size_ratio = min_double(size1, size2) / max_double(size1, size2)
    let size_diff = (size1 - size2).abs()
    tsed_similarity = if size_diff > 10.0 {
      tsed_similarity * 0.5
    } else if size_ratio < 0.95 || size_diff > 3.0 {
      tsed_similarity * size_ratio.sqrt()
    } else {
      tsed_similarity
    }
  }
  if options.size_penalty {
    if max_size < 10.0 && distance > 0.0 {
      tsed_similarity = tsed_similarity * 0.8
    } else if max_size < 30.0 && distance > 0.0 {
      tsed_similarity = tsed_similarity * 0.9
    }
  }
  let mut similarity = tsed_similarity
  let size_ratio = min_double(size1, size2) / max_double(size1, size2)
  if options.size_penalty {
    let min_size = min_double(size1, size2)
    if min_size < 30.0 {
      let short_function_factor = (min_size / 30.0).sqrt()
      similarity = similarity * short_function_factor
      if min_size < 10.0 {
        similarity = similarity * 0.5
      } else if min_size < 20.0 {
        similarity = similarity * 0.7
      }
    }
    if size_ratio < 0.5 {
      similarity = similarity * size_ratio.sqrt()
    }
  }
  similarity
}
