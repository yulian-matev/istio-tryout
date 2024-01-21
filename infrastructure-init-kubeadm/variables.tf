variable "access_key" { #Todo: uncomment the default value and add your access key.
        description = "Access key to AWS console"
        default = "xxxxx" 
        type = string
}

variable "secret_key" {  #Todo: uncomment the default value and add your secert key.
        description = "Secret key to AWS console"
        default = "xxxxxxx"
        type = string
}

variable "ami_key_pair_name" { #Todo: uncomment the default value and add your pem key pair name. Hint: don't write '.pem' exction just the key name
        default = "eu-key-ym"
        type = string 
}
variable "number_of_worker" {
        description = "number of worker instances to be join on cluster."
        default = 1
}

variable "region" {
        description = "The region zone on AWS"
        default = "eu-central-1" #The zone I selected is us-east-1, if you change it make sure to check if ami_id below is correct.
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-0faab6bdbac9486fb" #Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-12-07
        #default = "ami-0d118c6e63bcb554e"   #Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2023-10-25
}

variable "instance_type" {
        default = "t2.medium" #the best type to start k8s with it,
}