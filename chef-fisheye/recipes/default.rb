include_recipe "mysql::client"
include_recipe "database::mysql"
include_recipe 'cron'

group node['bpl']['devtool']['user'] do
  action :create
  append true
end

user node['bpl']['devtool']['user'] do
  supports :manage_home => false
  comment "User for #{node['bpl']['devtool']['user']}"
  uid node['bpl']['devtool']['uid']
  gid node['bpl']['devtool']['user']
end

directory "/export" do
  owner "root"
  group "root"
  mode 00777
  recursive true
  action :create
end

directory "/opt/atlassian/" do
  owner node['bpl']['devtool']['user']
  group node['bpl']['devtool']['user']
  mode 00750
  recursive true
  action :create
end

mount "/export" do
  device node['bpl']['devtool']['nfs_export_url']
  fstype "nfs"
  options "rw"
  action [:mount, :enable]
end

directory node['bpl']['devtool']['install_home'] do
  owner node['bpl']['devtool']['user']
  group node['bpl']['devtool']['user']
  mode 00750
  recursive true
  action :create
end

cron "backup_home" do
  action :create
  minute "*/5"  
  user node['bpl']['devtool']['user']
  command "rsync -v -r #{node['bpl']['devtool']['install_home']} /export/#{node['bpl']['devtool']['name']}"
end

ark 'java7' do
  name node['bpl']['devtool']['java_link_dir']
  url node['bpl']['devtool']['java_url']
  append_env_path true
  prefix_root "/opt"
  home_dir node['bpl']['devtool']['java_install_dir']
  owner "root"
  version node['bpl']['devtool']['java_version']
end

ark 'mysql-connector' do
  name "mysql-connector"
  url node['bpl']['devtool']['mysql_url']
  append_env_path false
  prefix_root "/opt"
  home_dir node['bpl']['devtool']['mysql_install_dir']
  owner node['bpl']['devtool']['user']
  version  node['bpl']['devtool']['mysql_version']
end

execute "setting up #{node['bpl']['devtool']['name']}" do
  user node['bpl']['devtool']['user']
  cwd "/opt/atlassian"
  command <<-COMMAND
    rm -fr #{node['bpl']['devtool']['name']}
    rm -fr crucible*
    rm -fr fecru*
    export no_proxy=".polarlake.com"
	wget #{node['bpl']['devtool']['url']}
    unzip crucible-3.3.1.zip
    ln -s fecru-3.3.1 #{node['bpl']['devtool']['name']}
  COMMAND
end

link "#{node['bpl']['devtool']['install_dir']}/lib/mysql-connector.jar" do
  to "/opt/mysql-connector/mysql-connector-java-5.1.29-bin.jar"
  owner node['bpl']['devtool']['user']
  group node['bpl']['devtool']['user']
end

mysql_connection_info = {
  :host     => node['bpl']['devtool']['mysql_server'],
  :username => node['bpl']['devtool']['mysql_root_user'],
  :password => node['bpl']['devtool']['mysql_root_password']
}

mysql_database node['bpl']['devtool']['mysql_dbname'] do
  connection mysql_connection_info
  action :create
  encoding 'utf8'
  collation 'utf8_bin'
end

mysql_database_user node['bpl']['devtool']['mysql_user'] do
  connection mysql_connection_info
  password   node['bpl']['devtool']['mysql_password']
  action     :grant
  database_name node['bpl']['devtool']['mysql_dbname']
  privileges    [:all]
  host          '%'
end

template "/etc/environment" do
    source "environment.erb"
    mode 00755
    owner "root"
    group "root"
end

template "/etc/profile.d/#{node['bpl']['devtool']['name']}.sh" do
    source "fisheye_sh.erb"
    mode 00755
    owner "root"
    group "root"
end

template "#{node['bpl']['devtool']['install_home']}/config.xml" do
    source "config_xml.erb"
    mode 00755
    owner node['bpl']['devtool']['user']
    group node['bpl']['devtool']['user']
end

template "#{node['bpl']['devtool']['install_dir']}/config.xml" do
    source "config_xml.erb"
    mode 00755
    owner node['bpl']['devtool']['user']
    group node['bpl']['devtool']['user']
end

template "/etc/init.d/#{node['bpl']['devtool']['service_name']}" do
    source "service_initd.erb"
    mode 00700
    owner "root"
    group "root"
end

service node['bpl']['devtool']['service_name'] do
  supports :start => true, :status => true, :restart => true
  action [:enable,:start]  
end

include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_ssl'

web_app node['bpl']['devtool']['name'] do
  template "apache2.erb"
end

service node['bpl']['devtool']['service_name'] do
  supports :start => true, :status => true, :restart => true
  action :stop
end

service node['bpl']['devtool']['service_name'] do
  supports :start => true, :status => true, :restart => true
  action :start  
end

