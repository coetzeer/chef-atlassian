include_recipe "mysql::client"
include_recipe "database::mysql"
include_recipe 'cron'

package "rsync"

# TODO:
# set up job to refresh stale nfs mounts
# http://joelinoff.com/blog/?p=356
#
# automate crowd integration
# https://confluence.atlassian.com/display/CROWD/Integrating+Crowd+with+Atlassian+JIRA#IntegratingCrowdwithAtlassianJIRA-1.1PrepareCrowd'sDirectories/Groups/UsersforJIRA

group "jira" do
  action :create
  append true
end

user "jira" do
  supports :manage_home => false
  comment "Managed service log monitor user"
  uid 7002
  gid "jira"
end

directory "/export" do
  owner "root"
  group "root"
  mode 00777
  recursive true
  action :create
end

directory "/opt/atlassian/" do
  owner "jira"
  group "jira"
  mode 00750
  recursive true
  action :create
end

directory "/var/jira/" do
  owner "jira"
  group "jira"
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

directory "/export/jira/data" do
  owner "jira"
  group "jira"
  mode 00750
  recursive true
  action :create
end

execute "link data directory" do
  user "root"
  cwd "/opt/atlassian"
  command <<-COMMAND
    ln -s /export/jira/data /var/jira/data
    chown jira /var/jira/data
  COMMAND
  creates "/var/jira/data"
end

cron "backup_home" do
  action :create
  minute "*/5"  
  user "jira"
  command "rsync -r --exclude 'data' /var/jira/* /export/jira"
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
  owner "jira"
  version "5.1.29"
end

template "/opt/atlassian/response.varfile" do
    source "jira_response_file.erb"
    mode 00700
    owner "jira"
    group "jira"
end

execute "downloading jira" do
  user "jira"
  cwd "/opt/atlassian"
  command <<-COMMAND
    export no_proxy=".polarlake.com"
	wget -q http://hdqwks016.polarlake.com:7001/atlassian/atlassian-jira-6.2-x64.bin
    chmod 755 atlassian-jira-6.2-x64.bin    
    ./atlassian-jira-6.2-x64.bin -q -varfile response.varfile
  COMMAND
  creates "/opt/atlassian/jira"
end

execute "copying mysql jars" do
  user "jira"
  command <<-COMMAND
    cp /opt/mysql-connector/mysql-connector-java-5.1.29-bin.jar /opt/atlassian/jira/lib/mysql-connector-java-5.1.29.jar
  COMMAND
  creates "/opt/atlassian/jira/lib/mysql-connector-java-5.1.29.jar"
end

execute "copying mysql jars" do
  user "jira"
  command <<-COMMAND
    cp /opt/mysql-connector/mysql-connector-java-5.1.29-bin.jar /opt/atlassian/jira/atlassian-jira/WEB-INF/lib/mysql-connector-java-5.1.29.jar
  COMMAND
  creates "/opt/atlassian/jira/atlassian-jira/WEB-INF/lib/mysql-connector-java-5.1.29.jar"
end

# https://confluence.atlassian.com/display/JIRA/Configuring+JIRA%27s+SMTP+Mail+Server+to+Send+Notifications
execute "copying mail jar" do
  user "jira"
  command <<-COMMAND
    mv /opt/atlassian/jira/atlassian-jira/WEB-INF/lib/mail-1.4.5.jar /opt/atlassian/jira/lib/
  COMMAND
  creates "/opt/atlassian/jira/lib/mail-1.4.5.jar"
end

execute "copying activation jar" do
  user "jira"
  command <<-COMMAND
    mv /opt/atlassian/jira/atlassian-jira/WEB-INF/lib/activation-1.1.1.jar /opt/atlassian/jira/lib/
  COMMAND
  creates "/opt/atlassian/jira/lib/activation-1.1.1.jar"
end

mysql_connection_info = {
  :host     => '192.168.56.20',
  :username => 'root',
  :password => 'foobar'
}

mysql_database 'jira' do
  connection mysql_connection_info
  action :create
  encoding 'utf8'
  collation 'utf8_bin'
end

mysql_database_user 'jira' do
  connection mysql_connection_info
  password   'jira'
  action     :grant
  database_name 'jira'
  privileges    [:all]
  host          '%'
end

template "/etc/init.d/jira" do
    source "jira_init.erb"
    mode 00700
    owner "root"
    group "root"
end

service "jira" do
  supports :start => true, :status => true, :restart => true
  action :enable  
end

include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_ssl'

web_app "jira" do
  template "jira_apache2.erb"
end

template "/opt/atlassian/jira/conf/server.xml" do
    source "server_xml.erb"
    mode 00700
    owner "jira"
    group "jira"
end

service "jira" do
  supports :start => true, :status => true, :restart => true
  action :restart  
end
