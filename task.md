task:1->q3
    Every app needs a secure home. In AWS, the VPC (Virtual Private Cloud) is the property line for our PhotoSharing app. Inside, we create two distinct zones:

Public Subnet: The "Front Door." This is where the Load Balancer and Web Server live. Placing the Web Server here allows us to easily connect (SSH) to it for configuration.

Private Subnet: The "Vault." This is where we hide the Database to keep our data strictly isolated from the internet.

By separating these zones, we ensure that while users can access the app interface, no one can directly touch our sensitive data storage.

Tasks:

Step 1: Build the VPC

Go to the VPC Dashboard and create a new VPC.

Name tag: photoshare-vpc
IPv4 CIDR block: 10.0.0.0/16
Step 2: Create the Subnets (The 2-AZ Setup)
Inside your new VPC, create 4 subnets:

A. Main Public Subnet (For Web Server & ALB)

Name tag: Public Subnet 1
Availability Zone: us-east-1a
IPv4 CIDR block: 10.0.1.0/24
B. Main Private Subnet (For Database)

Name tag: Private Subnet 1
Availability Zone: us-east-1a
IPv4 CIDR block: 10.0.2.0/24
C. Placeholder Public Subnet (Required for ALB creation)

Name tag: Public Subnet 2
Availability Zone: us-east-1b
IPv4 CIDR block: 10.0.3.0/24
D. Placeholder Private Subnet (Required for DB Group)

Name tag: Private Subnet 2
Availability Zone: us-east-1b
IPv4 CIDR block: 10.0.4.0/24
Step 3: Add the Internet Gateway

Create an Internet Gateway. photoshare-igw
Select it and choose Attach to VPC.
Select photoshare-vpc.
Step 4: Configure Routing

We need to create a specific "Public Route Table" so only our Web Server and Load Balancer get internet access, while the Database stays hidden.

Create a Public Route Table:

Go to Route Tables -> Create route table.
Name: public-rt
VPC: photoshare-vpc
Click Create route table.
Add Internet Access:

Select your new public-rt from the list.
Click the Routes tab -> Edit routes.
Add route:
Destination: 0.0.0.0/0
Target: Internet Gateway (Select the one you just created).
Click Save changes.
Associate Public Subnets Only:

Click the Subnet associations tab -> Edit subnet associations.
Select Public Subnet 1 AND Public Subnet 2.
Make sure Private Subnet 1 & 2 are UNCHECKED.
Click Save associations.
Note:

Is VPC photoshare-vpc created?
Are all 4 subnets created correctly in 1a and 1b?
Do both Public Subnets have a route to the Internet Gateway? 

q2
Go to your Public Route Table. Look at the route with Destination 0.0.0.0/0. What is the "Target" listed?

task:2

Our PhotoSharing app has two main workers: the Web Server (EC2) and the Image Processing Function (Lambda).

Instead of hardcoding dangerous API keys, we create specific IAM Roles. These roles act as temporary ID badges, granting only the necessary permissions. Crucially, we must use specific role names starting with iam and containing role to comply with the lab's security policy.

Tasks:

Step 1: Create the EC2 Role

Go to the IAM Dashboard, select Roles, and click Create role.

Trusted entity type: AWS service
Service or use case: EC2
Add permissions: Search for and select these policies:
AmazonS3FullAccess
AWSSecretsManagerClientReadOnlyAccess
Role name: iam_role_ec2
Step 2: Create the Lambda Role

Click Create role again to set up the role for your serverless function.

Trusted entity type: AWS service
Service or use case: Lambda
Add permissions: Search for and select these policies:
AWSLambdaBasicExecutionRole
AmazonS3FullAccess
Role name: iam_role_lambda
Note:

Are IAM Roles iam_role_ec2 and iam_role_lambda created?

Check: Ensure both IAM roles are created with the correct permissions and trusted entities.


task:3->q3
Go to IAM > Roles. Click on your photoshare-ec2-role and look at the Trust relationships tab. What "Service" is listed in the JSON/Table?

task:4
We are storing sensitive database passwords, and we need to make sure they are unreadable to anyone who shouldn't see them. KMS (Key Management Service) acts as our digital vault. AWS provides a managed key specifically for Secrets Manager. Later, we will use this key to “lock” our database credentials so that even if someone accessed the encrypted file, it would appear as scrambled gibberish without the key.

