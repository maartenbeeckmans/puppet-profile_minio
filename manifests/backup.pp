#
#
#
class profile_minio::backup (
  Stdlib::AbsolutePath $data_path = $::profile_minio::data_path,
) {
  include profile_rsnapshot::user

  @@rsnapshot::backup{ "backup ${facts['networking']['fqdn']} minio-data":
    source     => "rsnapshot@${facts['networking']['fqdn']}:${data_path}",
    target_dir => "${facts['networking']['fqdn']}/minio-data",
    tag        => lookup('rsnapshot_tag', String, undef, 'rsnapshot'),
  }
}
