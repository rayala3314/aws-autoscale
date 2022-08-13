resource "aws_iam_role" "ssm-user" {
  name = "ssm-user"
  assume_role_policy = "${file("ec2-role.json")}"

}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.ssm-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