Tasks:

Step 1: Open the KMS Console

Go to the AWS Key Management Service console.

Step 2: Locate the AWS-Managed Key

Find the managed key:

Alias: alias/aws/secretsmanager
Step 3: Record the Key ARN

Select the key and copy its Key ARN.

Step 4: Verify Key Status

On the key details page, confirm:

Key state: Enabled
Note:

Is the AWS managed key alias/aws/secretsmanager identified?
Is the key state Enabled?


task:5
Every photo needs data attached to it, such as who uploaded it, when, and what the title is. We need a reliable database to store this information. We use Amazon RDS to run a managed MySQL database. Crucially, we place this database in the Private Subnet. This means it is completely invisible to the public internet. Only our Web Server (EC2) can talk to it, making it extremely difficult for attackers to try and guess passwords or steal data.

Tasks:

Step 1: Create DB Subnet Group

Go to the RDS Dashboard and create a new DB Subnet Group.

Name: photoshare-db-group
Description: DB Subnet Group for PhotoShare
VPC: Select photoshare-vpc
Availability Zones: us-east-1a, us-east-1b
Subnets: Select the Private Subnets (10.0.2.0/24 and 10.0.4.0/24)
Step 2: Create Security Group for Database

Create a new Security Group for the database.

Name: db-sg
Description: Security group for PhotoShare RDS database
VPC: photoshare-vpc
Configure Inbound Rules:

Type: MySQL/Aurora
Protocol: TCP
Port: 3306
Source: 10.0.0.0/16 (Entire VPC)
Step 3: Create RDS MySQL Instance

Go to RDS Instances and create a new MySQL database instance.

Engine: MySQL
Engine Version: 8.4 (or latest 8.4.x)
Templates: Free Tier
DB Instance Identifier: photoshare-db
Master Username: admin
Master Password: Create a strong password and save it
DB Instance Class: db.t3.micro (Free Tier eligible)
Storage: 20 GB (Free Tier)
Storage Type: gp3
DB Subnet Group: photoshare-db-group
Public Access: No
VPC Security Groups: db-sg
Disable Automated Backup
Multi-AZ: No (for Free Tier)
Advance Configuration: Initial Database Name photoshare
Note:

Is the RDS instance photoshare-db status Available?
Is the database Public Access set to No?



Check: Verify RDS instance configuration, availability, and security settings.

q4-> 
Why should the RDS instance NOT be publicly accessible?


task:6

A classic mistake in app development is saving the database password directly in the source code (e.g., password="admin123"). If that code leaks, the database is compromised.

AWS Secrets Manager fixes this. We store the password in a secure, central vault. When our PhotoSharing app starts up, it asks AWS: "Please give me the password." AWS checks the security badge (IAM Role) and hands it over securely. This keeps our code clean and our secrets safe.

Tasks:

Step 1: Store the Credentials

Go to the Secrets Manager Dashboard and click Store a new secret.

Secret type: Other type of secret
Key/value pairs: Add rows for your DB credentials:
Key: username | Value: admin
Key: password | Value: (Paste your password here)
Key: engine | Value: mysql
Key: host | Value: (Paste your RDS Endpoint here)
Key: port | Value: 3306
Key: dbname | Value: (Paste your Initial database name here)
Encryption key: aws/secretsmanager (Default)
Step 2: Name and Create

Secret name: photoshare/db/credentials
Description: Database credentials for PhotoSharing App
Rotation: Leave disabled (default).
Click Store.
Note:

Is the secret photoshare/db/credentials created?
Is the secret encrypted using the aws/secretsmanager key?



Check: Ensure the secret photoshare/db/credentials is created, encrypted, and contains the required username and password.

q->5
Why use Secrets Manager for DB credentials?

task:8

S3 is where the actual image files will live. However, we don't want just anyone on the internet browsing through our bucket. To protect user privacy, we enforce a "Block All Public Access" policy. Even though the photos are for a web app, users won't download them directly from S3. Instead, they view them through our secure Web App, which checks if they are allowed to see the image first. This gives us total control over our data.

Tasks:

Step 1: Create S3 Bucket

Go to the S3 Console and create a new S3 bucket.

