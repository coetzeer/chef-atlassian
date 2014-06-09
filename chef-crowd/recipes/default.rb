include_recipe "mysql::client"
include_recipe "database::mysql"
include_recipe 'cron'

group "crowd" do
  action :create
  append true
end

user "crowd" do
  supports :manage_home => false
  comment "Managed service log monitor user"
  uid 7001
  gid "crowd"
end

directory "/export" do
  owner "root"
  group "root"
  mode 00777
  recursive true
  action :create
end

directory "/opt/atlassian/" do
  owner "crowd"
  group "crowd"
  mode 00750
  recursive true
  action :create
end

mount "/export" do
  device "192.168.56.20:/exports"
  fstype "nfs"
  options "rw"
  action [:mount, :enable]
end

directory "/var/crowd/" do
  owner "crowd"
  group "crowd"
  mode 00750
  recursive true
  action :create
end

cron "backup_home" do
  action :create
  minute "*/5"  
  user "crowd"
  command "rsync -v -r /var/crowd/ /export/crowd"
end

ark 'java7' do
  name "java"
  url 'http://jenkins.polarlake.com/userContent/vagrant/jdk-7u51-linux-x64.tar.gz'
  append_env_path true
  prefix_root "/opt"
  home_dir "/opt/java7"
  owner "root"
  version "7u51"
end

ark 'mysql-connector' do
  name "mysql-connector"
  url 'http://hdqwks016.polarlake.com:7001/atlassian/mysql-connector-java-5.1.29.tar.gz'
  append_env_path false
  prefix_root "/opt"
  home_dir "/opt/mysql-connector"
  owner "crowd"
  version "5.1.29"
end

execute "setting up crowd" do
  user "crowd"
  cwd "/opt/atlassian"
  command <<-COMMAND
    rm -fr crowd
    rm -fr atlassian-crowd*
    export no_proxy=".polarlake.com"
	wget http://hdqwks016.polarlake.com:7001/atlassian/atlassian-crowd-2.7.1.tar.gz
    tar -xvf atlassian-crowd-2.7.1.tar.gz
    ln -s atlassian-crowd-2.7.1 crowd    
  COMMAND
end

template "/opt/atlassian/crowd/crowd-webapp/WEB-INF/classes/crowd-init.properties" do
    source "crowd.erb"
    mode 00700
    owner "crowd"
    group "crowd"
end

link "/opt/atlassian/crowd/apache-tomcat/lib/mysql-connector.jar" do
  to "/opt/mysql-connector/mysql-connector-java-5.1.29-bin.jar"
  owner "crowd"
  group "crowd"
end

file "/opt/atlassian/crowd/apache-tomcat/conf/Catalina/localhost/demo.xml" do
  action :delete
end

directory "/opt/atlassian/atlassian-crowd-2.7.1/apache-tomcat/webapps/ROOT" do
  recursive true
  action :delete
end

mysql_connection_info = {
  :host     => '192.168.56.20',
  :username => 'root',
  :password => 'foobar'
}

mysql_database 'crowd' do
  connection mysql_connection_info
  action :create
  encoding 'utf8'
  collation 'utf8_bin'
end

mysql_database_user 'crowd' do
  connection mysql_connection_info
  password   'crowd'
  action     :grant
  database_name 'crowd'
  privileges    [:all]
  host          '%'
end

template "/etc/init.d/crowd" do
    source "service_initd.erb"
    mode 00700
    owner "root"
    group "root"
end

template "/opt/atlassian/crowd/apache-tomcat/conf/Catalina/localhost/crowd.xml" do
    source "crowd_context.erb"
    mode 00700
    owner "crowd"
    group "crowd"
end

service "crowd" do
  supports :start => true, :status => true, :restart => true
  action [:enable,:start]  
end

include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_ssl'

web_app "crowd" do
  template "crowd_apache2.erb"
end

service "crowd" do
  supports :start => true, :status => true, :restart => true
  action :stop
end

service "crowd" do
  supports :start => true, :status => true, :restart => true
  action :start  
end

