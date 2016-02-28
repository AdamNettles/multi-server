#
# Cookbook Name:: multi-server
# Recipe:: default
#
# Copyright (C) 2016 YOUR_NAME
#
# All rights reserved - Do Not Redistribute

# fetch data bag
chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault' # the chef_gem
include_recipe 'chef-vault' #the recipe

if ChefVault::Item.vault?("multi_server", "tomcat")
  tomcat_creds = ChefVault::Item.load("multi_server", "tomcat")
else
  tomcat_creds = Chef::DataBagItem.load("multi_server", "tomcat")
end

if ChefVault::Item.vault?("multi_server", "postgresql")
  postgresql_creds = ChefVault::Item.load("multi_server", "postgresql")
else
  postgresql_creds = Chef::DataBagItem.load("multi_server", "postgresql")
end

# Copy a JDK tarball from cookbook to Node
# TODO:  Create custom cookbook to install java from local file
# cookbook_file '/var/jtreg-4.1-b12-496.tar.gz' do
#   source 'jtreg-4.1-b12-496.tar.gz'
#   owner 'root'
#   mode '0755'
#   action :create
# end

include_recipe 'java'

# locally cached tomcat8 tar @ /Users/adamnettles/chef/resources/apache-tomcat-8.0.30.tar

group 'tomcat' do
	action :create
end

user 'tomcat_usr' do
	group 'tomcat'
	home '/opt/tomcat'
	shell '/bin/false'
end

directory '/opt/tomcat' do
	group 'tomcat'
	owner 'tomcat_usr'
	action :create
end

#Set up the deploy and deployer_usr with public key
user 'deployer_usr' do
	group 'tomcat'
	home '/opt/deployer_usr'
	shell '/bin/bash'
end

ssh_authorize_key 'deployer_public_key' do
  key tomcat_creds['deployerPublicKey']
  user 'deployer_usr'
  group 'tomcat'
  # options inser directly into the pub key on node, not using them
end

# Make deployer_usr a sudoer, see attributes
include_recipe 'sudo'

# If detailed restrictions needed, use this LWRP to setup sudoers instead
# Note, needs modification to work
# sudo 'tomcat' do
#   user      "%deployer_usr"    # or a username
#   runas     'app_user'   # or 'app_user:tomcat'
#   commands  ['/etc/init.d/tomcat restart']
# end

service 'sshd' do
	action :enable
end

service 'sshd' do
	action :restart
end

node.default['tom-version'] = '8.0.32'
# for vagrant box ~ = /home/vagrant
remote_file "/home/vagrant/apache-tomcat-#{node['tom-version']}.tar.gz" do
	# source 'http://supergsego.com/apache/tomcat/tomcat-8/v8.0.30/bin/apache-tomcat-8.0.30.tar.gz'
	#http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32.tar.gz
	source "http://mirror.reverse.net/pub/apache/tomcat/tomcat-8/v#{node['tom-version']}/bin/apache-tomcat-#{node['tom-version']}.tar.gz"
	action :create_if_missing
end

#TODO: move this to attributes

node.default['tom-install-path'] = '/opt/tomcat'

tar_extract "/home/vagrant/apache-tomcat-#{node['tom-version']}.tar.gz" do
  action :extract_local
  target_dir '/opt/tomcat'
  # sudo tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
  tar_flags ['--strip-components=1']
  creates "/opt/tomcat/webapps"
end

directory "#{node['tom-install-path']}/conf" do
	group 'tomcat'
	# owner 'tomcat_usr'
	mode '0200'
end

Dir[ "#{node['tom-install-path']}/conf/*" ].each do |path|
  file path do
    # owner "root"
    mode '0040'
    group 'tomcat'
  end if File.file?(path)
  directory path do
    # owner "root"
    mode '0040'
    group 'tomcat'
  end if File.directory?(path)
end

node.default['tom-owned-dirs'] = ['webapps','work','temp','logs']
node['tom-owned-dirs'].each do |dir|
	directory "#{node['tom-install-path']}/#{dir}" do
		owner 'tomcat_usr'
		group 'tomcat'
		mode '0770'
	end
end

# Grant rwx on this to allow deployer_usr access through tomcat group
directory node['tom-install-path'] do
	mode '0770'
end

template '/etc/systemd/system/tomcat.service' do
	# -Xms512M -Xmx1024M
	source 'tomcat.service.erb'
	owner 'tomcat_usr'
	group 'tomcat'
	variables({
	     :xms => '512M',
	     :xmx => '1024M'
	  })
	action :create
end

template '/opt/tomcat/conf/tomcat-users.xml' do
		source 'tomcat-users.xml.erb'
	owner 'tomcat_usr'
	group 'tomcat'
	variables({
	     :user => tomcat_creds['username'],
	     :password => tomcat_creds['password']
	})
	action :create
end

service 'tomcat' do
	action :enable
end

service 'tomcat' do
	action :start
end

### Create Login user for deployment ###
### Then, install pub under that user ###


puts node['postgresql']['server']['service_name']

### Begin Postgres ###
include_recipe 'postgresql::server'
## Contrib included automatically by attribute flags ##

# Execute the DDL


# Make sure the PGDATA env variable is set
# bash 'setPGDATA' do
#   code "export PGDATA = #{node['postgresql']['dir']}"
#   action :run
# end

# 
#include_recipe 'postgresql::config_initdb'
#include_recipe 'postgresql::config_pgtune'