Bucket Name: photoshare-assets-<your-unique-suffix>(Copy this name, you will need it for the Lambda configuration later)
Region: us-east-1
Default Encryption: Enable (AES-256)
Step 2: Enable Block All Public Access

Once the bucket is created, go to the bucket's Permissions tab. Block all public access is enabled by default, but verify that all four options are still enabled:

Block public access to buckets and objects granted through new access control lists (ACLs)
Block public access to buckets and objects granted through any access control lists (ACLs)
Block public access to buckets and objects granted through new public bucket or access point policies
Block public and cross-account access to buckets and objects through any public bucket or access point policies
Step 3: Verify Bucket Privacy

Confirm that the bucket is completely private.

No public ACLs are applied
No public bucket policies are attached
All Block Public Access settings are enabled
Note:

Is an S3 bucket with prefix photoshare-assets- created?
Is "Block all public access" enabled for the bucket?



Check: Verify S3 bucket is created with proper name prefix, Block All Public Access is enabled, and no public ACLs or policies are applied.

q6->
Why must public access be blocked on the S3 bucket?

task:9
We don’t want to expose our Web Server directly to the internet. If it crashes or gets attacked, the whole application could go down. The Application Load Balancer (ALB) acts as our Receptionist.

It lives in the Public Subnet, accepts incoming user traffic, and safely forwards requests to the Web Server running in the backend. This setup provides a secure entry point and protects our infrastructure from direct internet exposure.

Tasks:

Step 1: Create the Application Load Balancer

Go to the EC2 Dashboard, select Load Balancers, and click Create Load Balancer.

Load balancer type: Application Load Balancer
Name: photoshare-alb
Scheme: Internet-facing
IP address type: IPv4
Network mapping:
VPC: photoshare-vpc
Mappings: Select the Public Subnets in both zones:
Check us-east-1a -> Select Public Subnet 1
Check us-east-1b -> Select Public Subnet 2
Step 2: Create the Security Group

Create a new Security Group for the ALB. photoshare-sg

Inbound rules:
HTTP — Port 80 — Source: 0.0.0.0/0
SSH — Port 22 — Source: 0.0.0.0/0
Outbound rules: Allow all traffic
Attach this Security Group to the ALB.

Step 3: Configure the Target Group

Create a Target Group that the ALB will forward traffic to.

Target group name: photoshare-tg
Target type: Instance
Protocol: HTTP
Port: 80
We will register the Web Server EC2 instance to the target group later.

Verification:

Is the ALB scheme set to Internet-facing?
Does the Security Group allow inbound traffic from 0.0.0.0/0?
Action Required: Copy the DNS Name (e.g., photoshare-alb-123.us-east-1.elb.amazonaws.com) from the ALB Description tab. You will need this URL to access your website and to configure the Lambda environment variables later.



Check: Ensure the Application Load Balancer is Internet-facing and deployed in the Public Subnet.

task:10

When a user uploads a new photo, we want to automatically calculate its size and dimensions without slowing down the main website. If the Web Server handled this task, large uploads could affect performance for other users.

We solve this using AWS Lambda. As soon as a photo is uploaded to S3, Lambda wakes up, processes the file in the background, and then shuts down. This keeps the PhotoSharing app fast and responsive.

Tasks:

Step 1: Create the Lambda Function

Go to the Lambda Dashboard and click Create function.

Function name: photoshare-metadata-extractor
Runtime: Python 3.14 (or latest Python version)
Architecture: x86_64
Change default execution role:
Select Use an existing role
Existing role: Select iam_role_lambda (created in the previous IAM section)
Step 2: Network Configuration

Advanced Settings -> Enable VPC: Leave Unchecked (No VPC).
Reason: Our Lambda needs to reach S3 and the ALB (which are on the public internet). Since we do not have a NAT Gateway in our Private Subnet, putting the Lambda inside the VPC would cut off its internet access and cause it to fail.
Step 3: Update Function Code

In your terminal, run the following command to view the source code:

cat lambda_handler.py
Copy the entire output of the command.

In the AWS Console, go to the Code tab and paste the code you just copied.

Click Deploy to save changes.

Step 4: Configure Environment Variables

The code relies on two variables to know where to look for files and where to send data.

