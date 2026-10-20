# Special:Export under each of its names and spellings, and only it, counts toward the export zone

run "export" {
  command = plan

  assert {
    condition = length([
      for uri in [
        "/w/특수:내보내기",
        "/w/%ED%8A%B9%EC%88%98:%EB%82%B4%EB%B3%B4%EB%82%B4%EA%B8%B0",
        "/w/Special:Export/x",
        "/index.php?title=Special:Export/x",
        "/index.php?title=%ED%8A%B9%EC%88%98%3A%EB%82%B4%EB%B3%B4%EB%82%B4%EA%B8%B0&action=submit",
      ] : uri if !can(regex(output.export_uri, uri))
    ]) == 0
    error_message = "An export would not be counted."
  }

  assert {
    condition = length([
      for uri in [
        "/w/대문",
        "/w/특수:가져오기",
        "/w/Special:ExportX",
        "/index.php?title=Exports",
      ] : uri if can(regex(output.export_uri, uri))
    ]) == 0
    error_message = "A page other than Special:Export would be counted."
  }
}
