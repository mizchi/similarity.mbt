///|
test "worklist parsing preserves nonempty file paths" {
  assert_eq(parse_worklist("a.mbt\n\nb.mbt\n"), ["a.mbt", "b.mbt"])
  assert_eq(parse_worklist(""), [])
}

///|
test "worker partition is stable and covers each file once" {
  let files = ["a.mbt", "b.mbt", "c.mbt", "d.mbt", "e.mbt"]
  assert_eq(select_files(files, 0, 2), ["a.mbt", "c.mbt", "e.mbt"])
  assert_eq(select_files(files, 1, 2), ["b.mbt", "d.mbt"])
  assert_eq(select_files(files, 3, 2), ["b.mbt", "d.mbt"])
  assert_eq(select_files(files, -1, 2), ["a.mbt", "c.mbt", "e.mbt"])
  assert_eq(select_files(files, 0, 0), files)
  assert_eq(select_files(files, 0, 1), files)
}
