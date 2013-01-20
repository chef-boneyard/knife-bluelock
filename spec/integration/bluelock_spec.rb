# -*- coding: utf-8 -*-
# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
require File.expand_path(File.dirname(__FILE__) + '/bluelock_factories')

require 'knife_cloud_tests'
require 'knife_cloud_tests/knifeutils'
require 'knife_cloud_tests/matchers'
#require File.expand_path(File.dirname(__FILE__) +'../../../spec_helper')
require "securerandom"

RSpec.configure do |config|
  FactoryGirl.find_definitions
end

def prepare_create_srv_cmd_bl_cspec(server_create_factory)
  cmd = "#{cmds_bl.cmd_create_server} " +
    strip_out_command_key("#{server_create_factory.node_name}")  +
    " "+
    prepare_knife_command(server_create_factory)
  return cmd
end

# Common method to run create server test cases

def run_bl_cspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised, run_list_cmd = true, run_del_cmd = true)
  context "" do
    instance_name = "instance_name"
    cmd_out = ""
    context "#{test_context}" do
      let(:server_create_factory){ FactoryGirl.build(factory_to_be_exercised) }
      # let(:instance_name){ strip_out_command_key("#{server_create_factory.node_name}") }
      let(:command) { prepare_create_srv_cmd_bl_cspec(server_create_factory) }
      after(:each){instance_name = strip_out_command_key("#{server_create_factory.node_name}")}
      context "#{test_case_scene}" do
        it "#{test_run_expect[:status]}" do
          match_status(test_run_expect)
        end
      end
    end

    if run_list_cmd
      context "list server after #{test_context} " do
        let(:grep_cmd) { "| grep -e #{instance_name}" }
        let(:command) { prepare_list_srv_cmd_bl_lspec(srv_list_base_fact_bl)}
        after(:each){cmd_out = "#{cmd_stdout}"}
        it "should succeed" do
          match_status({:status => "should succeed"})
        end
      end
    end

    if run_del_cmd
      context "delete-purge server after #{test_context} #{test_case_scene}" do
        let(:command) { "#{cmds_bl.cmd_delete_server}" + " " +
                        "#{instance_name}" +
                        " " +
                        prepare_knife_command(srv_del_base_fact_bl) +
                        " -y" + " -N #{instance_name} -P"}
        it "should succeed" do
          match_status({:status => "should succeed"})
        end
      end
    end
  end
end


# Common method to run create server test cases

def run_bl_lspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
  context "#{test_context}" do
    let(:server_list_factory){ FactoryGirl.build(factory_to_be_exercised) }
    let(:command) { prepare_list_srv_cmd_bl_lspec(server_list_factory) }
    after(:each) {puts "Test case completed!"}
    context "#{test_case_scene}" do
      it "#{test_run_expect[:status]}" do
        match_status(test_run_expect)
      end
    end
  end
end

def prepare_list_srv_cmd_bl_lspec(factory)
  cmd = "#{cmds_bl.cmd_list_server} " +
  prepare_knife_command(factory)
  return cmd
end


def create_srv_bl_dspec(server_create_factory)
  cmd = "#{cmds_bl.cmd_create_server} " +
  prepare_knife_command(server_create_factory)
  shell_out_command(cmd, "creating instance...")
end

def create_srvs_bl_dspec(count)
  for server_count in 0..count
    name_of_the_node    = "bl#{SecureRandom.hex(4)}"
    node_name_local     = "#{srv_create_params_fact_bl.node_name} "  + name_of_the_node
    server_name_local   = "#{srv_create_params_fact_bl.server_name} "  + name_of_the_node
    fact =  FactoryGirl.build(:blServerCreateWithDefaults,
      node_name: node_name_local,
      server_name: server_name_local)
    instances.push fact
    create_srv_bl_dspec(fact)
  end
  return instances
end

def find_srv_ids_bl_dspec(instances)
  instance_ids = []
  instances.each do |instance|
    instance_ids.push strip_out_command_key("#{instance.node_name}")
  end
  return instance_ids
end

