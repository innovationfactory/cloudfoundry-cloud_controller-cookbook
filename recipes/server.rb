ruby_version = node.cloudfoundry_common.ruby_1_9_2_version
config_file  = File.join(node.cloudfoundry_common.config_dir, "cloud_controller.yml")


# Needed because the CloudController Gemfile depends on mysql
include_recipe "mysql::client"

# CloudController must unzip incoming files
package "unzip"
package "zip"

# For the nokogiri dependency
package "libxml2"
package "libxml2-dev"
package "libxslt1-dev"

# For the sqlite3 dependency
package "sqlite3"
package "libsqlite3-dev"

ruby_path    = File.join(rbenv_root, "versions", node.cloudfoundry_common.ruby_1_9_2_version, "bin")
install_path = File.join(node['cloudfoundry_common']['vcap']['install_path'], "cloud_controller", "cloud_controller")

cloudfoundry_component "cloud_controller" do
  pid_file node.cloudfoundry_cloud_controller.server.pid_file
  log_file node.cloudfoundry_cloud_controller.server.log_file
  binary "#{File.join(ruby_path, 'ruby')} #{File.join(install_path, "bin", "cloud_controller")}"
  install_path install_path
end

template File.join(node['cloudfoundry_common']['config_dir'], 'runtimes.yml') do
  owner    node.cloudfoundry_common.user
  mode     "0644"
  notifies :restart, "service[cloudfoundry-cloud_controller]"
end

bash "run cloudfoundry migrations" do
  user node['cloudfoundry_common']['user']
  cwd  File.join(node['cloudfoundry_common']['vcap']['install_path'], "cloud_controller", "cloud_controller")
  code "#{File.join(ruby_path, "bundle")} exec rake db:migrate RAILS_ENV=production CLOUD_CONTROLLER_CONFIG='#{config_file}'"
  subscribes :run, resources(:git => "#{File.join(node['cloudfoundry_common']['vcap']['install_path'], "cloud_controller")}")
  action :nothing
end
