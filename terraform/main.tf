terraform {
  required_version = "> 0.7.0"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

provider "aws" {
  version = "~> 1.16"
  region  = "${var.aws_region}"
}

resource "aws_iam_service_linked_role" "lex" {
 aws_service_name = "lex.amazonaws.com"
}

resource "null_resource" "put_slot_type" {
  provisioner "local-exec" {
    command = "aws lex-models put-slot-type --region ${var.aws_region} --name FlowerTypes --cli-input-json file://FlowerTypes.json"
  }
}

resource "null_resource" "put_intent" {
  depends_on = ["null_resource.put_slot_type"]
  provisioner "local-exec" {
    command = "aws lex-models put-intent --region ${var.aws_region} --name OrderFlowers --cli-input-json file://OrderFlowers.json"
  }
}

resource "null_resource" "put_bot" {
  depends_on = ["null_resource.put_intent"]
  provisioner "local-exec" {
    command = "aws lex-models put-bot --region ${var.aws_region} --name FlowerBot --cli-input-json file://FlowerBot.json"
  }
}


resource "null_resource" "delete_bot" {
  depends_on = ["null_resource.delete_intent"]
provisioner "local-exec" {
    when    = "destroy"
    command = "aws lex-models delete-bot --name FlowerBot" 
    on_failure = "continue" 
  }
}

resource "null_resource" "delete_intent" {
  depends_on = ["null_resource.delete_slot_type"]
provisioner "local-exec" {
    when    = "destroy"
    command = "aws lex-models delete-intent --name OrderFlowers" 
    on_failure = "continue" 
  }
}

resource "null_resource" "delete_slot_type" {
  provisioner "local-exec" {
    when    = "destroy"
    command = "aws lex-models delete-slot-type --name FlowerTypes"
    on_failure = "continue"
  }
}




