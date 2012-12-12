#
# Author:: Chirag Jog (<chiragj@websym.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'fog'
require 'highline'
require 'chef/knife'
require 'chef/json_compat'

class Chef
  class Knife
    class BluelockServerDelete < Knife

      banner "knife bluelock server delete SERVER (options)"


      # Extracted from Chef::Knife.delete_object, because it has a
      # confirmation step built in... By specifying the '--purge'
      # flag (and also explicitly confirming the server destruction!)
      # the user is already making their intent known.  It is not
      # necessary to make them confirm two more times.
      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name}")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end

      def h
        @highline ||= HighLine.new
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      option :purge,
        :short => "-P",
        :long => "--purge",
        :boolean => true,
        :default => false,
        :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the Bluelock node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node and client to delete, if it differs from the server name. Only has meaning when used with the '--purge' option."

      option :bluelock_password,
        :short => "-K PASSWORD",
        :long => "--bluelock-password PASSWORD",
        :description => "Your bluelock password",
        :proc => Proc.new { |key| Chef::Config[:knife][:bluelock_password] = key }

      option :bluelock_username,
        :short => "-A USERNAME",
        :long => "--bluelock-username USERNAME",
        :description => "Your bluelock username",
        :proc => Proc.new { |username| Chef::Config[:knife][:bluelock_username] = username }

      def run
        $stdout.sync = true

        unless Chef::Config[:knife][:bluelock_username] && Chef::Config[:knife][:bluelock_password]
	        ui.error("Missing Credentials")
	        exit 1
        end

        bluelock = Fog::Vcloud::Compute.new(
          :vcloud_username => Chef::Config[:knife][:bluelock_username],
          :vcloud_password => Chef::Config[:knife][:bluelock_password],
          :vcloud_host => 'zone01.bluelock.com',
          :vcloud_version => '1.5'
        )
        vapps = bluelock.vapps.all
        vapp = nil
        @name_args.each do |vapp_id|
          vapp = vapps.find {|v| v.name == vapp_id }
          if vapp.nil?
            ui.warn("Cannot find vapp #{vapp_id}")
            next
          end
          confirm("Do you really want to delete this server #{vapp.name} ")
          server = bluelock.get_server(vapp.href)
          server.destroy
          ui.warn("Deleted server #{vapp.name}")
          if config[:purge]
            thing_to_delete = config[:chef_node_name] || vapp_id
            destroy_item(Chef::Node, thing_to_delete, "node")
            destroy_item(Chef::ApiClient, thing_to_delete, "client")
          else
            ui.warn("Corresponding node and client for the #{instance_id} server were not deleted and remain registered with the Chef Server")
          end
        end
      end
    end
  end
end
