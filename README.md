### Overview
This repository creates a production-ready [Node.js](https://nodejs.org/en/about/) and [Postgres](https://www.postgresql.org/) application.

In under 15 minutes, you can deploy an AWS stack using:
- [Docker](https://www.docker.com/) to make development and deployment easier.
- [Terraform](https://www.terraform.io/) to automate infrustucture management. 
- [Amazon RDS](https://aws.amazon.com/rds/) to manage a Postgres database.
- [Auto Scaling](https://aws.amazon.com/autoscaling/) to scale your application as your traffic grows.
- [Elastic Container Service](https://aws.amazon.com/ecs/) to deploy a cluster of Docker containers across multiple availability zones.
- [Application Load Balancing](https://aws.amazon.com/elasticloadbalancing/) to evenly distribute traffic between these instances.
- [A Virtual Private Cloud](https://aws.amazon.com/vpc/) to secure the communication between these services 

### Installation Steps

##### Install required dependencies
- Docker
  - On OSX, install [Homebrew](https://brew.sh/) and run `brew install docker`
- Terraform
  - On OSX, run `brew install terraform`
- AWS CLI
  - On OSX, run `brew install awscli`
- Node
  - On OSX, run `brew install node`

##### Create an AWS account
- Go to [AWS](https://aws.amazon.com) and create an account

##### Create an AWS credentials for development
When you log in to AWS with the email / password used to set up the account, you are signed in as a root user. AWS [strongly recommends](https://docs.aws.amazon.com/general/latest/gr/aws_tasks-that-require-root.html) to do normal user and administrative tasks as a non-root user.

```
# [ACTION] indicates that you need to do something, instead of a normal comment :)

# [ACTION] Create temporary root credentials at https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials
aws configure # [ACTION] Enter temporary root credentials 
# [ACTION] Delete root credentials in console
aws iam create-group --group-name Admins
aws iam attach-group-policy --group-name Admins --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-user --user-name mcgradyc
aws iam create-login-profile --user-name mcgradyc
aws iam add-user-to-group --user-name mcgradyc --group-name Admins
# [ACTION] Use account ID to sign in with mcgradyc role (i.e. https://<your_account_id>.signin.aws.amazon.com/console/)
aws configure --profile personal-website-mcgradyc # [ACTION] Enter mcgradyc credentials and us-west-2 as region

# Create a key pair called charliemcgrady-key-pair (to use a custom name,
# update the key_pair_name variable in `./infrustructure/vars.tf`). Make sure 
# to save this key pair somewhere safe - it will be used to SSH into hosts.
aws ec2 create-key-pair --key-name charliemcgrady-key-pair --query 'KeyMaterial' --output text > charliemcgrady-key-pair.pem
chmod 400 charliemcgrady-key-pair.pem
```

##### Deploy the stack with Terraform
There are two sensitive Terraform variables which need to be provided as environment variables - `db_password` and `ip_address_for_ssh`.
```
# Export the password you want for the DB as an env variable,
# so we dont check it into source control
export TF_VAR_db_password=password

# Export your public IP address for ssh access into public hosts
# Value can be found at https://www.whatismyip.com/what-is-my-public-ip-address/
export TF_VAR_ip_address_for_ssh=<ip_addres>/32
```

We are now ready to deploy the stack:
```
cd ./infrustructure
terraform init
terraform apply
```

Follow the steps in the "Deploying Changes To Your Application" section.

Once the cluster has been updated, you can view the application on the Internet by:
- Going to the EC2 dashboard in the AWS console
- Clicking on the "Load Balancers" tab
- Searching for DNS name (e.g. node-server-alb-1234.us-west-2.elb.amazonaws.com)
- Going to `<dns_name>/deepPing` in a browser

##### Updating the schema / data in the database
Knex is used to manage the schema of the Postgres database. To seed the database:
- Find the Public IP of one of your hosts via the EC2 console
- SSH into the host: `ssh -vv -i ~/path/to/charliemcgrady-key-pair.pem ec2-user@<public_ip>`
- Log into the node-server Docker instance: 
```
docker ps
# [ACTION] Note the container ID for the node-server image
docker exec -it <container_id> sh

# Execute all of the migrations in ./app/server/db/migrations
npm run migrate-db

# Execute all of the db seeds in ./app/server/db/seeds
npm run seed-db
```

### Deploying changes
Navigate to the root of the workspace and run `./bin/release.sh`.

You can monitor the release by going to the [ECS Dashboard](https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/clusters/charliemcgrady-production-cluster/services/node-server/events).

### Local development
To run the application, run `./bin/dev/init.sh`. This script uses `docker-compose.yml` to initialize the Node application and a local DB. Once the logs indicate that Node is listening on port 4000, you should see "Healthy" when you navigate to [http://localhost:4000/deepPing](http://localhost:4000/deepPing).


To making changes to the Node application:
```
cd ./app/server
npm run dev
```
This command starts the Typescript compiler. Any changes in `./app/server/src` will be compiled into `./app/server/dist`. This directory is mounted as a volume for the Node Docker container and will be automatically picked up by the server.

Note: if you want make changes to `./app/types`, you also need to run `npm run dev` in `./app/types`.

### Cookbook of useful commands
SSHing into a host
```
# [Action] Find the host's Public IP in the EC2 console
ssh -vv -i ~/path/to/charliemcgrady-key-pair.pem ec2-user@<public_ip>
```