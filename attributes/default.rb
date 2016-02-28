normal['java']['install_flavor']='openjdk' # openjdk, ibm, windows), default openjdk on Linux/Unix platforms, windows on Windows platforms.
normal['java']['jdk_version']='8' # JDK version to install, defaults to '6'.
normal['java']['java_home']='/usr/bin/java'  # Default location of the "$JAVA_HOME".
normal['java']['set_etc_environment']=false  # Optionally sets JAVA_HOME in /etc/environment for Default false.
# normal['java']['openjdk_packages']=['java-1.8.0-openjdk-devel'] # Array of OpenJDK package names to install in the java::openjdk recipe. This is set based on the platform.
# normal['java']['tarball'] = '/var/jtreg-4.1-b12-496.tar.gz' # Name of the tarball to retrieve from your internal repository, default jdk1.6.0_29_i386.tar.gz
# normal['java']['tarball_checksum'] = 'ffb0db78f71869aa9ac87452211c8dacd2f8ce764fc3206f53190cee1539f9b3' #Checksum for the tarball, if you use a different tarball, you also need to create a new sha256 checksum
# normal['java']['jdk'] - Version and architecture specific attributes for setting the URL on Oracle's site for the JDK, and the checksum of the .tar.gz.
# normal['java']['oracle']['accept_oracle_download_terms'] - Indicates that you accept Oracle's EULA
# normal['java']['windows']['url'] - The internal location of your java install for windows
# normal['java']['windows']['package_name'] - The package name used by windows_package to check in the registry to determine if the install has already been run
# normal['java']['windows']['checksum'] - The checksum for the package to download on Windows machines (default is nil, which does not perform checksum validation)
# normal['java']['ibm']['url'] - The URL which to download the IBM JDK/SDK. See the ibm recipe section below.
# normal['java']['ibm']['accept_ibm_download_terms'] - Indicates that you accept IBM's EULA (for java::ibm)
# normal['java']['oracle_rpm']['type'] - Type of java RPM (jre or jdk), default jdk
# normal['java']['oracle_rpm']['package_version'] - optional, can be set to pin a version different from the up-to-date one available in the YUM repo, it might be needed to also override the normal['java']['java_home'] attribute to a value consistent with the defined version
# normal['java']['oracle_rpm']['package_name'] - optional, can be set to define a package name different from the RPM published by Oracle.
normal['java']['accept_license_agreement']=true # Indicates that you accept the EULA for openjdk package installation.
normal['java']['set_default']=true # Indicates whether or not you want the JDK installed to be default on the system. Defaults to true.
# normal['java']['oracle']['jce']['enabled'] - Indicates if the JCE Unlimited Strength Jurisdiction Policy Files should be installed for oracle JDKs
# normal['java']['oracle']['jce']['home'] - Where the JCE policy files should be installed to
# normal['java']['oracle']['jce'][java_version]['checksum'] - Checksum of the JCE policy zip. Can be sha256 or md5
# normal['java']['oracle']['jce'][java_version]['url'] - URL which to download the JCE policy zip

### PostgreSQL ###
### see the postgresql cookbooks attributes/default.rb for defaults ###
normal['postgresql']['version'] ='9.4' # version of postgresql to manage
normal['postgresql']['dir'] = '/var/lib/pgsql/9.4/data' # home directory of where postgresql data and configuration lives.
normal['postgresql']['client']['packages'] = ['postgresql94'] # An array of package names that should be installed on "client" systems.
normal['postgresql']['server']['packages'] = ['postgresql94-server'] # An array of package names that should be installed on "server" systems.
# normal['postgresql']['server']['config_change_notify'] - Type of notification triggered when a config file changes.
# normal['postgresql']['contrib']['packages'] ['postgresql94-contrib'] # An array of package names that could be installed on "server" systems for useful sysadmin tools.
# normal['postgresql']['enable_pgdg_apt'] - Whether to enable the apt repo by the PostgreSQL Global Development Group, which contains newer versions of PostgreSQL.
normal['postgresql']['enable_pgdg_yum'] =true # Whether to enable the yum repo by the PostgreSQL Global Development Group, which contains newer versions of PostgreSQL.
# normal['postgresql']['initdb_locale'] - Sets the default locale for the database cluster. If this attribute is not specified, the locale is inherited from the environment that initdb runs in. Sometimes you must have a system locale that is not what you want for your database cluster, and this attribute addresses that scenario. Valid only for EL-family distros (RedHat/Centos/etc.).

## overrides to fix the forked postgresql cookbook for version 9.4 on centos##
normal['postgresql']['setup_script'] = "/usr/pgsql-#{node['postgresql']['version']}/bin/postgresql#{node['postgresql']['version'].tr('.','')}-setup"
normal['postgresql']['server']['service_name'] = "postgresql-9.4"
normal['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '192.168.0.1/24', :method => 'md5'}
]
normal['postgresql']['config']['listen_addresses'] = '*'

## PASSWORD ##
# echo -n 'YOUR_PASSWORD''postgres' | openssl md5 | sed -e 's/.* /md5/'
# Remember to put your hash in the Vagrantfile too
normal['postgresql']['password']['postgres'] = '232a17a9e1f6cfe8add398bc356a61e7'

# normal['postgresql']['config']['logging_collector'] = true
# normal['postgresql']['config']['datestyle'] = 'iso, mdy'
# normal['postgresql']['config']['ident_file'] = nil
# normal['postgresql']['config']['port'] = 5432
# normal['postgresql']['config']['listen_addresses'] = 'localhost'

# Sudoers
default['authorization']['sudo']['users'] = ['deployer_usr'] # users to enable sudo access (default: [])
default['authorization']['sudo']['passwordless'] = true # use passwordless sudo (default: false)
default['authorization']['sudo']['include_sudoers_d'] = true
