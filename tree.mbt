///|
pub(all) struct TreeNode {
  label : String
  value : String
  mut children : Array[TreeNode]
  id : Int
}

///|
pub fn TreeNode::new(label : String, value : String, id : Int) -> TreeNode {
  { label, value, children: [], id }
}

///|
pub fn TreeNode::add_child(self : TreeNode, child : TreeNode) -> Unit {
  self.children.push(child)
}

///|
pub fn TreeNode::get_subtree_size(self : TreeNode) -> Int {
  let mut size = 1
  for child in self.children {
    size = size + child.get_subtree_size()
  }
  size
}

///|
pub impl Show for TreeNode with output(self, logger) {
  logger.write_string("TreeNode(")
  logger.write_string(self.label)
  logger.write_string(", ")
  logger.write_string(self.value)
  logger.write_string(", children=")
  logger.write_string(self.children.length().to_string())
  logger.write_string(")")
}
