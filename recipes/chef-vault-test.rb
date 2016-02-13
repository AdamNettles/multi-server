# fetch data bag
chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'

#item = Chef::DataBagItem.load("multi_server", "tomcat")

if ChefVault::Item.vault?("multi_server", "tomcat")
  item = ChefVault::Item.load("multi_server", "tomcat")
else
  item = Chef::DataBagItem.load("multi_server", "tomcat")
end
puts item["username"]
puts item["password"]