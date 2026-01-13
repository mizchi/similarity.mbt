// Different: Test with struct creation vs Loop with struct creation
// Expected: no match at threshold 0.85

struct Item {
  name : String
  value : Int
  order : Int
}

///|
fn test_struct_creation() -> Unit {
  let item1 : Item = {
    name: "width",
    value: 100,
    order: 0,
  }
  let item2 : Item = {
    name: "height",
    value: 50,
    order: 1,
  }
  let result = process_items([item1, item2])
  assert_eq(result.length(), 2)
}

///|
fn collect_matches(items : Array[Item], filter : (Item) -> Bool) -> Array[Item] {
  let matches : Array[Item] = []
  for item in items {
    if filter(item) {
      let new_item : Item = {
        name: item.name,
        value: item.value * 2,
        order: item.order + 100,
      }
      matches.push(new_item)
    }
  }
  matches
}

fn process_items(items : Array[Item]) -> Array[Item] {
  items
}
