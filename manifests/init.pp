#
#
#
class profile_minio (
  String                     $checksum,
  String                     $version,
  Hash                       $config,
  Hash                       $config_default,
  Stdlib::Absolutepath       $data_path,
  Stdlib::Absolutepath       $data_device,
  Boolean                    $manage_firewall_entry,
  Stdlib::Host               $listen_address,
  Stdlib::Port::Unprivileged $port,
  String                     $sd_service_name,
  Array                      $sd_service_tags,
  Boolean                    $minio_backup,
  Boolean                    $manage_sd_service            = lookup('manage_sd_service', Boolean, first, true),
) {
  $_config = deep_merge($config_default, $config)

  profile_base::mount{ $data_path:
    device => $data_device,
    mkdir  => false,
  }
  -> class { 'minio':
    configuration          => $_config,
    checksum               => $checksum,
    checksum_type          => 'sha256',
    version                => $version,
    installation_directory => '/usr/local/bin/minio',
    listen_ip              => $listen_address,
    listen_port            => $port,
    storage_root           => $data_path,
  }

  if $manage_firewall_entry {
    firewall { "0${port} accept minio":
      dport  => $port,
      proto  => 'tcp',
      action => 'accept',
    }
  }

  if $manage_sd_service {
    consul::service { $sd_service_name:
      checks => [
        {
          http     => "http://${listen_address}:${port}/minio/health/live",
          interval => '10s'
        }
      ],
      port   => $port,
      tags   => $sd_service_tags,
    }
  }

  if $minio_backup {
    include profile_minio::backup
  }
}
