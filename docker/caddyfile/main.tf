# serving/Caddyfile with the lists that are kept here filled in

terraform {
  required_version = "1.13.1"
}

locals {
  # Special pages the special_pages zone lets through, each with its aliases from
  # api.php?action=query&meta=siteinfo&siprop=specialpagealiases
  special_exempt_pages = [
    ["로그인", "사용자로그인", "UserLogin", "Login"],
    ["계정만들기", "가입", "CreateAccount"],
    ["검색", "찾기", "Search"],
    ["최근바뀜", "RecentChanges"],
    ["임의문서", "Random", "RandomPage"],
    ["특수문서", "특수기능", "SpecialPages"],
    ["모바일설정", "MobileOptions"],
    ["분류", "Categories"],
    ["캡차", "Captcha"],
    ["MathShowImage"],
    ["비밀번호재설정", "비밀번호초기화", "PasswordReset"],
    ["이메일확인", "이메일인증", "ConfirmEmail"],
    ["이메일인증취소", "이메일인증해제", "InvalidateEmail"],
    ["개체데이터", "EntityData"],
    ["MWO인증", "OAuth", "MWOAuth"],
    ["파일경로", "그림경로", "FilePath"],
    ["넘겨주기", "Redirect"],
    ["로그아웃", "사용자로그아웃", "UserLogout", "Logout"],
  ]

  # Each alias as written and percent-encoded, as the URI carries either
  text = replace(file("${path.module}/../../serving/Caddyfile"), "SPECIAL_EXEMPT_PAGES_FROM_DOCKER_CADDYFILE", join("|", flatten([
    for page in local.special_exempt_pages : [
      for alias in page : alias == urlencode(alias) ? [alias] : [alias, urlencode(alias)]
    ]
  ])))
}

output "text" {
  value = local.text
}

output "special_exempt_uri" {
  description = "FW_SPECIAL_EXEMPT_URI's default as filled in, for the tests"
  value       = regex("\\{\\$FW_SPECIAL_EXEMPT_URI:([^\\n]*)\\}\\n", local.text)[0]
}
