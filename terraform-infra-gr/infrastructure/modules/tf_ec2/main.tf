locals {
  identifier = var.append_workspace ? "${var.identifier}-${terraform.workspace}" : var.identifier
  default_tags = {
    Environment = terraform.workspace
    Name        = local.identifier
  }
  tags = merge(local.default_tags, var.tags)
}

data "template_file" "user_data" {
  template = "${file("scripts/av.tpl")}"

}

resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  iam_instance_profile   = var.iam_instance_profile
  # user_data              = "${base64encode(file(install_bamboo.ps1))}"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_name
  tags = local.tags
}

resource "aws_volume_attachment" "ebs_att" {
  count    = var.extra_ebs == true ? 1 : 0
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.volumen[count.index].id
  instance_id = aws_instance.server.id
}

resource "aws_ebs_volume" "volumen" {
  count    = var.extra_ebs == true ? 1 : 0
  availability_zone = aws_instance.server.availability_zone
  size              = 200
}

resource "aws_eip" "lb" {
  count    = var.add_eip == true ? 1 : 0
  instance = aws_instance.server.id
  vpc      = true
}
