include_recipe "mysql::client"
include_recipe "database::mysql"
include_recipe 'cron'

package "rsync"

group "confluence" do
  action :create
  append true
end

user "confluence" do
  supports :manage_home => false
  comment "Confluence user"
  uid 7004
  gid "confluence"
end

directory "/export" do
  owner "root"
  group "root"
  mode 00777
  recursive true
  action :create
end

directory "/opt/atlassian/" do
  owner "confluence"
  group "confluence"
  mode 00750
  recursive true
  action :create
end

directory "/var/confluence/" do
  owner "confluence"
  group "confluence"
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

directory "/export/confluence/attachments" do
  owner "confluence"
  group "confluence"
  mode 00750
  recursive true
  action :create
end

execute "link data directory" do
  user "root"
  cwd "/opt/atlassian"
  command <<-COMMAND
    ln -s /export/confluence/attachments /var/confluence/attachments
    chown confluence /var/confluence/attachments
  COMMAND
  creates "/var/confluence/attachments"
end

cron "backup_home" do
  action :create
  minute "*/5"  
  user "confluence"
  command "rsync -r --exclude 'attachments' /var/confluence/* /export/confluence"
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
  owner "confluence"
  version "5.1.29"
end

template "/opt/atlassian/response.varfile" do
    source "conf_response_file.erb"
    mode 00700
    owner "confluence"
    group "confluence"
end

execute "downloading confluence" do
  user "confluence"
  cwd "/opt/atlassian"
  command <<-COMMAND
    export no_proxy=".polarlake.com"
	wget -q http://hdqwks016.polarlake.com:7001/atlassian/atlassian-confluence-5.4.3-x64.bin
    chmod 755 atlassian-confluence-5.4.3-x64.bin    
    ./atlassian-confluence-5.4.3-x64.bin -q -varfile response.varfile
  COMMAND
  creates "/opt/atlassian/confluence"
end


execute "copying mysql jars" do
  user "confluence"
  command <<-COMMAND
    cp /opt/mysql-connector/mysql-connector-java-5.1.29-bin.jar /opt/atlassian/confluence/lib/mysql-connector-java-5.1.29.jar
  COMMAND
  creates "/opt/atlassian/confluence/lib/mysql-connector-java-5.1.29.jar"
end

execute "copying mysql jars" do
  user "confluence"
  command <<-COMMAND
    cp /opt/mysql-connector/mysql-connector-java-5.1.29-bin.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.29.jar
  COMMAND
  creates "/opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.29.jar"
end

# https://confluence.atlassian.com/display/JIRA/Configuring+JIRA%27s+SMTP+Mail+Server+to+Send+Notifications
execute "copying mail jar" do
  user "confluence"
  command <<-COMMAND
    mv /opt/atlassian/confluence/confluence/WEB-INF/lib/mail-1.4.5.jar /opt/atlassian/confluence/lib/
  COMMAND
  creates "/opt/atlassian/confluence/lib/mail-1.4.5.jar"
end

mysql_connection_info = {
  :host     => '192.168.56.20',
  :username => 'root',
  :password => 'foobar'
}

mysql_database 'confluence' do
  connection mysql_connection_info
  action :create
  encoding 'utf8'
  collation 'utf8_bin'
end

mysql_database_user 'confluence' do
  connection mysql_connection_info
  password   'confluence'
  action     :grant
  database_name 'confluence'
  privileges    [:all]
  host          '%'
end

template "/etc/init.d/confluence" do
    source "conf_init.erb"
    mode 00700
    owner "root"
    group "root"
end

service "confluence" do
  supports :start => true, :status => true, :restart => true
  action :enable  
end

include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_ssl'

web_app "confluence" do
  template "conf_apache2.erb"
end

template "/opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml" do
    source "seraph-config_xml.erb"
    mode 00700
    owner "confluence"
    group "confluence"
end

template "/opt/atlassian/confluence/confluence/WEB-INF/classes/crowd.properties" do
    source "crowd_properties.erb"
    mode 00700
    owner "confluence"
    group "confluence"
end

template "/opt/atlassian/confluence/conf/server.xml" do
    source "server_xml.erb"
    mode 00700
    owner "confluence"
    group "confluence"
end

service "confluence" do
  supports :start => true, :status => true, :restart => true
  action :restart  
end
