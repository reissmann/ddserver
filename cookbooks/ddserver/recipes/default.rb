#
# Author:: Ronny Trommer (ronny@opennms.org)
# Cookbook Name:: ddserver
# Recipe:: default
#
# Copyright 2010-2013, Ronny Trommer
#
# Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.gnu.org/licenses/gpl-3.0.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Platform dependend install from OpenNMS repository
if platform?("redhat", "centos")

    # Install MySQL server and development environment required for
    # compiling from source
    execute "install mysql database server and libraries" do
      command "yum install -y mysql-server mysql-devel python-devel"
      action :run
    end

    # Enable MySQL for systemboot and start
    service "mysqld" do
      supports :status => true, :restart => true, :reload => true
      action [ :enable, :start]
    end

    # Stop firewall, not sure right now which TCP/UDP ports have to be activated
    service "iptables" do
      supports :status => true, :restart => true, :reload => true
      action [ :disable, :stop]
    end

    # Checkout latest code from github
    bash "clone git repository" do
      not_if { ::File.exists?("/usr/local/src/ddserver") }
      cwd "/usr/local/src"
      user "root"
      code <<-EOH
        git clone https://github.com/ddserver/ddserver.git
      EOH
    end

    # Compile and install from source with python
    bash "compile and install ddserver" do
      cwd "/usr/local/src/ddserver"
      user "root"
      code <<-EOH
        python2.7 setup.py install
      EOH
    end

    # Create configuration for ddserver and database connection
    template "/etc/ddserver/ddserver.conf" do
        not_if { ::File.exists?("/etc/ddserver/ddserver.conf") }
        source "ddserver.conf.erb"
        owner "root"
        group "root"
        mode "0644"
    end

    # This should be done by the ddserver installer
    template "/etc/init.d/ddserver" do
        source "ddserver.init.erb"
        owner "root"
        group "root"
        mode "0755"
    end

    bash "init ddserver logfile" do
      cwd "/root"
      user "root"
      code <<-EOH
        touch /var/log/ddserver.log
        chmod 777 /var/log/ddserver.log
      EOH
    end

    # Enable ddserver on system boot and start
    service "ddserver" do
        supports :status => true, :restart => true
        action [ :enable, :start]
    end

    # Initialize MySQL database with database, schema user and authentication
    bash "set mysql root password" do
      not_if("/usr/bin/mysql -u root --password=secret -e 'show databases' | grep ddserver")
      cwd "/root"
      user "root"
      code <<-EOH
        /usr/bin/mysqladmin -u root password 'secret' && \
        /usr/bin/mysql -u root --password=secret -e "create database ddserver;" && \
        /usr/bin/mysql -u root --password=secret ddserver < /usr/share/doc/ddserver/schema.sql && \
        /usr/bin/mysql -u root --password=secret -e "create user 'ddserver'@'localhost' identified by 'secret';" && \
        /usr/bin/mysql -u root --password=secret -e "grant all privileges on ddserver.* TO 'ddserver'@'localhost';" && \
        /usr/bin/mysql -u root --password=secret -e "FLUSH PRIVILEGES;"
      EOH
    end

    # add epal repo (needed to install pdns)
    bash "install epel" do
      cwd "/root"
      user "root"
      code <<-EOH
        rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
        rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
        yum -y update
      EOH
    end

    # Install powerdns server
    execute "install mysql database server and libraries" do
      command "yum install -y pdns pdns-backend-pipe"
      action :run
    end

    # configure PYTHON_EGG_CACHE
    bash "configuring PYTHON_EGG_CACHE" do
      cwd "/root"
      user "root"
      code <<-EOH
        mkdir /tmp/.python_eggs
        chmod 777 /tmp/.python_eggs
        echo export PYTHON_EGG_CACHE=/tmp/.python_eggs >> /etc/environment
      EOH
    end

    # use a pdns init script that knows about PYTHON_EGG_CACHE
    template "/etc/init.d/pdns" do
        source "pdns.init.erb"
        owner "root"
        group "root"
        mode "0755"
    end

    # Set pdns configuration to use pipe backend with ddserver
    template "/etc/pdns/pdns.conf" do
        source "pdns.conf.erb"
        owner "root"
        group "root"
        mode "0600"
    end

    # Enable powerdns on system boot and start
    service "pdns" do
        supports :status => true, :restart => true
        action [ :enable]
    end

    # start pdns server
    bash "starting pdns" do
      cwd "/root"
      user "root"
      code <<-EOH
        /etc/init.d/pdns start
      EOH
    end

 end
