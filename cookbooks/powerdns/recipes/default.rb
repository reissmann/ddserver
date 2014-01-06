#
# Author:: Ronny Trommer (ronny@opennms.org)
# Cookbook Name:: PowerDNS
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
