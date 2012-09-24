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

resque_redis_settings = {
  'user' => node[:cloudfoundry_common][:user],
  'configdir' => '/etc/redis',
  'address' => node[:ipaddress] ,
  'backuptype' => 'rdb', 
  'save' => ['900 1','300 10','60 10000'], 
  'datadir' => node['cloudfoundry_cloud_controller']['resque_redis']['datadir'],
  'timeout' => '600', 
  'loglevel' => 'notice', 
  'logfile' => '/var/log/redis', 
  'requirepass' => node[:cloudfoundry_cloud_controller][:resque_redis[:password]
}

server = [{ 
   'address' => node[:ipaddress],
   'port' => '6379' 
}]

version = node['cloudfoundry_cloud_controller']['resque_redis']['version']

redisio_install "redis-servers" do 
  version version
  download_url 'http://redis.googlecode.com/files/redis-#{version}.tar.gz' 
  default_settings resque_redis_settings
  servers server
  safe_install false 
  base_piddir '/var/run'
end


