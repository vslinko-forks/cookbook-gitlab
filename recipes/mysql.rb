#
# Cookbook Name:: gitlab
# Recipe:: mysql
#
# Copyright 2012, Seth Vargo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe 'mysql-chef_gem'

# Enable secure password generation
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
node.set_unless['gitlab']['database']['password'] = secure_password
ruby_block 'save node data' do
  block do
    node.save
  end
  not_if { Chef::Config[:solo] }
end

# Helper variables
database = node['gitlab']['database']['database']
database_user = node['gitlab']['database']['username']
database_password = node['gitlab']['database']['password']
database_userhost = node['gitlab']['database']['userhost']
database_host = node['gitlab']['database']['host']
database_connection = {
  host: database_host,
  username: 'root',
  password: node['mysql']['server_root_password']
}

# Create the database
mysql_database database do
  connection      database_connection
  action          :create
end

# Create the database user
mysql_database_user database_user do
  connection      database_connection
  password        database_password
  host            database_userhost
  database_name   database
  action          :create
end

# Grant all privileges to user on database
mysql_database_user database_user do
  connection      database_connection
  database_name   database
  privileges ['SELECT', 'LOCK TABLES', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'INDEX', 'ALTER']
  action          :grant
end
