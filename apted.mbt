///|
pub(all) struct APTEDOptions {
  rename_cost : Double
  delete_cost : Double
  insert_cost : Double
  compare_values : Bool
}

///|
pub fn APTEDOptions::default() -> APTEDOptions {
  {
    rename_cost: 0.3,
    delete_cost: 1.0,
    insert_cost: 1.0,
    compare_values: false,
  }
}

///|
fn min_double(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn max_double(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn compute_edit_distance(
  tree1 : TreeNode,
  tree2 : TreeNode,
  options : APTEDOptions,
) -> Double {
  let memo : Map[Int64, Double] = {}
  compute_edit_distance_recursive(tree1, tree2, options, memo)
}

///|
fn memo_key(id1 : Int, id2 : Int) -> Int64 {
  // Pack two 32-bit ints into one 64-bit int
  (id1.to_int64() << 32) | (id2.to_int64() & 0xFFFFFFFFL)
}

///|
fn compute_edit_distance_recursive(
  node1 : TreeNode,
  node2 : TreeNode,
  options : APTEDOptions,
  memo : Map[Int64, Double],
) -> Double {
  let key = memo_key(node1.id, node2.id)
  match memo.get(key) {
    Some(cost) => return cost
    None => ()
  }
  if node1.children.is_empty() && node2.children.is_empty() {
    let cost = if options.compare_values {
      if node1.label == node2.label && node1.value == node2.value {
        0.0
      } else {
        options.rename_cost
      }
    } else if node1.label == node2.label {
      0.0
    } else {
      options.rename_cost
    }
    memo.set(key, cost)
    return cost
  }
  let delete_all_cost = options.delete_cost *
    node1.get_subtree_size().to_double()
  let insert_all_cost = options.insert_cost *
    node2.get_subtree_size().to_double()
  let mut rename_plus_cost = if options.compare_values {
    if node1.label == node2.label && node1.value == node2.value {
      0.0
    } else {
      options.rename_cost
    }
  } else if node1.label == node2.label {
    0.0
  } else {
    options.rename_cost
  }
  if not(node1.children.is_empty()) || not(node2.children.is_empty()) {
    let child_cost_matrix : Map[Int64, Double] = {}
    for child1 in node1.children {
      for child2 in node2.children {
        let cost = compute_edit_distance_recursive(
          child1, child2, options, memo,
        )
        child_cost_matrix.set(memo_key(child1.id, child2.id), cost)
      }
    }
    let alignment_cost = compute_children_alignment(
      node1.children,
      node2.children,
      child_cost_matrix,
      options,
    )
    rename_plus_cost = rename_plus_cost + alignment_cost
  }
  let min_cost = min_double(
    min_double(delete_all_cost, insert_all_cost),
    rename_plus_cost,
  )
  memo.set(key, min_cost)
  min_cost
}

///|
fn compute_children_alignment(
  children1 : Array[TreeNode],
  children2 : Array[TreeNode],
  cost_matrix : Map[Int64, Double],
  options : APTEDOptions,
) -> Double {
  let m = children1.length()
  let n = children2.length()
  let dp : Array[Array[Double]] = Array::makei(m + 1, fn(_) {
    Array::make(n + 1, 0.0)
  })
  for i = 1; i <= m; i = i + 1 {
    dp[i][0] = dp[i - 1][0] +
      options.delete_cost * children1[i - 1].get_subtree_size().to_double()
  }
  for j = 1; j <= n; j = j + 1 {
    dp[0][j] = dp[0][j - 1] +
      options.insert_cost * children2[j - 1].get_subtree_size().to_double()
  }
  for i = 1; i <= m; i = i + 1 {
    for j = 1; j <= n; j = j + 1 {
      let child1 = children1[i - 1]
      let child2 = children2[j - 1]
      let edit_cost = cost_matrix
        .get(memo_key(child1.id, child2.id))
        .unwrap_or(0.0)
      let delete_cost = dp[i - 1][j] +
        options.delete_cost * child1.get_subtree_size().to_double()
      let insert_cost = dp[i][j - 1] +
        options.insert_cost * child2.get_subtree_size().to_double()
      let match_cost = dp[i - 1][j - 1] + edit_cost
      dp[i][j] = min_double(min_double(delete_cost, insert_cost), match_cost)
    }
  }
  dp[m][n]
}
