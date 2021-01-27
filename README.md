# Icinga Tasks
Simple puppet/bolt tasks to integrate Icinga 2 into Puppet.

## Usage
### Installation
Install this module alongside icinga/icinga2

## r10k or Code Manager
```
mod 'icinga-icinga2', '3.0.0'
mod 'icinga_tasks', :git => https://github.com/joernott/puppet-icinga-tasks.git, :tag => 'v0.1.0'
```

## Manual installation
```shell
puppet module install icinga-icinga2 --version 3.0.0
git clone https://github.com/joernott/puppet-icinga-tasks.git
```
## Setup
Provide a value for icinga_tasks::api_password in your hiera eyaml for the puppet master 
Include the class icinga_tasks on your puppet master to create a password file and the "puppet" api user

## Usage
### Schedule downtime
Run the task "icinga_schedule_downtime" on the icinga master to schedule a downtime for a defined filter.
The parameters you can provide match the ones accepted by the [Icinga2 scheule-downtime API](https://icinga.com/docs/icinga-2/latest/doc/12-icinga2-api/#schedule-downtime). 

#### Puppet Enterprise
```shell
puppet task run icinga_tasks::icinga_schedule_downtime \
   type='Host' \
   filter='match("www.*", host.name)' \
   author='Jörn Ott' \
   comment='Example' \
   start='5 minutes' \
   end='1 hour' \
   all_services=true \
   --nodes icinga2.example.com
```
#### Bolt
```shell
bolt task run icinga_tasks::icinga_schedule_downtime \
   type='Host' \
   filter='match("www.*", host.name)' \
   author='Jörn Ott' \
   comment='Example' \
   start='5 minutes' \
   end='1 hour' \
   all_services=true \
   --targets icinga2.example.com
```

### Remove downtime
Run the task "icinga_remove_downtime" on the icinga master to schedule a downtime for a defined filter.
The parameters you can provide match the ones provided by the [Icinga2 remove-downtime API](https://icinga.com/docs/icinga-2/latest/doc/12-icinga2-api/#remove-downtime).

#### Puppet Enterprise
```shell
puppet task run icinga_tasks::icinga_remove_downtime \
   type='Downtime' \
   filter='downtime.author == "Jörn Ott"' \
   author='Jörn Ott' \
   --nodes icinga2.example.com
```

#### Bolt
```shell
bolt task run icinga_tasks::icinga_remove_downtime \
   type='Downtime' \
   filter='downtime.author == "Jörn Ott"' \
   author='Jörn Ott' \
   --targets icinga2.example.com
```

### Reset logfile alert
We use ConsolLoabs check_logfile Script to monitor application logs.
We place the config files for the various checks into /etc/icinga2/logfiles.d/ and give them
names that match the check name with a suffix ".conf". As we have activated the sticky option
on many of those checks, one needs to "unstick" them. This task can be used for unsticking them.

You can optionally provide a user to run unstick as. If none is provided, the task will use the
default icinga user.

To unstick one or many logfiles, you need to provide the name of the config (shell patterns as accepted by
find can be used). If not, the task just lists the available configs for which the reset can be performed.

#### Puppet Enterprise

```shell
puppet task run icinga_tasks::reset_logfile_alert \
   config='*' \
   --nodes www.example.com
```

#### Bolt

```shell
bolt task run icinga_tasks::reset_logfile_alert \
   config='*' \
   --targets www.example.com
```