# Method to prepare bl create server command

def prepare_del_srv_cmd_bl_dspec(factory, instances)
  cmd ="#{cmds_bl.cmd_delete_server}" + " " +
  "#{prepare_list_srv_ids_bl_dspec(instances)}" + " " + prepare_knife_command(factory) + " -y"
  return cmd
end

def prepare_del_srv_cmd_purge_bl_dspec(factory, instances)
  node_names = "-N"
  instances.each do |instance|
    node_names = node_names + " " + strip_out_command_key("#{instance.node_name}")
  end

  cmd ="#{cmds_bl.cmd_delete_server}" + " " +
  "#{prepare_list_srv_ids_bl_dspec(instances)}" + " " +  node_names + " -P " + prepare_knife_command(factory) + " -y"
  return cmd
end

def prepare_del_srv_cmd_non_existent_bl_dspec(factory)
  cmd ="#{cmds_bl.cmd_delete_server}" + " " +
  "1234567890" + " " + prepare_knife_command(factory) + " -y"
  return cmd
end

def prepare_list_srv_ids_bl_dspec(instances)
  instances_to_be_deleted = ""
  instance_ids = find_srv_ids_bl_dspec(instances)
  instance_ids.each do |instance|
    instances_to_be_deleted = instances_to_be_deleted + " " + "#{instance}"
  end
  return instances_to_be_deleted
end

# Common method to run create server test cases

def run_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised, test_case_type="")
  case test_case_type
      when "delete"
        srv_del_test_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
      when "delete_purge"
        srv_del_test_purge_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
      when "delete_multiple"
        srv_del_test_mult_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
      when "delete_non_existent"
        srv_del_test_non_exist_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
      else
  end
end

def srv_del_test_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
  context "#{test_context}" do
    let(:instances) { [] }
    before(:each) {create_srvs_bl_dspec(0)}
    let(:server_delete_factory){ FactoryGirl.build(factory_to_be_exercised) }
    let(:command) { prepare_del_srv_cmd_purge_bl_dspec(server_delete_factory, instances) }
    after(:each) {puts "Test case completed!"}
    context "#{test_case_scene}" do
      it "#{test_run_expect[:status]}" do
        match_status(test_run_expect)
      end
    end
  end
end

def srv_del_test_purge_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
  context "#{test_context}" do
    let(:instances) { [] }
    before(:each) {create_srvs_bl_dspec(0)}
    let(:server_delete_factory){ FactoryGirl.build(factory_to_be_exercised) }
    let(:command) { prepare_del_srv_cmd_purge_bl_dspec(server_delete_factory, instances) }
    after(:each) {puts "Test case completed!"}
    context "#{test_case_scene}" do
      it "#{test_run_expect[:status]}" do
        match_status(test_run_expect)
      end
    end
  end
end

def srv_del_test_mult_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
  context "#{test_context}" do
    let(:instances) { [] }
    before(:each) {create_srvs_bl_dspec(1)}
    let(:server_delete_factory){ FactoryGirl.build(factory_to_be_exercised) }
    let(:command) { prepare_del_srv_cmd_purge_bl_dspec(server_delete_factory, instances) }
    after(:each) {puts "Test case completed!"}
    context "#{test_case_scene}" do
      it "#{test_run_expect[:status]}" do
        match_status(test_run_expect)
      end
    end
  end
end

def srv_del_test_non_exist_bl_dspec(test_context, test_case_scene, test_run_expect, factory_to_be_exercised)
  context "#{test_context}" do
    let(:server_delete_factory){ FactoryGirl.build(factory_to_be_exercised) }
    let(:command) { prepare_del_srv_cmd_non_existent_bl_dspec(server_delete_factory) }
    after(:each) {puts "Test case completed!"}
    context "#{test_case_scene}" do
      it "#{test_run_expect[:status]}" do
        match_status(test_run_expect)
      end
    end
  end
end

