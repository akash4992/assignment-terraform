Note: If the default value is removed from the variables.tf file, the user will be able to dynamically change the main region.

Terraform init 
Terraform plan
Terraform apply

You can either define the `main_region` and `peer_regions` directly in the `terraform.tfvars` file or provide them dynamically via the command line.

#### Option 1: Using `terraform.tfvars`

Add the following content to the `terraform.tfvars` file to set default values for the regions:

```hcl
main_region  = "us-east-1"
peer_regions = ["us-west-1", "ap-south-1"]
#### With Command-Line Variable Override:

```bash
terraform plan -var "main_region=us-west-2" -var 'peer_regions=["us-west-1","ap-south-1"]'
terraform apply -var "main_region=us-west-2" -var 'peer_regions=["us-west-1","ap-south-1"]'
```

If you do not define variables in `terraform.tfvars` or via the command line, Terraform will prompt you for input during the `terraform apply` process:

```
main_region:
  [Enter AWS main region, e.g., us-east-1]

peer_regions:
  [Enter list of peer regions, e.g., ["us-west-1", "ap-south-1"]]