Go to Configuration tab > Environment variables.
Click Edit.
Add the following Key-Value pairs:
Key: S3_BUCKET | Value: (Your bucket name, e.g., photoshare-assets-xxxx)
Key: ALB_DNS | Value: (Your ALB DNS, e.g., photoshare-alb-xxx.elb.amazonaws.com)
Click Save.
Step 5: Add S3 Trigger

Configure S3 to wake up this Lambda function when a new photo is uploaded.

Go to the Function overview section and click Add trigger.
Select a source: S3.
Bucket: Select your photoshare-assets-xxxx bucket.
Event types: Select All object create events.
Recursive invocation: Acknowledge the warning.
Click Add.
Verification:

Is the function using the existing iam_role_lambda?
Is the S3 trigger configured for ObjectCreated events?
Is the Lambda function running without VPC attached (allowing S3 access)?



Check: Ensure the Lambda function is running and is triggered when a new object is uploaded to S3.


task:11
This is the heart of the PhotoSharing app. We will launch this instance in the Public Subnet to allow for configuration access, but we will secure it using strict Security Groups and IAM roles.

Tasks:

Step 1: Create Web Server Security Group

Security group name: photoshare-web-sg
Description: Security group for Web Server
VPC: photoshare-vpc
Inbound Rules:
Type: HTTP | Port: 80 | Source: Custom -> Select the ALB Security Group.
Type: SSH | Port: 22 | Source: 0.0.0.0/0 (Allows SSH access for configuration).
Step 2: Update RDS Security Group
Lock down the Database so only this specific EC2 instance can talk to it.

Go to Security Groups -> Select db-sg.
Edit inbound rules -> Delete existing rules.
Add Rule:
Type: MySQL/Aurora | Port: 3306 | Source: Custom -> Select photoshare-web-sg.
Click Save rules.
Step 3: Launch the Instance
Go to the EC2 Dashboard and click Launch Instances.

Name: photoshare-web
AMI: Amazon Linux 2023
Instance Type: t3.micro
Key Pair: Select an existing key pair or create a new one (e.g., photoshare-key).
Note: You need this if you want to use a standard terminal. If you plan to only use EC2 Instance Connect, you can proceed without one, but having one is recommended.
Network Settings:
VPC: photoshare-vpc
Subnet: Select the Public Subnet
Auto-assign Public IP: Enable (Required for internet access and SSH).
Security Group: Select photoshare-web-sg.
Advanced Details:
IAM instance profile: Select iam_role_ec2.
Step 4: Configure the Server

Prepare File Content: Run this in the terminal and copy the output to your clipboard:
cat docker-compose.yml

Connect to EC2

Option A (Browser): Select instance -> Connect -> EC2 Instance Connect.
Option B (SSH): Run ssh -i key.pem ec2-user@<Public-IP>
Install, Create Files & Run (Inside EC2): Run these commands in order:

# 1. Install Docker & Git
sudo dnf install -y docker git
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user

# 2. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. Create the docker-compose.yml file
# Run this, PASTE your clipboard content, then press Ctrl+D.
cat > docker-compose.yml

# 4. Create the .env file
# You MUST replace 'photoshare-assets-xxxx' with your actual bucket name.
cat <<EOF > .env
S3_BUCKET=photoshare-assets-xxxx
AWS_SECRET_NAME=photoshare/db/credentials
EOF

# 5. Run the application
sudo docker-compose up -d

Step 5: Register to Target Group

Go to Target Groups -> Select photoshare-tg.
Click Register targets.
Select the photoshare-web instance.
Click Include as pending below -> Register pending targets.
Verification:

