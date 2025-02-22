resource "null_resource" "wireguard_aws" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("D:\\Masters In CS\\Subjects\\Spring 2025\\awskey.pem")
    host        = aws_instance.wireguard_aws.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install wireguard -y",
      "wg genkey | tee privatekey | wg pubkey > publickey"
    ]
  }
}

resource "null_resource" "wireguard_azure" {
  connection {
    type        = "ssh"
    user        = "adminuser"
    private_key = file("D:\\Masters In CS\\Subjects\\Spring 2025\\AzureLinuxServer_key.pem")
    host        = azurerm_linux_virtual_machine.wireguard_azure.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install wireguard -y",
      "wg genkey | tee privatekey | wg pubkey > publickey"
    ]
  }
}
