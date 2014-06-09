default['bpl']['devtool']['name'] = 'crowd'


default['crowd']['install_path'] = '/opt/atlassian/crowd/'
default['crowd']['tomcat']['port'] = 8095

default['crowd']['apache2']['access_log']         = ''
default['crowd']['apache2']['error_log']          = ''
default['crowd']['apache2']['port']               = 80
default['crowd']['apache2']['virtual_host_alias'] = ''
default['crowd']['apache2']['virtual_host_name']  = ''

default['crowd']['apache2']['ssl']['access_log']       = ''
default['crowd']['apache2']['ssl']['chain_file']       = ''
default['crowd']['apache2']['ssl']['error_log']        = ''
default['crowd']['apache2']['ssl']['port']             = 443

case node['platform_family']
when 'rhel'
  default['crowd']['apache2']['ssl']['certificate_file'] = '/etc/pki/tls/certs/localhost.crt'
  default['crowd']['apache2']['ssl']['key_file']         = '/etc/pki/tls/private/localhost.key'
else
  default['crowd']['apache2']['ssl']['certificate_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  default['crowd']['apache2']['ssl']['key_file']         = '/etc/ssl/private/ssl-cert-snakeoil.key'
end
