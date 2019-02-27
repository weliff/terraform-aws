resource "aws_key_pair" "keypair" {
  public_key = "${file("key/beerstore_key.pub")}"
}


resource "aws_instance" "instances" {
  count = "3"

  ami = "ami-035be7bafff33b6b6"
  instance_type = "t2.micro"
  
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"

  key_name = "${aws_key_pair.keypair.key_name}"

  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}", 
    "${aws_security_group.allow_outbound.id}", 
    "${aws_security_group.cluster_communication.id}",
    "${aws_security_group.allow_portainer.id}"]

  tags {
    Name = "hibicode_instances"
  }
}

data "template_file" "hosts" {
  template = "${file("./templates/hosts.tpl")}"

  vars {
    PRIVATE_IP_0 = "${aws_instance.instances.*.private_ip[0]}"
    PUBLIC_IP_0 = "${aws_instance.instances.*.public_ip[0]}"
    PUBLIC_IP_1 = "${aws_instance.instances.*.public_ip[1]}"
    PUBLIC_IP_2 = "${aws_instance.instances.*.public_ip[2]}"
  }
}

resource "local_file" "hosts" {
  content = "${data.template_file.hosts.rendered}"
  filename = "./hosts"
}

output "public_ips" {
  value = "${join(", ", aws_instance.instances.*.public_ip)}"
}

