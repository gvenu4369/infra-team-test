variable "access_key" {
   default = "<INSERT AWS ACCESS KEY>"
}
variable "secret_key" {
   default = "<INSERT AWS SECRET KEY>"
}
variable "keyName" {
   default = "<INSERT NAME OF YOUR AWS PEM KEY>"
}
variable "keyPath" {
   default = "~/<INSERT NAME AND PATH OF THE AWS PEM KEY>.pem"
}
variable "subnet" {
   default = "subnet-<INSERT VPC SUBNET>"
}
variable "securityGroups" {
   type = list
   default = [ "sg-<INSERT VPC SECURITY GROUP>" ]
}