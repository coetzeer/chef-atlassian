default['bpl']['devtool']['name'] = 'stash'
default['bpl']['devtool']['user'] = 'stash'
default['bpl']['devtool']['install_home'] = '/var/stash'
default['bpl']['devtool']['uid'] = 7003
default['bpl']['devtool']['url'] = 'http://hdqwks016.polarlake.com:7001/atlassian/atlassian-stash-2.11.2.tar.gz'

default['bpl']['devtool']['install_dir'] = "/opt/atlassian/#{node['bpl']['devtool']['name']}/"
default['bpl']['devtool']['service_name'] = node['bpl']['devtool']['name']
default['devtool']['tomcat']['port'] = 7990

default['bpl']['devtool']['java_url'] = 'http://jenkins.polarlake.com/userContent/vagrant/jdk-7u51-linux-x64.tar.gz'
default['bpl']['devtool']['java_version'] = '7u51'
default['bpl']['devtool']['java_link_dir'] = 'java'
default['bpl']['devtool']['java_install_dir'] = '/opt/java7'

default['bpl']['devtool']['mysql_url'] = 'http://hdqwks016.polarlake.com:7001/atlassian/mysql-connector-java-5.1.29.tar.gz'
default['bpl']['devtool']['mysql_version'] = '5.1.29'
default['bpl']['devtool']['mysql_install_dir'] = '/opt/mysql-connector'


default['bpl']['devtool']['mysql_server']='192.168.56.20'
default['bpl']['devtool']['mysql_root_user']='root'
default['bpl']['devtool']['mysql_root_password']='foobar'
default['bpl']['devtool']['mysql_dbname']=node['bpl']['devtool']['name']
default['bpl']['devtool']['mysql_user']=node['bpl']['devtool']['name']
default['bpl']['devtool']['mysql_password']=node['bpl']['devtool']['name']

default['bpl']['devtool']['nfs_server']='192.168.56.20'
default['bpl']['devtool']['nfs_export_url']="#{node['bpl']['devtool']['nfs_server']}:/exports"

default['devtool']['apache2']['access_log']         = ''
default['devtool']['apache2']['error_log']          = ''
default['devtool']['apache2']['port']               = 80
default['devtool']['apache2']['virtual_host_alias'] = ''
default['devtool']['apache2']['virtual_host_name']  = ''

default['devtool']['apache2']['ssl']['access_log']       = ''
default['devtool']['apache2']['ssl']['chain_file']       = ''
default['devtool']['apache2']['ssl']['error_log']        = ''
default['devtool']['apache2']['ssl']['port']             = 443

case node['platform_family']
when 'rhel'
  default['devtool']['apache2']['ssl']['certificate_file'] = '/etc/pki/tls/certs/localhost.crt'
  default['devtool']['apache2']['ssl']['key_file']         = '/etc/pki/tls/private/localhost.key'
else
  default['devtool']['apache2']['ssl']['certificate_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  default['devtool']['apache2']['ssl']['key_file']         = '/etc/ssl/private/ssl-cert-snakeoil.key'
end
