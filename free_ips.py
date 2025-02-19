import boto3
import json

def get_available_cidr():
    ec2 = boto3.client("ec2", region_name="us-west-1")

    # Fetch existing VPCs
    vpcs = ec2.describe_vpcs()["Vpcs"]
    used_cidrs = {vpc["CidrBlock"] for vpc in vpcs}

    # Define a range to check (adjust as needed)
    base_cidr = "10.0.0.0/18"
    available_cidr = None

    # Check for an available CIDR (simplified logic)
    if base_cidr not in used_cidrs:
        available_cidr = base_cidr
    else:
        for i in range(1, 256):  # Loop through /16 ranges
            candidate = f"10.{i}.0.0/18"
            if candidate not in used_cidrs:
                available_cidr = candidate
                break

    if not available_cidr:
        raise Exception("No available CIDR block found.")

    # Return the result in Terraform-friendly JSON
    print(json.dumps({"cidr_block": available_cidr}))

if __name__ == "__main__":
    get_available_cidr()