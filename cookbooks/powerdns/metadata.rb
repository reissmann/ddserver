maintainer       "Ronny Trommer"
maintainer_email "ronny@opennms.org"
license          "GPLv3+"
description      "Installs/Configures PowerDNS for ddserver"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"
name             "PowerDNS for ddserver"
provides         "PowerDNS for ddserver"

recipe "ddserver", "Installs PowerDNS and configuration for ddserver"

%w{ centos }.each do |os|
    supports os
end
