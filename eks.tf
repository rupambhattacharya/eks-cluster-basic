

resource "aws_eks_cluster" "hello" {
  name     = "hello_world"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.public.id, aws_subnet.private.id]
  }

  tags = {
    Name = "EKS"
  }
}

output "endpoint" {
  value = aws_eks_cluster.hello.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.hello.certificate_authority[0].data
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.hello.name
  node_group_name = "hello_world"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["<subnet-1>", "<subnet-2>"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}