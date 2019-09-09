resource "aws_lb" "alb" {
    name = "hibicode-beerstore-alb"
    subnets = "${flatten(chunklist(aws_subnet.public_subnet.*.id, 1))}"

    security_groups = ["${aws_security_group.allow_lb.id}"]

    enable_deletion_protection = false
  
}

resource "aws_lb_target_group" "alb_tg" {
    name = "hibicode-beerstore"
    vpc_id = "${aws_vpc.main.id}"
    port = 8080
    protocol = "HTTP"

    health_check {
        path = "/actuator/health"
        matcher = 200
        interval = 120
        healthy_threshold = 5
        unhealthy_threshold = 3
        timeout = 10
    }

}

resource "aws_lb_target_group_attachment" "alb_group_attachment" {
    count = "3"
    target_group_arn = "${aws_lb_target_group.alb_tg.arn}"
    target_id = "${element(aws_instance.instances.*.id, count.index)}"
    port = 8080
}

resource "aws_lb_listener" "alb_listener" {
    port = 80
    load_balancer_arn = "${aws_lb.alb.arn}"
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.alb_tg.arn}"
    }
}

output "loadbalancer" {
  value = "${aws_lb.alb.dns_name}"
}

