resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Principal": {"Service": "ssm.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
}
EOF
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}

resource "aws_ssm_activation" "foo" {
  name               = "test_ssm_activation"
  description        = "Test"
  iam_role           = aws_iam_role.test_role.id
  registration_limit = "5"
  depends_on         = [aws_iam_role_policy_attachment.test_attach]
}

resource "aws_launch_template" "ssm_testing" {
  name                   = "ssm_test"
  key_name               = "Ray"
  image_id               = data.aws_ami.ami.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.tribehealth_platform.id]
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  subnet_id              = "${aws_subnet.testapp_private_subnet.id}"
}
