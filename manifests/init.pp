# @summary Set up prerequisites for the tasks
#
# The tasks have a few requirements (apiuser, a file with the password for the api user etc). This class does the setup for this
#
# @example simple usage with password provided by hiera
#   include icinga_tasks
#
# @example defining all parameters
#    class{'icinga_tasks':
#      api_user     => 'bolt',
#      api_password => 'Sup3rS3cr3tPassw0rd!',
#      target       => '/etc/icinga2/zones.d/master/api-users.conf'
#
# @param api_user String
#    Name of the API user, defaults to 'puppet'.
#
# @param api_password String
#    Password for the API user
#
# @param target_file Stdlib::Absolutepath
#     Path to the api user-users.conf file
#
class icinga_tasks(
  String               $api_password,
  String               $api_user      = 'puppet',
  Stdlib::Absolutepath $target_file   =  '/etc/icinga2/conf.d/api-users.conf',
) {

  icinga2::object::apiuser { $api_user:
    ensure      => 'present',
    password    => $api_password,
    permissions => [ 'status/query', 'actions/*', 'objects/modify/*', 'objects/query/*' ],
    target      => $target_file,
  }

  file { '/etc/icinga2/puppet.password':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $api_password,
  }
}
