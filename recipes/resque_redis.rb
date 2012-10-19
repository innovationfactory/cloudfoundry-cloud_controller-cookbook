#
# Cookbook Name:: cloudfoundry-cloud_controller
# Recipe:: Resque Redis
#
# Copyright 2012, Innovation Factory
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

version = node['cloudfoundry_cloud_controller']['resque_redis']['version']

redisio_install 'redis-servers' do 
  version version
  download_url "http://redis.googlecode.com/files/redis-#{version}.tar.gz"
  default_settings {}
  servers []
  safe_install false 
  base_piddir '/var/run'
end

config_dir = node['cloudfoundry_cloud_controller']['resque_redis']['config_dir']

data_dir = node['cloudfoundry_cloud_controller']['resque_redis']['data_dir']

[config_dir, data_dir].each do |dir|
  directory dir do
    owner node['cloudfoundry_common']['user']
    mode '0775'
    recursive true
    action :create
  end
end

config_file = File.join(config_dir, 'resque_redis.conf')

template config_file do
  source 'redis.conf.erb'
  owner node['cloudfoundry_common']['user']
  mode '0644'
  variables({
    :pid_file     => node['cloudfoundry_cloud_controller']['resque_redis']['pid_file'],
    :port         => node['cloudfoundry_cloud_controller']['resque_redis']['port'],
    :address      => node['ipaddress'],
    :requirepass  => node['cloudfoundry_cloud_controller']['resque_redis']['password'],
    :data_dir      => node['cloudfoundry_cloud_controller']['resque_redis']['data_dir'],
  })
  notifies :restart, 'service[resque-redis]'
end

template '/etc/init/resque-redis.conf' do
  source 'redis.init.conf.erb'
  owner node['cloudfoundry_common']['user']
  mode '0644'
  variables({
    :config_file => config_file
  })
  notifies :restart, 'service[resque-redis]'
end

service 'resque-redis' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end