Is the instance running in the Public Subnet using iam_role_ec2?
Does the RDS Security Group (db-sg) allow traffic ONLY from photoshare-web-sg?
Action Required: Test the website via the Load Balancer DNS (e.g., http://photoshare-alb-123...).



Check: Verify EC2 Instance, Security Group source chaining, and Target Group registration.

task: 12

Since our Lambda function runs in the background to process photos, we wouldn't see it failing just by looking at the website. We need a way to monitor the "invisible" parts of our app. CloudWatch is our dashboard. We set up a monitor to track Lambda errors. If the image processing breaks, CloudWatch will alert us immediately, ensuring we can fix the issue before users start complaining that their photo details are missing.

Tasks:

Step 1: Create the Dashboard

Go to the CloudWatch Console and select Dashboards from the left menu.

Click: Create dashboard
Name: PhotoShare-Monitor
Click: Create dashboard
Step 2: Add EC2 CPU Widget

You will be prompted to add a widget immediately after creating the dashboard.

Widget Type: Line
Metrics: EC2 > Per-Instance Metrics > CPUUtilization
Instance: Select your photoshare-web instance
Click: Create widget
Step 3: Add Lambda Invocations Widget

Add another widget to track how often your function runs.

Click: Add widget
Widget Type: Number
Metrics: Lambda > By Function Name > Invocations
Function: Select your photoshare-metadata-extractor
Click: Create widget and Save dashboard.
Step 4: Create Alarm for Lambda Errors

Set up an alert so you know if the code fails.

Go to Alarms -> All alarms -> Create alarm.
Select metric: Lambda > By Function Name > Errors (Select your function).
Conditions:
Threshold type: Static
Whenever Errors is…: Greater than 0
Name: PhotoShare-Lambda-Error-Alarm
Click: Create alarm.
Verification:

Is the PhotoShare-Monitor dashboard showing data for both EC2 and Lambda?
Is the PhotoShare-Lambda-Error-Alarm state currently OK (green)?
Action Required: Verify the alarm exists via CLI: aws cloudwatch describe-alarms --alarm-names PhotoShare-Lambda-Error-Alarm



Check: Verify CloudWatch Dashboard existence, Widget configuration (EC2 & Lambda), and Alarm settings.

task:13

This is the moment of truth. We are going to use the app just like a real user to prove that everything is connected correctly. When you open the App via the Load Balancer and upload a photo, you are testing the entire chain: The network routing, the database login, the S3 storage, and the Lambda trigger. If the image uploads and the dashboard updates, you have successfully built a secure, production-ready cloud architecture!

Tasks:

Step 1: Get Load Balancer DNS

You need the public address of your application.

Navigate to the EC2 Console -> Load Balancers.
Select photoshare-alb.
Locate the DNS name in the Details tab and copy it (e.g., photoshare-alb-12345.us-east-1.elb.amazonaws.com).
Step 2: Access & Upload

Open a new browser tab and paste the DNS Name.
Verify the PhotoShare application loads successfully.
Click the Share Your Photo button and select a sample image from your computer.
Step 3: Verify Backend Processing

Confirm that the invisible parts of the infrastructure worked.

Go to the S3 Console -> Open your bucket (photoshare-assets-...).
Verify the image file appears there.
Go to the CloudWatch Console -> Dashboards -> PhotoShare-Monitor.
Check if the Lambda Invocations widget shows a data point (it might take a minute).
Verification:

Did the web page load using the ALB DNS?
Did the image upload successfully to S3?
Action Required: If you cannot access the browser, verify connectivity via terminal:
curl -I http://<ALB-DNS-NAME>



Check: Verify App Accessibility (ALB status) and Functional Success (S3 Upload & Lambda Execution).


Mission Accomplished!
Congratulations, Cloud Architect!

You have successfully built PhotoShare, a secure, scalable, and modern 3-tier cloud application on AWS.

No more hardcoded database passwords in source code.
No more publicly exposed databases.
No more manual server updates.

You have proven that by combining EC2, Lambda, RDS, and S3, you can create a production-grade architecture that is secure by default and scalable by design.

What You Have Mastered:

VPC Networking: You built a custom network with Public/Private isolation to protect your data.
Infrastructure Security: You implemented "Least Privilege" using IAM Roles and Security Groups.
Serverless Automation: You used Lambda to process files in the background without provisioning servers.
Containerization: You deployed a Dockerized application using Docker Compose on EC2.
Secret Management: You secured sensitive credentials using AWS Secrets Manager and KMS encryption.
Load Balancing: You exposed your app safely to the world using an Application Load Balancer (ALB).
Next Steps:

Auto Scaling: Create an Auto Scaling Group to launch more Web Servers when traffic spikes.
CloudFormation: Automate this entire lab using "Infrastructure as Code" (IaC).
Domain & SSL: Attach a real domain name (Route53) and secure it with HTTPS (ACM).
Thank you for learning with KodeKloud!
