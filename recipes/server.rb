include_recipe "cloudfoundry-common"

# Needed because the CloudController Gemfile depends on mysql
include_recipe "mysql::client"
include_recipe "cloudfoundry-common::directories"
include_recipe "cloudfoundry-common::vcap"

ruby_path = File.join(rbenv_root, "versions", node.cloudfoundry_common.ruby_1_9_2_version, "bin")
cloud_controller_path = File.join(node[:cloudfoundry_common][:vcap][:install_path], "bin", "cloud_controller")
config_file = File.join(node[:cloudfoundry_common][:config_dir], "cloud_controller.yml")

rbenv_gem "bundler" do
  ruby_version node.cloudfoundry_common.ruby_1_9_2_version
end

# For the nokogiri dependency
package "libxml2"
package "libxml2-dev"
package "libxslt1-dev"

# For the sqlite3 dependency
package "sqlite3"
package "libsqlite3-dev"

bash "install cloudfoundry_gems" do
  user node[:cloudfoundry_common][:user]
  cwd  File.join(node[:cloudfoundry_common][:vcap][:install_path], "cloud_controller")
  code "#{File.join(ruby_path, "bundle")} install --without=test --local"
  subscribes :run, resources(:git => node[:cloudfoundry_common][:vcap][:install_path])
  action :nothing
end

bash "run cloudfoundry migrations" do
  user node[:cloudfoundry_common][:user]
  cwd  File.join(node[:cloudfoundry_common][:vcap][:install_path], "cloud_controller")
  code "PATH='#{ruby_path}:$PATH' #{File.join(ruby_path, "bundle")} exec rake db:migrate RAILS_ENV=production CLOUD_CONTROLLER_CONFIG='#{config_file}'"
  subscribes :run, resources(:git => node[:cloudfoundry_common][:vcap][:install_path])
  action :nothing
end

template config_file do
  source "config.yml.erb"
  owner  node['cloudfoundry_common']['user']
  mode   '0644'
end

template File.join(node[:bluepill][:conf_dir], "cloud_controller.pill") do
  source "cloud_controller.pill.erb"
  variables(
    :binary      => "#{File.join(ruby_path, "ruby")} #{cloud_controller_path}",
    :pid_file    => node[:cloudfoundry_cloud_controller][:server][:pid_file],
    :config_file => config_file
  )
end

bluepill_service "cloud_controller" do
  action [:enable, :load, :start]
end

# Write config files for each framework so that cloud_controller can
# detect what kind of application it's dealing with.
if !node[:cloudfoundry_cloud_controller][:server][:frameworks] ||
    node[:cloudfoundry_cloud_controller][:server][:frameworks].empty?
  Chef::Log.info "No frameworks specified, skipping framework configs."
else
  node[:cloudfoundry_cloud_controller][:server][:frameworks].each do |framework|
    template File.join(node[:cloudfoundry_common][:staging_manifests_dir], "#{framework}.yml") do
      source "#{framework}.yml.erb"
      owner  node[:cloudfoundry_common][:user]
      mode   "0644"
      variables(
        # ruby outputs the version without the '-'
        :ruby_1_9_2_version => node[:cloudfoundry_common][:ruby_1_9_2_version].sub('-', ''),
        :ruby_1_9_2_path => ruby_path(node[:cloudfoundry_common][:ruby_1_9_2_version])
      )
    end
  end
end
