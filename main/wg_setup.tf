resource "null_resource" "wireguard_aws" {
  depends_on = [ module.aws ]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("D:\\Masters In CS\\Subjects\\Spring 2025\\Cloud-Security-and-Multi-Cloud-Environments\\main\\aws\\awskey.pem")
    host        = module.aws.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y epel-release",  # ✅ Ensure Extra Packages for Enterprise Linux is enabled
      "sudo yum install -y wireguard-tools",  # ✅ Correct package name
      "sudo modprobe wireguard",  # ✅ Load WireGuard module
      "wg genkey | tee privatekey | wg pubkey > publickey"
    ]
  }
}

resource "null_resource" "wireguard_azure" {
  depends_on = [ module.azure ] 
  connection {
    type        = "ssh"
    user        = "adminuser"
    private_key = file("D:\\Masters In CS\\Subjects\\Spring 2025\\Cloud-Security-and-Multi-Cloud-Environments\\main\\azure\\LinuxServer_key.pem")
    host        =  module.azure.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update || sudo yum update -y",  # ✅ Update package lists for both Ubuntu & RHEL
      "sudo apt install -y wireguard || sudo yum install -y wireguard-tools",  # ✅ Install WireGuard for both OS types
      "sudo modprobe wireguard",  # ✅ Load WireGuard module
      "wg genkey | tee privatekey | wg pubkey > publickey"
    ]
  }
}
