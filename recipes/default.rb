#
# Cookbook Name:: cloudfoundry-cloud_controller
# Recipe:: default
#
# Copyright 2012, Trotter Cashion
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
#
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# randomly generate stager password
node.set_unless[:cloudfoundry_cloud_controller][:server][:staging_password] = secure_password
node.set_unless[:cloudfoundry_cloud_controller][:resque_redis][:password] = secure_password
node.save unless Chef::Config[:solo]

include_recipe "cloudfoundry-cloud_controller::database"
include_recipe "cloudfoundry-cloud_controller::resque_redis"
include_recipe "cloudfoundry-cloud_controller::server"
