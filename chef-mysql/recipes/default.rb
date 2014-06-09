include_recipe 'mysql::server'
include_recipe 'nfs::server'
include_recipe 'cron'

template "/root/seed.sql" do
    source "data.erb"
    mode 00700
end

template "/root/data.sql" do
    source "data2.erb"
    mode 00700
end

# execute "setting up scripts" do
  # cwd "/root"
  # command <<-COMMAND	
	# mysql -u root -pfoobar -e "create database demo"
    # mysql -u root -pfoobar -e "GRANT ALL ON demo.* TO demo@localhost IDENTIFIED BY 'demo'"
    # mysql -u root -pfoobar -e "UPDATE mysql.user SET host = '%' WHERE host = '127.0.0.1' AND user = 'root'"
    # mysql -u demo -pdemo demo < seed.sql

# cat > data1.sh <<- EOF
# !/bin/sh
# mysql -u demo -pdemo demo < /root/data.sql
# mysql -u demo -pdemo demo -e "select count (*) from myTable"
# EOF
  # COMMAND
# end

template "/etc/mysql/conf.d/crowd.cnf" do
    source "mysqld_conf.erb"
    mode 00711
    owner "root"
    group "root"
end

service "mysqld" do
  action :restart  
end

directory "/exports" do
  owner "root"
  group "root"
  mode 00777
  recursive true
  action :create
end

user "crowd" do
  supports :manage_home => false
  comment "crowd"
  uid 7001
end

directory "/exports/crowd" do
  owner "crowd"
  group "crowd"
  mode 00750
  recursive true
  action :create
end

user "jira" do
  supports :manage_home => false
  comment "jira"
  uid 7002
end

directory "/exports/jira" do
  owner "jira"
  group "jira"
  mode 00750
  recursive true
  action :create
end

user "stash" do
  supports :manage_home => false
  comment "stash"
  uid 7003
end

directory "/exports/stash" do
  owner "stash"
  group "stash"
  mode 00750
  recursive true
  action :create
end

user "confluence" do
  supports :manage_home => false
  comment "confluence"
  uid 7004
end

directory "/exports/confluence" do
  owner "confluence"
  group "confluence"
  mode 00750
  recursive true
  action :create
end

user "fisheye" do
  supports :manage_home => false
  comment "fisheye"
  uid 7005
end

directory "/exports/fisheye" do
  owner "fisheye"
  group "fisheye"
  mode 00777
  recursive true
  action :create
end

user "bamboo" do
  supports :manage_home => false
  comment "bamboo"
  uid 7006
end

directory "/exports/bamboo" do
  owner "bamboo"
  group "bamboo"
  mode 00750
  recursive true
  action :create
end

nfs_export "/exports" do
  network '192.168.56.*'
  writeable true
  sync true
  options ['no_root_squash']
end