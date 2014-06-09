default['nfs']['port']['statd'] = "32765"
default['nfs']['port']['statd_out'] = "32766"
default['nfs']['port']['mountd'] = "32767"
default['nfs']['port']['lockd'] = "32768"
default['nfs']['packages'] = %w{ nfs-utils rpcbind }
default['nfs']['service']['portmap'] = "rpcbind"