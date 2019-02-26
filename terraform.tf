terraform {
    backend "s3" {
        bucket = "weliff-terraform-state"
        key = "beerstore-curso-online"
        region = "us-east-1"
        profile = "terraform"
    }
}