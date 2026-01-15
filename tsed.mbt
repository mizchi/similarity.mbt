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
  let total_size = size1 + size2
  let tsed_similarity = if total_size > 0.0 {
    @cmp.maximum(1.0 - 2.0 * distance / total_size, 0.0)
  } else {
    1.0
  }
  let mut similarity = tsed_similarity
  let min_size = @cmp.minimum(size1, size2)
  let max_size = @cmp.maximum(size1, size2)
  let size_ratio = min_size / max_size

  if options.size_penalty && distance > 0.0 {
    // Only apply penalty when there are structural differences (distance > 0)
    // distance=0 means structurally identical - no penalty needed

    // Penalty for very small functions (high false positive risk)
    if min_size < 10.0 {
      similarity = similarity * 0.7
    }

    // Penalty for large functions with structural differences
    // Large functions sharing common patterns should be penalized
    if max_size > 50.0 {
      let distance_ratio = distance / max_size
      // More distance = more penalty for large functions
      let large_func_penalty = 1.0 - distance_ratio * 0.3
      similarity = similarity * large_func_penalty
    }

    // Penalty for significant size mismatch
    if size_ratio < 0.5 {
      similarity = similarity * size_ratio.sqrt()
    }
  }

  similarity
}
