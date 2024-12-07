variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "source_folder_name" {
  description = "Name of the source folder"
  type        = string
}

variable "destination_folder_name" {
  description = "Name of the destination folder"
  type        = string
}

variable "archiving_folder_name" {
  description = "Name of the archiving folder"
  type        = string
}