# Logged-out special pages the special_pages zone has to let through, or count

run "special_pages" {
  command = plan

  assert {
    condition = length([
      for uri in [
        "/w/특수:로그인",
        "/w/%ED%8A%B9%EC%88%98:%EB%A1%9C%EA%B7%B8%EC%9D%B8?returnto=%EB%8C%80%EB%AC%B8",
        "/w/Special:UserLogin",
        "/index.php?title=%ED%8A%B9%EC%88%98%3A%EA%B3%84%EC%A0%95%EB%A7%8C%EB%93%A4%EA%B8%B0&returnto=x",
        "/index.php?search=x&title=특수:검색",
        "/w/특수:최근바뀜",
        "/w/Special:Random",
        "/w/특수:MWO인증/authorize",
        "/w/%ED%8A%B9%EC%88%98:MWO%EC%9D%B8%EC%A6%9D%2Fauthorize",
        "/w/Special:MathShowImage?hash=x",
        "/w/특수:사용자로그아웃",
      ] : uri if !can(regex(output.special_exempt_uri, uri))
    ]) == 0
    error_message = "A page readers or logins need would be rate limited."
  }

  assert {
    condition = length([
      for uri in [
        "/w/특수:가리키는문서/대문",
        "/w/%ED%8A%B9%EC%88%98:%EA%B8%B0%EC%97%AC/x",
        "/w/특수:로그인기록",
        "/w/Special:RandomRootPage",
        "/index.php?title=Special:Export/x",
      ] : uri if can(regex(output.special_exempt_uri, uri))
    ]) == 0
    error_message = "A special page that should count toward the zone would be let through."
  }
}
