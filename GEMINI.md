# Gemini Project: K8s Infrastructure

This project uses Terraform to provision the infrastructure for a Kubernetes cluster on AWS.

## Project Overview

The goal of this project is to create a Kubernetes cluster from scratch. This first phase focuses on provisioning the necessary infrastructure using Terraform. The infrastructure consists of:

*   A Virtual Private Cloud (VPC) to provide a private network for the cluster.
*   Three EC2 instances: one master node and two worker nodes.
*   A security group to allow SSH access to the instances.
*   An SSH key pair for secure access to the instances.

## Technologies

*   **Terraform:** Used for Infrastructure as Code (IaC) to define and manage the AWS resources.
*   **AWS:** The cloud provider where the infrastructure is deployed.

## File Structure

The project is organized into the following Terraform files:

*   `main.tf`: Contains the main Terraform configuration, including the AWS provider setup.
*   `variables.tf`: Defines the variables used in the project, such as the AWS region and instance type.
*   `vpc.tf`: Defines the VPC, subnet, internet gateway, and route table.
*   `ec2.tf`: Defines the EC2 instances, security group, and SSH key pair.
*   `outputs.tf`: Defines the outputs of the project, such as the public IP addresses of the EC2 instances.

## Building and Running

To build and run this project, you need to have Terraform installed and configured with your AWS credentials.

1.  **Provide your public key:**
    Create a file named `terraform.tfvars` in the `K8s-infra` directory and add the following content, replacing `<your-public-key>` with your SSH public key:
    ```
    public_key = "<your-public-key>"
    ```

2.  **Initialize Terraform:**
    This command initializes the Terraform working directory and downloads the necessary provider plugins.
    ```bash
    terraform init
    ```

3.  **Plan the changes:**
    This command shows you what changes Terraform will make to your infrastructure.
    ```bash
    terraform plan
    ```

4.  **Apply the changes:**
    This command applies the changes to your infrastructure.
    ```bash
    terraform apply
    ```

## Development Conventions

*   The project is organized into multiple files to separate concerns.
*   Variables are used to make the project configurable.
*   Outputs are used to expose important information about the infrastructure.
