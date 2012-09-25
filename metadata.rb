maintainer       "Trotter Cashion"
maintainer_email "cashion@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures cloudfoundry-cloud_controller"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ ubuntu }.each do |os|
  supports os
end

%w{ 
postgresql 
mysql 
database 
redisio
cloudfoundry-common 
cloudfoundry-ruby-runtime
cloudfoundry-node-runtime
cloudfoundry-java-runtime
openssl
}.each do |cb|
  depends cb
end
