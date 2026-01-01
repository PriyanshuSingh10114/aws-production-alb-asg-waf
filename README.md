<p align="center">
  <img src="Architecture.png" alt="AWS ALB ASG WAF Architecture" width="800"/>
</p>

<h1>AWS Application Load Balancer + Auto Scaling Group + WAF Setup</h1>

This repository documents the step-by-step process to deploy a scalable and secure web application architecture on AWS using an Application Load Balancer, Auto Scaling Group, and AWS WAF.

The setup ensures:

High availability

Automatic scaling based on load

Protection against DDoS and malicious traffic

<h2>Architecture Overview</h2> <pre> Internet | AWS WAF | Application Load Balancer | Target Group | Auto Scaling Group | EC2 Instances (NGINX serving index.html) </pre>
<h2>Prerequisites</h2> <ul> <li>AWS account</li> <li>VPC with at least two public subnets</li> <li>Security Group allowing HTTP (80) and HTTPS (443)</li> <li>IAM permissions for EC2, ALB, Auto Scaling, and WAF</li> </ul>
<h1>Step 1: Create Target Group</h1>

The target group defines where the Application Load Balancer forwards traffic.

<h3>Steps</h3> <ol> <li>Navigate to EC2 → Target Groups</li> <li>Click Create target group</li> <li>Select Target type: Instances</li> <li>Protocol: HTTP</li> <li>Port: 80</li> <li>Select the same VPC as EC2</li> <li>Health check path: <code>/</code></li> <li>Create the target group</li> </ol>

Do not manually register instances. The Auto Scaling Group will handle this automatically.

<h1>Step 2: Create Application Load Balancer</h1> <h3>Steps</h3> <ol> <li>Navigate to EC2 → Load Balancers</li> <li>Click Create Load Balancer</li> <li>Select Application Load Balancer</li> <li>Scheme: Internet-facing</li> <li>Select at least two public subnets</li> <li>Attach a security group allowing ports 80 and 443</li> <li>Create a listener on port 80 and forward traffic to the target group</li> <li>Create the load balancer</li> </ol>
<h1>Step 3: Create EC2 Launch Template</h1>

The launch template defines how EC2 instances are created inside the Auto Scaling Group.

<h3>Steps</h3> <ol> <li>Navigate to EC2 → Launch Templates</li> <li>Click Create launch template</li> <li>Select Ubuntu 22.04 as the AMI</li> <li>Instance type: t2.micro</li> <li>Select a security group allowing HTTP</li> <li>Add the following user data script:</li> </ol> 
<pre> 
  
    #!/bin/bash 
    sudo apt-get update -y 
    sudo apt-get install -y nginx 
    sudo systemctl start nginx 
    sudo systemctl enable nginx
  
</pre>
<h1>Step 4: Create Auto Scaling Group</h1> <h3>Steps</h3> <ol> <li>Navigate to Auto Scaling Groups</li> <li>Click Create Auto Scaling Group</li> <li>Select the previously created launch template</li> <li>Select the same VPC and subnets as the load balancer</li> <li>Attach the Auto Scaling Group to the existing target group</li> <li>Set capacity: <ul> <li>Desired: 1</li> <li>Minimum: 1</li> <li>Maximum: 3</li> </ul> </li> <li>Add a scaling policy based on average CPU utilization (20 percent)</li> <li>Create the Auto Scaling Group</li> </ol>
<h1>Step 5: Verify Load Balancer and Auto Scaling</h1> <ul> <li>Open the Application Load Balancer DNS name in a browser</li> <li>Confirm the application loads successfully</li> <li>Check the target group health status is healthy</li> <li>Apply load to verify scale-out behavior</li> </ul>
<h1>Step 6: Add AWS WAF for Security</h1>

AWS WAF protects the application from common web exploits and DDoS attacks.
WAF is always attached to the Application Load Balancer, not directly to the Auto Scaling Group.

<h2>Create Web ACL</h2> <ol> <li>Navigate to WAF & Shield → Web ACLs</li> <li>Click Create Web ACL</li> <li>Scope: Regional</li> <li>Select the same region as the load balancer</li> <li>App focus: Web</li> <li>App category: Other or General web application</li> </ol>
<h2>Add Managed Rule Groups</h2>

Enable the following managed rules in COUNT mode initially:

<ul> <li>AWSManagedRulesCommonRuleSet</li> <li>AWSManagedRulesKnownBadInputsRuleSet</li> <li>AWSManagedRulesSQLiRuleSet</li> <li>AWSManagedRulesAmazonIpReputationList</li> </ul>
<h2>Attach Web ACL to Load Balancer</h2> <ol> <li>Open the Web ACL</li> <li>Navigate to Associated AWS resources</li> <li>Select Application Load Balancer</li> <li>Choose the existing load balancer</li> <li>Save changes</li> </ol>

<h1>Conclusion</h1>

This setup provides a scalable, highly available, and secure AWS web architecture suitable for production workloads.
The design follows AWS best practices and supports future enhancements such as HTTPS, CloudWatch monitoring, and infrastructure as code.
