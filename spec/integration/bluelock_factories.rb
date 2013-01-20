# -*- coding: utf-8 -*-
# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.m

require  File.expand_path(File.dirname(__FILE__) +'/bluelock')
# require  File.expand_path(File.dirname(__FILE__) +'/models/knife_parameters')
require "securerandom"

FactoryGirl.define do

  factory :blKnifeParams, class: KnifeParams do
    server_url                       "-s"                                          # Chef Server URL
    server_url_l                     "--server-url"                                # Chef Server URL
    api_client_key                   "-k"                                          # API Client Key
    api_client_key_l                 "--key"                                       # API Client Key
    colored_optput                   "--[no-]color"                                # Use colored output, defaults to enabled
    config_file                      "-c"                                          # The configuration file to use
    config_file_l                    "--config"                                    # The configuration file to use
    defaults                         "--defaults"                                  # Accept default values for all questions
    disable_editing                  "-d"                                          # Do not open EDITOR, just accept the data as is
    disable_editing_l                "--disable-editing"                           # Do not open EDITOR, just accept the data as is
    editor                           "-e"                                          # Set the editor to use for interactive commands
    editor_l                         "--editor"                                    # Set the editor to use for interactive commands
    environment                      "-E"                                          # Set the Chef environment
    environment_l                    "--environment"                               # Set the Chef environment
    format                           "-F"                                          # Which format to use for output
    format_l                         "--format"                                    # Which format to use for output
    identity_file                    "-i"                                          # The SSH identity file used for authentication
    identity_file_l                  "--identity-file"                             # The SSH identity file used for authentication
    user                             "-u"                                          # API Client Username
    user_l                           "--user"                                      # API Client Username
    pre_release                      "--prerelease"                                # Install the pre-release chef gems
    print_after                      "--print-after"                               # Show the data after a destructive operation
    verbose                          "-V"                                          # More verbose output. Use twice for max verbosity
    verbose_l                        "--verbose"                                   # More verbose output. Use twice for max verbosity
    version_chef                     "-v"                                          # Show chef version
    version_chef_l                   "--version"                                   # Show chef version
    say_yes_to_all_prompts           "-y"                                          # Say yes to all prompts for confirmation
    say_yes_to_all_prompts_l         "--yes"                                       # Say yes to all prompts for confirmation
    help                             "-h"                                          # Show help
    help_l                           "--help"                                      # Show help
  end

  factory :blKnifeCommands, class: BLKnifeCommands do
    cmd_list_image                   "knife bluelock image list"               # Knife command for listing servers
    cmd_create_server                 "knife bluelock server create"          # Knife command for creating a server
    cmd_delete_server                 "knife bluelock server delete"          # Knife command for deleting a server
    cmd_list_server                   "knife bluelock server list"            # Knife command for listing servers
  end

  factory :blServerCreateParameters, class: BLKnifeServerCreateParameters , parent: :blKnifeParams do
    bl_username                      "-A"                                     # Bluelock username
    bl_username_l                    "--bluelock-username"                    # Bluelock username long
    bl_password                      "-K"                                     # Bluelock password
    bl_password_l                    "--bluelock-password"                    # Bluelock password long
    node_name                        "--node-name"                                 # The Chef node name for your new node
    enable_firewall                  "--enable-firewall"                           # Install a Firewall to control public network access
    bluelock_image                   "-I"                                          # Your Bluelock virtual app template/image name
    bluelock_image_l                 "--bluelock-image"                            # Your Bluelock virtual app template/image name (long)
    memory                           "-m"                                          # Defines the number of MB of memory. Possible values are 512,1024,1536,2048,4096,8192,12288 or 16384.
    memory_l                         "--memory"                                    # Defines the number of MB of memory. Possible values are 512,1024,1536,2048,4096,8192,12288 or 16384.
    run_list                         "-r"                                          # Comma separated list of roles/recipes to apply
    run_list_l                       "--run-list"                                  # Comma separated list of roles/recipes to apply
    server_name                      "-N"                                          # The server name
    server_name_l                    "--server-name"                               # The server name
    password                         "-p"                                          # SSH Password for the user
    passworrd_l                      "--password"                                  # SSH Password for the user
    tcp_ports                        "-T"                                          # TCP ports to be made accessible for this server
    tcp_ports_l                      "--tcp"                                       # TCP ports to be made accessible for this server
    template_file                    "--template-file"                             # Full path to location of template to use
    udp_ports                        "-U"                                          # UDP ports to be made accessible for this server
    udp_ports_l                      "--udp"                                       # UDP ports to be made accessible for this server
    vcpus_l                          "--vcpus"                                     # Defines the number of vCPUS per VM. Possible values are 1,2,4,8
  end

  factory :blServerDeleteParameters, class: BLKnifeServerDeleteParameters , parent: :blKnifeParams do
    bl_username                      "-A"                                     # Bluelock username
    bl_username_l                    "--bluelock-username"                    # Bluelock username long
    bl_password                      "-K"                                     # Bluelock password
    bl_password_l                    "--bluelock-password"                    # Bluelock password long
  end

  factory :blServerListParameters, class: BLKnifeServerListParameters , parent: :blKnifeParams do
    bl_username                      "-A"                                     # Bluelock username
    bl_username_l                    "--bluelock-username"                    # Bluelock username long
    bl_password                      "-K"                                     # Bluelock password
    bl_password_l                    "--bluelock-password"                    # Bluelock password long
  end

  factory :blImageListParameters, class: BLKnifeImageListParameters , parent: :blKnifeParams do
    bl_username                      "-A"                                     # Bluelock username
    bl_username_l                    "--bluelock-username"                    # Bluelock username long
    bl_password                      "-K"                                     # Bluelock password
    bl_password_l                    "--bluelock-password"                    # Bluelock password long
  end

  bl_server_create_params_factory   = FactoryGirl.build(:blServerCreateParameters)
  bl_server_delete_params_factory   = FactoryGirl.build(:blServerDeleteParameters)
  bl_server_list_params_factory     = FactoryGirl.build(:blServerListParameters)

  properties_file = File.expand_path(File.dirname(__FILE__) + "/properties/credentials.yml")
  properties = File.open(properties_file) { |yf| YAML::load(yf) }
  valid_bl_username     = properties["credentials"]["username"]
  valid_bl_password     = properties["credentials"]["password"]

  # Base Factory for server create
  factory :blServerCreateBase, class: BLKnifeServerCreateParameters do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name        "#{bl_server_create_params_factory.node_name} "       + name_of_the_node
    server_name      "#{bl_server_create_params_factory.server_name} "     + name_of_the_node
    bl_username      "#{bl_server_create_params_factory.bl_username} "     + "#{valid_bl_username}"
    bl_password      "#{bl_server_create_params_factory.bl_password} "     + "#{valid_bl_password}"
    bluelock_image   "#{bl_server_create_params_factory.bluelock_image} "  + "78cdde13-b0e2-417d-bd5f-825ed7641e8d" #OS-Ubuntu10.04_x64
    memory           "#{bl_server_create_params_factory.memory} "          + "512"
    password         "#{bl_server_create_params_factory.password} "          + "password"
  end

  # Base Factory for server delete
  factory :blServerDeleteBase, class: BLKnifeServerDeleteParameters do
    bl_username      "#{bl_server_create_params_factory.bl_username} "      + "#{valid_bl_username}"
    bl_password      "#{bl_server_create_params_factory.bl_password} "      + "#{valid_bl_password}"
  end

  # Base Factory for server list
  factory :blServerListBase, class: BLKnifeServerListParameters do
    bl_username      "#{bl_server_create_params_factory.bl_username} "      + "#{valid_bl_username}"
    bl_password      "#{bl_server_create_params_factory.bl_password} "      + "#{valid_bl_password}"
  end

  # Test Case: OP_KBP_1, CreateServerWithDefaults
  factory :blServerCreateWithDefaults, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "     + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "   + name_of_the_node
  end


  # Test Case: OP_KBP_2, CreateServerWithUnsupportedVCPU
  factory :blServerCreateWithUnsupportedVCPU, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    vcpus_l           "#{bl_server_create_params_factory.vcpus_l} "           + "1112"

  end

  # Test Case: OP_KBP_3, CreateServerWithUnsupportedRAM
  factory :blServerCreateWithUnsupportedRAM, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    memory            "#{bl_server_create_params_factory.memory} "            + "100222"
  end

  # Test Case: OP_KBP_3, CreateServerWithSupportedRAMandCPU
  factory :blCreateServerWithSupportedRAMandCPU, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    memory            "#{bl_server_create_params_factory.memory} "            + "4096"
    vcpus_l           "#{bl_server_create_params_factory.vcpus_l} "           + "4"
  end

  # Test Case: OP_KBP_4, CreateServerWithTCPPortList
  factory :blServerCreateWithTCPPortList, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    tcp_ports         "#{bl_server_create_params_factory.tcp_ports} "         + "'80:80,443:8433'"
  end

  # Test Case: OP_KBP_5, CreateServerWithUDPPortList
  factory :blServerCreateWithUDPPortList, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    udp_ports         "#{bl_server_create_params_factory.udp_ports} "         + "'80:80,443:8433'"
  end

  # Test Case: OP_KBP_6, CreateServerWithFirewallOff
  factory :blServerCreateWithFirewallOff, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "       + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    enable_firewall   "--no-enable-firewall"
  end


  # Test Case: OP_KBP_7, CreateServerwithFirewallOffAndTCPPortlist
  factory :CreateServerwithFirewallOffAndTCPPortlist, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "       + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    tcp_ports         "#{bl_server_create_params_factory.tcp_ports} "       + "'161:161,111:111'"
    enable_firewall   "--no-enable-firewall"
  end

  # Test Case: OP_KBP_8, DeleteServerThatDoesNotExist
  factory :blServerDeleteNonExistent, parent: :blServerDeleteBase do
  end

  # Test Case: OP_KBP_9, DeleteMutipleServers
  factory :blServerDeleteMutiple, parent: :blServerDeleteBase do
  end

  # Test Case: OP_KBP_10, ListServerEmpty
  factory :blServerListEmpty, parent: :blServerListBase do
  end

  # Test Case: OP_KBP_11, ListServerNonEmpty
  factory :blServerListNonEmpty, parent: :blServerListBase do
  end

  # Test Case: OP_KBP_12, DeleteServerPurge
  factory :blServerDeletePurge, parent: :blServerDeleteBase do
    # purge          "#{bl_server_create_params_factory.purge} "
  end

  # Test Case: OP_KBP_13, DeleteServerDontPurge
  factory :blServerDeleteDonrPurge, parent: :blServerDeleteBase do
  end

  # Test Case: OP_KBP_14, CreateServerWithValidNodeName
  factory :blServerCreateWithValidNodeName, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
  end

  # Test Case: OP_KBP_15, CreateServerWithRoleAndRecipe
  factory :blServerCreateWithRoleAndRecipe, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    run_list          "#{bl_server_create_params_factory.run_list} "          + "recipe[build-essential], role[webserver]"
  end

  # Test Case: OP_KBP_16, CreateServerWithInvalidRole
  factory :blServerCreateWithInvalidRole, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         + name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    run_list          "#{bl_server_create_params_factory.run_list} "          + "recipe[build-essential], role[invalid-role]"
  end

  # Test Case: OP_KBP_17, CreateServerWithInvalidRecipe
  factory :blServerCreateWithInvalidRecipe, parent: :blServerCreateBase do
    name_of_the_node  = "bl#{SecureRandom.hex(4)}"
    node_name         "#{bl_server_create_params_factory.node_name} "         +  name_of_the_node
    server_name       "#{bl_server_create_params_factory.server_name} "       + name_of_the_node
    run_list          "#{bl_server_create_params_factory.run_list} "          + "recipe[invalid-recipe]"
  end

end