describe 'knife bluelock' do
  include RSpec::KnifeUtils
  # before(:all) { load_factory_girl }
  before(:all) { load_knife_config }

  let(:cmds_bl) { FactoryGirl.build(:blKnifeCommands) }
  let(:srv_del_base_fact_bl) {FactoryGirl.build(:blServerDeleteBase) }
  let(:srv_list_base_fact_bl) {FactoryGirl.build(:blServerListBase) }
  let(:srv_create_params_fact_bl){FactoryGirl.build(:blServerCreateParameters)}

  expected_params = {
                     :status => "should succeed",
                     :stdout => nil,
                     :stderr => nil
                   }
  # Test Case: OP_KBP_1, CreateServerWithDefaults
  run_bl_cspec("server create", "with all default parameters", expected_params, :blServerCreateWithDefaults, true)

  # Test Case: OP_KBP_3, CreateServerWithSupportedRAMandCPU
  run_bl_cspec("server create", "with supported RAM and CPU", expected_params, :blServerCreateWithUnsupportedRAM, false)

  # Test Case: OP_KBP_4, CreateServerWithTCPPortList
  run_bl_cspec("server create", "with TCP port list", expected_params, :blServerCreateWithTCPPortList, false)

  # Test Case: OP_KBP_5, CreateServerWithUDPPortList
  run_bl_cspec("server create", "with UDP port list", expected_params, :blServerCreateWithUDPPortList, false)

  # Test Case: OP_KBP_6, CreateServerWithFirewallOff
  run_bl_cspec("server create", "with firewall off", expected_params, :blServerCreateWithFirewallOff, false)

  # Test Case: OP_KBP_7, CreateServerwithFirewallOffAndTCPPortlist
  run_bl_cspec("server create", "with firewall off and TCP port list", expected_params, :blServerCreateWithUDPPortListStaticNat, false)

  # Test Case: OP_KBP_14, CreateServerWithValidNodeName
  run_bl_cspec("server create", "with valid node name", expected_params, :blServerCreateWithValidNodeName, true)

  # Test Case: OP_KBP_15, CreateServerWithRoleAndRecipe
  run_bl_cspec("server create", "with role and recipe", expected_params, :blServerCreateWithRoleAndRecipe, false)

  # Test Case: OP_KBP_20, DeleteMutipleServers
  run_bl_dspec("server delete", "command for multiple servers", expected_params, :blServerDeleteMutiple, "delete_multiple")

  # Test Case: OP_KBP_12, DeleteServerPurge
  run_bl_dspec("server delete", "with purge option", expected_params, :blServerDeletePurge, "delete_purge")

  # Test Case: OP_KBP_13, DeleteServerDontPurge
  run_bl_dspec("server delete", "woth no purge option", expected_params, :blServerDeleteDonrPurge, "delete")

  expected_params["status"] = "should return empty list"
  # Test Case: OP_KBP_10, ListServerEmpty
  run_bl_lspec("server list", "for no instances", expected_params, :blServerListEmpty)

  expected_params["should fail"]
  # Test Case: OP_KBP_2, CreateServerWithUnsupportedVCPU
  run_bl_cspec("server create", "with unsupported VCPU", expected_params, :blServerCreateWithUnsupportedVCPU, false, false)

  # Test Case: OP_KBP_3, CreateServerWithUnsupportedRAM
  run_bl_cspec("server create", "with unsupported RAM", expected_params, :blServerCreateWithUnsupportedRAM, true, false)

  # Test Case: OP_KBP_16, CreateServerWithInvalidRole
  # FIXME need to write a custom matcher to validate invalid role
  run_bl_cspec("server create", "with invalid role", expected_params, :blServerCreateWithInvalidRole, false)

  # Test Case: OP_KBP_17, CreateServerWithInvalidRecipe
  # FIXME need to write a custom matcher to validate invalid recipe
  run_bl_cspec("server create", "with invalid recipe", expected_params, :blServerCreateWithInvalidRecipe, false)

  # Test Case: OP_KBP_8, DeleteServerThatDoesNotExist
  run_bl_dspec("server delete", "with non existent server", expected_params, :blServerDeleteNonExistent, "delete_non_existent")

end
