default['jira']['install_path'] = '/opt/atlassian/jira/'
default['jira']['tomcat']['port'] = 8080

default['jira']['apache2']['access_log']         = ''
default['jira']['apache2']['error_log']          = ''
default['jira']['apache2']['port']               = 80
default['jira']['apache2']['virtual_host_alias'] = ''
default['jira']['apache2']['virtual_host_name']  = ''

default['jira']['apache2']['ssl']['access_log']       = ''
default['jira']['apache2']['ssl']['chain_file']       = ''
default['jira']['apache2']['ssl']['error_log']        = ''
default['jira']['apache2']['ssl']['port']             = 443

case node['platform_family']
when 'rhel'
  default['jira']['apache2']['ssl']['certificate_file'] = '/etc/pki/tls/certs/localhost.crt'
  default['jira']['apache2']['ssl']['key_file']         = '/etc/pki/tls/private/localhost.key'
else
  default['jira']['apache2']['ssl']['certificate_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  default['jira']['apache2']['ssl']['key_file']         = '/etc/ssl/private/ssl-cert-snakeoil.key'
end
