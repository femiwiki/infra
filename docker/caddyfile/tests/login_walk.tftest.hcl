# The login and signup pages under each spelling count toward login_walk and login_uselang

run "login_walk" {
  command = plan

  assert {
    condition = length([
      for query in [
        "title=특수:로그인&returnto=대문",
        "title=%ED%8A%B9%EC%88%98%3A%EB%A1%9C%EA%B7%B8%EC%9D%B8&returnto=x",
        "title=Special:UserLogin",
        "returnto=x&title=특수:계정만들기",
        "title=%ED%8A%B9%EC%88%98:%EA%B3%84%EC%A0%95%EB%A7%8C%EB%93%A4%EA%B8%B0",
        "title=Special:CreateAccount/x",
      ] : query if !can(regex(output.login_walk_query, query))
    ]) == 0
    error_message = "A login or signup page would not be counted."
  }

  assert {
    condition = length([
      for query in [
        "title=특수:로그인기록",
        "title=로그인",
        "title=Special:UserLogout",
        "search=특수:로그인",
      ] : query if can(regex(output.login_walk_query, query))
    ]) == 0
    error_message = "A page other than login or signup would be counted."
  }
}

run "login_uselang" {
  command = plan

  assert {
    condition = length([
      for query in [
        "title=특수:로그인&uselang=en",
        "title=%ED%8A%B9%EC%88%98%3A%EB%A1%9C%EA%B7%B8%EC%9D%B8&returnto=x&uselang=ja",
        "uselang=en&title=Special:CreateAccount",
        "uselang=en&returnto=x&title=%ED%8A%B9%EC%88%98:%EA%B3%84%EC%A0%95%EB%A7%8C%EB%93%A4%EA%B8%B0",
      ] : query if !can(regex(output.login_uselang_query, query))
    ]) == 0
    error_message = "A login language link would not be counted."
  }

  assert {
    condition = length([
      for query in [
        "title=특수:로그인&returnto=x",
        "title=대문&uselang=en",
        "uselang=en&title=특수:로그인기록",
      ] : query if can(regex(output.login_uselang_query, query))
    ]) == 0
    error_message = "A login page without uselang, or another page, would be counted."
  }
}
