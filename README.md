vagrant-ddserver
================

Vagrant environment for the ddserver project.

ddserver is a server-side application for dynamic DNS management.

It allows you to specify hostnames (subdomains) inside a dynamic DNS zone, and to update the IP address of those hostnames using a dynamic update protocol (no-ip protocol). This enables you to access hosts with dynamic IP addresses by a static domain name, even if the IP address changes. As updates of the IP address are performed using the no-ip update protocol, most DSL home-routers are able to send updates of the IP address. Also, there is a tool called ddclient, which can be used to send updates from any *NIX-based OS.

ddserver is written in Python and comes in three parts:

* ddserver-bundle is the bundled version of
  * ddserver-interface: A nice-looking webinterface for adding hostnames, administrating dynamic zones and managing users
  * ddserver-updater: The implementation of the no-ip update protocol
* ddserver-recursor is the application that answers DNS queries. It runs as a pipe-backend for the PowerDNS server.

All the web-stuff is using the Bottle web-framework using clean HTML5 and the Bootstrap CSS framework.

The project page: https://ddserver.0x80.io/


Requirements:
-------------
- VirtualBox > 4.2 [1]
- Vagrant > 1.4 [2]
- Git [3]
- *nix based operating system

By default the virtual machine uses a no-worry private NAT network interface. To give you access to the virtual machine services there are some preconfigured port forwardings.

 - TCP guest 8080 to your host 8080
 - UDP guest 53 to your host 5353

Usage:
------
1. Install VirtualBox and Vagrant on your computer
2. Checkout this repository with
   git clone https://github.com/ddserver/ddserver.git
   
3. Change into vagrant-ddserver
4. Run vagrant up to start the virtual machine
5. Connect in your browser to http://localhost:8080

Under the hood
--------------
The Vagrantfile allows you to control the behavior of your virtual machine. On your first run Vagrant will download a Vagrant basebox based on a minimal Centos 6.5 with pre-installed Python 2.7. from the following URL

  "http://mirror.informatik.hs-fulda.de/pub/vagrant/CentOS-6-x86_64-python27.box"

Based on this machine a setup of ddserver and PowerDNS will be executed through Chef recipes. In detail:

recipe:ddserver
  - Install MySQL database and development environment to compile and setup ddserver
  - Remove the default installed iptables from CentOS
  - Clone the ddserver latest master source from github
  - Compile and install ddserver
  - Create an initial ddserver.conf which fits the MySQL setup
  - Install init scripts and add ddserver to runlevels to start ddserver on server boot
  - Install MySQL database schema and set initial passwords
  - Start ddserver on port 8080
 
recipe:powerdns
  - Install CentOS EPEL repository and REMI Repository
  - Install powerdns with powerdns backend pipe
  - Add powerdns init script to runlevels to start powerdns on server boot
  - Create a initial powerdns configuration
  - Start powerdns service

Customization through Vagrantfile
---------------------------------
If you want to run your Vagrant with a different branch or a fork of ddserver you can configure git repository URL through the Vagrantfile by changing the giturl and branch parameter

  chef.json = {
    :ddserver => {
      :giturl => "https://github.com/ddserver/ddserver.git"
    },
    :ddserver => {
      :branch => "master"
    }
  }

gl & hf

[1] http://www.virtualbox.org/
[2] http://www.vagrantup.com/
[3] http://www.git-scm.com/
