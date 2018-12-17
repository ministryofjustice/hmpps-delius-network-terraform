# load data from Terraform output
json_file="terraform.json"
content = inspec.profile.file(json_file)
params = JSON.parse(content)

# vpc
vpc_id = params['vpc_id']['value']
cidr_block = params['vpc_cidr_block']['value']

# subnets
public_subnet_az1 = params['vpc_public-subnet-az1']['value']
public_subnet_az2 = params['vpc_public-subnet-az2']['value']
public_subnet_az3 = params['vpc_public-subnet-az3']['value']
private_subnet_az1 = params['vpc_private-subnet-az1']['value']
private_subnet_az2 = params['vpc_private-subnet-az2']['value']
private_subnet_az3 = params['vpc_private-subnet-az3']['value']
db_subnet_az1 = params['vpc_db-subnet-az1']['value']
db_subnet_az2 = params['vpc_db-subnet-az2']['value']
db_subnet_az3 = params['vpc_db-subnet-az3']['value']
public_az1 = params['vpc_public-subnet-az1-availability_zone']['value']
public_az2 = params['vpc_public-subnet-az2-availability_zone']['value']
public_az3 = params['vpc_public-subnet-az3-availability_zone']['value']
private_az1 = params['vpc_private-subnet-az1-availability_zone']['value']
private_az2 = params['vpc_private-subnet-az2-availability_zone']['value']
private_az3 = params['vpc_private-subnet-az3-availability_zone']['value']
db_az1 = params['vpc_db-subnet-az1-availability_zone']['value']
db_az2 = params['vpc_db-subnet-az2-availability_zone']['value']
db_az3 = params['vpc_db-subnet-az3-availability_zone']['value']
public_min_available_ips = 10
private_min_available_ips = 10
db_min_available_ips = 4

# Look at the vpc
describe aws_vpc(vpc_id) do
  its('state') { should eq 'available' }
  its('cidr_block') { should eq cidr_block }
end

# Look for all subnets within a vpc.
describe aws_subnets.where( vpc_id: vpc_id) do
  its('subnet_ids') { should include public_subnet_az1 }
  its('subnet_ids') { should include public_subnet_az2 }
  its('subnet_ids') { should include public_subnet_az3 }
  its('subnet_ids') { should include private_subnet_az1 }
  its('subnet_ids') { should include private_subnet_az2 }
  its('subnet_ids') { should include private_subnet_az3 }
  its('subnet_ids') { should include db_subnet_az1 }
  its('subnet_ids') { should include db_subnet_az2 }
  its('subnet_ids') { should include db_subnet_az3 }
end

# availability_zone
# public
describe aws_subnet(subnet_id: public_subnet_az1) do
  its('availability_zone') { should eq public_az1 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= public_min_available_ips }
  it { should be_available }
end

describe aws_subnet(subnet_id: public_subnet_az2) do
  its('availability_zone') { should eq public_az2 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= public_min_available_ips }
  it { should be_available }
end

describe aws_subnet(subnet_id: public_subnet_az3) do
  its('availability_zone') { should eq public_az3 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= public_min_available_ips }
  it { should be_available }
end

# private
describe aws_subnet(subnet_id: private_subnet_az1) do
  its('availability_zone') { should eq private_az1 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= private_min_available_ips }
  it { should be_available }
end

describe aws_subnet(subnet_id: private_subnet_az2) do
  its('availability_zone') { should eq private_az2 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= private_min_available_ips }
  it { should be_available }
end

describe aws_subnet(subnet_id: private_subnet_az3) do
  its('availability_zone') { should eq private_az3 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= private_min_available_ips }
  it { should be_available }
end

# db
describe aws_subnet(subnet_id: db_subnet_az1) do
  its('availability_zone') { should eq db_az1 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= db_min_available_ips }
  it { should be_available }
end

describe aws_subnet(subnet_id: db_subnet_az2) do
  its('availability_zone') { should eq db_az2 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= db_min_available_ips }
  it { should be_available }
end

describe aws_subnet(subnet_id: db_subnet_az3) do
  its('availability_zone') { should eq db_az3 }
  it { should_not be_mapping_public_ip_on_launch }
  its('available_ip_address_count') { should >= db_min_available_ips }
  it { should be_available }
end

#  VPC Subnet should not be pending
describe aws_subnets.where( vpc_id: vpc_id) do
  its('states') { should_not include 'pending' }
end

#tags
control 'check_environment_tags' do
  title 'Check environment tags'
  desc '
  All tags should have a value and exist
  '
  describe params['tags']['value'] do
    its(['application']) { should_not eq nil }
    its(['business-unit']) { should_not eq nil }
    its(['environment']) { should_not eq nil }
    its(['environment-name']) { should_not eq nil }
    its(['infrastructure-support']) { should_not eq nil }
    its(['is-production']) { should_not eq nil }
    its(['owner']) { should_not eq nil }
    its(['provisioned-with']) { should_not eq nil }
    its(['region']) { should_not eq nil }
  end
end

control 'check_vpc_role_arn' do
  title 'Check VPC Role ARN'
  desc '
  VPC should have a Role ARN and exist
  '
  describe params['vpc_role_arn'] do
    its(['value']) { should_not eq nil }
  end
end
