# Project Gemini: A Kubernetes Journey

## Introduction

This document chronicles the creation of a complete, end-to-end cloud-native application deployment and monitoring system. The goal was to build a Kubernetes cluster from scratch on AWS, deploy a containerized application, automate the process with a CI/CD pipeline, and implement robust monitoring.

This project was built interactively and serves as a practical, real-world example of the challenges and solutions encountered in modern DevOps practices.

## The Journey: What We Built

We successfully built a full-stack environment in six distinct phases:

1.  **Infrastructure (Terraform):** We defined and provisioned all necessary AWS resources, including a VPC, subnets, security groups, and three EC2 instances (one master, two workers).

2.  **Configuration (Ansible):** We used Ansible playbooks to transform the blank EC2 instances into a fully functional Kubernetes cluster, installing Docker, `kubeadm`, `kubelet`, and `kubectl`, and handling the master initialization and worker node joins.

3.  **Application (Python & Docker):** We developed a simple two-tier application consisting of a Python Flask backend API and a frontend web app, and containerized both using Docker.

4.  **CI/CD (Jenkins):** We created a `Jenkinsfile` to define an automated pipeline that checks out code from GitHub, builds Docker images, runs API tests with Postman/Newman, and pushes the images to Docker Hub.

5.  **Deployment (Kubernetes):** We wrote Kubernetes manifest files (`Deployment`, `Service`, `Ingress`) to deploy our application. The Jenkins pipeline uses these manifests to deploy the application to the cluster, with Nginx Ingress managing traffic routing.

6.  **Monitoring (Prometheus & Grafana):** We used Helm to deploy Prometheus for metrics collection and Grafana for creating dashboards to monitor cluster health, pod status, and ingress metrics.

## Challenges & Lessons Learned

This project was not without its challenges. The following section documents the key problems we faced and how we solved them, as these are often the most valuable learning experiences.

### 1. Environment Incompatibility: Git Bash vs. WSL

*   **Problem:** We initially encountered an `OSError: [WinError 1] Incorrect function` when trying to run Ansible from the Git Bash terminal on Windows.
*   **Analysis:** This is a known compatibility issue where tools like Ansible, which are built for Linux environments, do not function correctly in the POSIX-emulated environment provided by Git Bash.
*   **Solution:** The correct and professional solution was to use the **Windows Subsystem for Linux (WSL)**. By installing Ubuntu via WSL, we created a native Linux environment on Windows where Ansible and other tools could run without compatibility issues.

### 2. The SSH Key Synchronization Saga

This was the most persistent challenge of the project.

*   **Problem:** We repeatedly received `Permission denied (publickey)` errors when trying to connect to our EC2 instances via SSH, both directly and through Ansible.
*   **Analysis:** This error definitively means that the private key on the local machine does not match the public key on the server. We discovered several contributing factors:
    1.  **Incorrect User:** Ansible was defaulting to the WSL username (`ashish`) instead of the required AWS username (`ubuntu`). This was solved by using the `-u ubuntu` flag.
    2.  **Mismatched Keys:** The public key in `terraform.tfvars` did not match the private key being used by the SSH client. This was due to a series of manual errors during key generation and copy-pasting.
    3.  **"Stuck" Server State:** The most difficult issue was that even after we programmatically guaranteed the keys were correct and ran `terraform apply`, the connection was still denied. This proved that the running EC2 instances were not correctly updating with the new key information provided by Terraform.
*   **Solution:** After exhausting all other options, the final, definitive solution was to **recreate the servers themselves**. We used `terraform taint` on the `aws_instance` resources, which forced Terraform to destroy the "stuck" servers and launch fresh ones. The new servers were provisioned with the correct public key from the start, which finally resolved the connection issue.

### 3. Configuration Management Quirks

*   **Problem:** When running Ansible from WSL on a Windows directory (`/mnt/c/...`), Ansible ignored our `ansible.cfg` file due to what it saw as insecure "world-writable" directory permissions.
*   **Analysis:** This meant our configuration settings, like `remote_user = ubuntu` and `inventory = inventory`, were not being used.
*   **Solution:** We bypassed this by providing the configuration directly on the command line using flags: `ansible-playbook -i inventory -u ubuntu playbook.yml`.

## Key Takeaways & Best Practices

*   **Use the Right Environment:** For Linux-native tools like Ansible, Docker, and Terraform, using WSL on Windows is the most robust and error-free approach.
*   **SSH is Foundational:** A deep understanding of how SSH keys work is not optional. Always verify your public key is on the server and your private key is secure on your client. Use `ssh -v` for verbose debugging.
*   **Trust, but Verify:** Don't assume a command worked just because it didn't throw an error. We saw `terraform apply` complete with "0 changes" when a change was actually needed. Always check the plan and output to ensure the expected action is being taken.
*   **`terraform taint` is a Powerful Tool:** When a resource gets into a "stuck" or inconsistent state, `terraform taint` is the correct way to force its recreation on the next apply.
*   **Isolate to Diagnose:** When facing a complex error (like Ansible failing to connect), remove the layers of abstraction. We eventually solved the SSH issue by ignoring Ansible and testing the connection directly with `ssh`.

This project serves as a testament to the power of modern DevOps tools and the importance of methodical, persistent troubleshooting.
