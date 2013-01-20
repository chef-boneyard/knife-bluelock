# -*- coding: utf-8 -*-
# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
require 'knife_cloud_tests'
#require 'knife_cloud_tests/models/knife_parameters'

class BLKnifeCommands
  attr_accessor :cmd_list_image                 	# "knife bluelock image list"           	# Knife command for listing servers
  attr_accessor :cmd_create_server               	# "knife bluelock server create"          # Knife command for creating a server
  attr_accessor :cmd_delete_server               	# "knife bluelock server delete"          # Knife command for deleting a server
  attr_accessor :cmd_list_server                 	# "knife bluelock server list"            # Knife command for listing servers
end

module BLBaseKeys
  attr_accessor :bl_username                      # "-A"                                     # Bluelock username
  attr_accessor :bl_username_l                    # "--bluelock-username"                    # Bluelock username long
  attr_accessor :bl_password                    	# "-K"                                     # Bluelock password
  attr_accessor :bl_password_l                  	# "--bluelock-password"                    # Bluelock password long
end

class BLKnifeImageListParameters < KnifeParams
  include BLBaseKeys
end

class BLKnifeServerCreateParameters < KnifeParams
  include BLBaseKeys
	attr_accessor :node_name												# "--node-name"            											# The Chef node name for your new node
  attr_accessor :enable_firewall 									# "--enable-firewall"            								# Install a Firewall to control public network access
  attr_accessor :bluelock_image								  	# "-I"        																	# Your Bluelock virtual app template/image name
  attr_accessor :bluelock_image_l								  # "--bluelock-image"       											# Your Bluelock virtual app template/image name (long)
  attr_accessor :memory							  						# "-m"       																		# Defines the number of MB of memory. Possible values are 512,1024,1536,2048,4096,8192,12288 or 16384.
  attr_accessor :memory_l							  					# "--memory"       															# Defines the number of MB of memory. Possible values are 512,1024,1536,2048,4096,8192,12288 or 16384.
  attr_accessor :run_list                         # "-r"                                          # Comma separated list of roles/recipes to apply
  attr_accessor :run_list_l                       # "--run-list"                                  # Comma separated list of roles/recipes to apply
  attr_accessor :server_name                      # "-N"                                          # The server name
  attr_accessor :server_name_l                    # "--server-name"                               # The server name
  attr_accessor :password                      		# "-p"                                          # SSH Password for the user
  attr_accessor :passworrd_l                    	# "--password"                               		# SSH Password for the user
  attr_accessor :tcp_ports                    		# "-T"                               						# TCP ports to be made accessible for this server
  attr_accessor :tcp_ports_l                    	# "--tcp"                               				# TCP ports to be made accessible for this server
	attr_accessor :template_file                    # "--template-file"                         		# Full path to location of template to use
	attr_accessor :udp_ports                    		# "-U"                               						# UDP ports to be made accessible for this server
  attr_accessor :udp_ports_l                    	# "--udp"                               				# UDP ports to be made accessible for this server
  attr_accessor :vcpus_l                    			# "--vcpus"                               			# Defines the number of vCPUS per VM. Possible values are 1,2,4,8
end


class BLKnifeServerDeleteParameters < KnifeParams
  include BLBaseKeys
end

class BLKnifeServerListParameters < KnifeParams
  include BLBaseKeys
end
