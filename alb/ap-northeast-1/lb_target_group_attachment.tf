resource "aws_lb_target_group_attachment" "arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--targetgroup--femiwiki-restbase--b7d622c32d8f4324-20190525152003787000000001" {
  target_group_arn = "${aws_lb_target_group.femiwiki-restbase.arn}"
  target_id        = "i-0a60b966b04378ab1"
}

resource "aws_lb_target_group_attachment" "arn--aws--elasticloadbalancing--ap-northeast-1--302617221463--targetgroup--femiwiki-server--c4ab492257756dd9-20190525152003864500000002" {
  target_group_arn = "${aws_lb_target_group.femiwiki-server.arn}"
  target_id        = "i-0449b4506bbde43ad"
}
