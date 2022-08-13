resource "aws_iam_role" "ssm-user" {
  name = "ssm-user"
  assume_role_policy = "${file("ec2-role.json")}"

}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.ssm-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_ssm_activation" "foo" {
  name               = "test_ssm_activation"
  description        = "Test"
  iam_role           = aws_iam_role.ssm-user.id
  registration_limit = "5"
  depends_on         = [aws_iam_role_policy_attachment.test_attach]
}