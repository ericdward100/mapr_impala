#
# Cookbook Name:: mapr_impala
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
log "\n=========== Start mapr_impala default.rb =============\n"

bash 'wait_for_metastore' do
  code <<-EOH
    while (( `maprcli node list -columns hostname,svc|grep hivemeta|grep -v grep|wc -l` !=  1 ))
    do
        sleep 20
    done
  EOH
end

#Install Impala Server service from attributes
node["mapr"]["impala_server"].each do |server|
  if node['fqdn'] == "#{server}"
    print "\nWill install impala_server on node: #{node['fqdn']}\n"
    include_recipe "mapr_impala::impala_server"
  end
end


#Install Impala Catalog service from attributes
  if node['fqdn'] == "#{node[:mapr][:impala_catalog]}"
    print "\nWill install Impala Catalog on node: #{node['fqdn']}\n"
    include_recipe "mapr_impala::impala_catalog"
  end

#Install Impala Statestore service from attributes
  if node['fqdn'] == "#{node[:mapr][:impala_state]}"
    print "\nWill install Impala Statestore on node: #{node['fqdn']}\n"
    include_recipe "mapr_impala::impala_state"
  end


ruby_block "Set Impala parametersE in /opt/mapr/impala/impa../conf/env.sh" do
  block do
        file  = Chef::Util::FileEdit.new("/opt/mapr/impala/impala-1.4.1/conf/env.sh")
	file.search_file_replace_line("IMPALA_STATE_STORE_HOST=","IMPALA_STATE_STORE_HOST=#{node[:mapr][:impala_state]}")
       	file.search_file_replace_line("CATALOG_SERVICE_HOST=","CATALOG_SERVICE_HOST=#{node[:mapr][:impala_catalog]}")
 
	file.write_file
  end
end

#Run configure.sh to get services to start, etc
bash 'run configure.sh -R' do
  code <<-EOH
    /opt/mapr/server/configure.sh -R
  EOH
end
