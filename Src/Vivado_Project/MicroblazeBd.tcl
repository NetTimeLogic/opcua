
################################################################
# This is a generated script based on design: MicroblazeBd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source MicroblazeBd_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
   set_property BOARD_PART digilentinc.com:arty-a7-100:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name MicroblazeBd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_ethernetlite:3.0\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:axi_timer:2.0\
xilinx.com:ip:axi_uartlite:2.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:microblaze:11.0\
xilinx.com:ip:axi_intc:4.1\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:mig_7series:4.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xadc_wiz:3.3\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
xilinx.com:ip:lmb_v10:3.0\
xilinx.com:ip:blk_mem_gen:8.4\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}


##################################################################
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_MicroblazeBd_mig_7series_0_0 { str_mig_prj_filepath } {

   file mkdir [ file dirname "$str_mig_prj_filepath" ]
   set mig_prj_file [open $str_mig_prj_filepath  w+]

   puts $mig_prj_file {﻿<?xml version="1.0" encoding="UTF-8" standalone="no" ?>}
   puts $mig_prj_file {<Project NoOfControllers="1">}
   puts $mig_prj_file {  <!-- IMPORTANT: This is an internal file that has been generated by the MIG software. Any direct editing or changes made to this file may result in unpredictable behavior or data corruption. It is strongly advised that users do not edit the contents of this file. Re-run the MIG GUI with the required settings if any of the options provided below need to be altered. -->}
   puts $mig_prj_file {  <ModuleName>MicroblazeBd_mig_7series_0_0</ModuleName>}
   puts $mig_prj_file {  <dci_inouts_inputs>1</dci_inouts_inputs>}
   puts $mig_prj_file {  <dci_inputs>1</dci_inputs>}
   puts $mig_prj_file {  <Debug_En>OFF</Debug_En>}
   puts $mig_prj_file {  <DataDepth_En>1024</DataDepth_En>}
   puts $mig_prj_file {  <LowPower_En>ON</LowPower_En>}
   puts $mig_prj_file {  <XADC_En>Disabled</XADC_En>}
   puts $mig_prj_file {  <TargetFPGA>xc7a100t-csg324/-1</TargetFPGA>}
   puts $mig_prj_file {  <Version>4.2</Version>}
   puts $mig_prj_file {  <SystemClock>No Buffer</SystemClock>}
   puts $mig_prj_file {  <ReferenceClock>No Buffer</ReferenceClock>}
   puts $mig_prj_file {  <SysResetPolarity>ACTIVE LOW</SysResetPolarity>}
   puts $mig_prj_file {  <BankSelectionFlag>FALSE</BankSelectionFlag>}
   puts $mig_prj_file {  <InternalVref>1</InternalVref>}
   puts $mig_prj_file {  <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}
   puts $mig_prj_file {  <dci_cascade>0</dci_cascade>}
   puts $mig_prj_file {  <FPGADevice>}
   puts $mig_prj_file {    <selected>7a/xc7a100ti-csg324</selected>}
   puts $mig_prj_file {  </FPGADevice>}
   puts $mig_prj_file {  <Controller number="0">}
   puts $mig_prj_file {    <MemoryDevice>DDR3_SDRAM/Components/MT41K128M16XX-15E</MemoryDevice>}
   puts $mig_prj_file {    <TimePeriod>3000</TimePeriod>}
   puts $mig_prj_file {    <VccAuxIO>1.8V</VccAuxIO>}
   puts $mig_prj_file {    <PHYRatio>4:1</PHYRatio>}
   puts $mig_prj_file {    <InputClkFreq>166.666</InputClkFreq>}
   puts $mig_prj_file {    <UIExtraClocks>0</UIExtraClocks>}
   puts $mig_prj_file {    <MMCM_VCO>666</MMCM_VCO>}
   puts $mig_prj_file {    <MMCMClkOut0> 1.000</MMCMClkOut0>}
   puts $mig_prj_file {    <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {    <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {    <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {    <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {    <DataWidth>16</DataWidth>}
   puts $mig_prj_file {    <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {    <DataMask>1</DataMask>}
   puts $mig_prj_file {    <ECC>Disabled</ECC>}
   puts $mig_prj_file {    <Ordering>Normal</Ordering>}
   puts $mig_prj_file {    <BankMachineCnt>4</BankMachineCnt>}
   puts $mig_prj_file {    <CustomPart>FALSE</CustomPart>}
   puts $mig_prj_file {    <NewPartName></NewPartName>}
   puts $mig_prj_file {    <RowAddress>14</RowAddress>}
   puts $mig_prj_file {    <ColAddress>10</ColAddress>}
   puts $mig_prj_file {    <BankAddress>3</BankAddress>}
   puts $mig_prj_file {    <MemoryVoltage>1.35V</MemoryVoltage>}
   puts $mig_prj_file {    <C0_MEM_SIZE>268435456</C0_MEM_SIZE>}
   puts $mig_prj_file {    <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {    <PinSelection>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R2" SLEW="" VCCAUX_IO="" name="ddr3_addr[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R6" SLEW="" VCCAUX_IO="" name="ddr3_addr[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U6" SLEW="" VCCAUX_IO="" name="ddr3_addr[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T6" SLEW="" VCCAUX_IO="" name="ddr3_addr[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T8" SLEW="" VCCAUX_IO="" name="ddr3_addr[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="M6" SLEW="" VCCAUX_IO="" name="ddr3_addr[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="N4" SLEW="" VCCAUX_IO="" name="ddr3_addr[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T1" SLEW="" VCCAUX_IO="" name="ddr3_addr[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="N6" SLEW="" VCCAUX_IO="" name="ddr3_addr[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R7" SLEW="" VCCAUX_IO="" name="ddr3_addr[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V6" SLEW="" VCCAUX_IO="" name="ddr3_addr[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U7" SLEW="" VCCAUX_IO="" name="ddr3_addr[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R8" SLEW="" VCCAUX_IO="" name="ddr3_addr[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V7" SLEW="" VCCAUX_IO="" name="ddr3_addr[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R1" SLEW="" VCCAUX_IO="" name="ddr3_ba[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="P4" SLEW="" VCCAUX_IO="" name="ddr3_ba[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="P2" SLEW="" VCCAUX_IO="" name="ddr3_ba[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="M4" SLEW="" VCCAUX_IO="" name="ddr3_cas_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL135" PADName="V9" SLEW="" VCCAUX_IO="" name="ddr3_ck_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL135" PADName="U9" SLEW="" VCCAUX_IO="" name="ddr3_ck_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="N5" SLEW="" VCCAUX_IO="" name="ddr3_cke[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U8" SLEW="" VCCAUX_IO="" name="ddr3_cs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="L1" SLEW="" VCCAUX_IO="" name="ddr3_dm[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U1" SLEW="" VCCAUX_IO="" name="ddr3_dm[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="K5" SLEW="" VCCAUX_IO="" name="ddr3_dq[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U4" SLEW="" VCCAUX_IO="" name="ddr3_dq[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V5" SLEW="" VCCAUX_IO="" name="ddr3_dq[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V1" SLEW="" VCCAUX_IO="" name="ddr3_dq[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T3" SLEW="" VCCAUX_IO="" name="ddr3_dq[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="U3" SLEW="" VCCAUX_IO="" name="ddr3_dq[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R3" SLEW="" VCCAUX_IO="" name="ddr3_dq[15]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="L3" SLEW="" VCCAUX_IO="" name="ddr3_dq[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="K3" SLEW="" VCCAUX_IO="" name="ddr3_dq[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="L6" SLEW="" VCCAUX_IO="" name="ddr3_dq[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="M3" SLEW="" VCCAUX_IO="" name="ddr3_dq[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="M1" SLEW="" VCCAUX_IO="" name="ddr3_dq[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="L4" SLEW="" VCCAUX_IO="" name="ddr3_dq[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="M2" SLEW="" VCCAUX_IO="" name="ddr3_dq[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="V4" SLEW="" VCCAUX_IO="" name="ddr3_dq[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="T5" SLEW="" VCCAUX_IO="" name="ddr3_dq[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL135" PADName="N1" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL135" PADName="V2" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL135" PADName="N2" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL135" PADName="U2" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="R5" SLEW="" VCCAUX_IO="" name="ddr3_odt[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="P3" SLEW="" VCCAUX_IO="" name="ddr3_ras_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="K6" SLEW="" VCCAUX_IO="" name="ddr3_reset_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL135" PADName="P5" SLEW="" VCCAUX_IO="" name="ddr3_we_n"/>}
   puts $mig_prj_file {    </PinSelection>}
   puts $mig_prj_file {    <System_Control>}
   puts $mig_prj_file {      <Pin Bank="16" PADName="No connect" name="sys_rst"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="init_calib_complete"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="tg_compare_error"/>}
   puts $mig_prj_file {    </System_Control>}
   puts $mig_prj_file {    <TimingParameters>}
   puts $mig_prj_file {      <Parameters tcke="5.625" tfaw="45" tras="36" trcd="13.5" trefi="7.8" trfc="160" trp="13.5" trrd="7.5" trtp="7.5" twtr="7.5"/>}
   puts $mig_prj_file {    </TimingParameters>}
   puts $mig_prj_file {    <mrBurstLength name="Burst Length">8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {    <mrBurstType name="Read Burst Type and Length">Sequential</mrBurstType>}
   puts $mig_prj_file {    <mrCasLatency name="CAS Latency">5</mrCasLatency>}
   puts $mig_prj_file {    <mrMode name="Mode">Normal</mrMode>}
   puts $mig_prj_file {    <mrDllReset name="DLL Reset">No</mrDllReset>}
   puts $mig_prj_file {    <mrPdMode name="DLL control for precharge PD">Slow Exit</mrPdMode>}
   puts $mig_prj_file {    <emrDllEnable name="DLL Enable">Enable</emrDllEnable>}
   puts $mig_prj_file {    <emrOutputDriveStrength name="Output Driver Impedance Control">RZQ/6</emrOutputDriveStrength>}
   puts $mig_prj_file {    <emrMirrorSelection name="Address Mirroring">Disable</emrMirrorSelection>}
   puts $mig_prj_file {    <emrCSSelection name="Controller Chip Select Pin">Enable</emrCSSelection>}
   puts $mig_prj_file {    <emrRTT name="RTT (nominal) - On Die Termination (ODT)">RZQ/6</emrRTT>}
   puts $mig_prj_file {    <emrPosted name="Additive Latency (AL)">0</emrPosted>}
   puts $mig_prj_file {    <emrOCD name="Write Leveling Enable">Disabled</emrOCD>}
   puts $mig_prj_file {    <emrDQS name="TDQS enable">Enabled</emrDQS>}
   puts $mig_prj_file {    <emrRDQS name="Qoff">Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {    <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh">Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {    <mr2CasWriteLatency name="CAS write latency">5</mr2CasWriteLatency>}
   puts $mig_prj_file {    <mr2AutoSelfRefresh name="Auto Self Refresh">Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {    <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate">Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {    <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)">Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {    <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {    <AXIParameters>}
   puts $mig_prj_file {      <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {      <C0_S_AXI_ADDR_WIDTH>28</C0_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_DATA_WIDTH>128</C0_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_ID_WIDTH>1</C0_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_SUPPORTS_NARROW_BURST>0</C0_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {    </AXIParameters>}
   puts $mig_prj_file {  </Controller>}
   puts $mig_prj_file {</Project>}

   close $mig_prj_file
}
# End of write_mig_file_MicroblazeBd_mig_7series_0_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB

  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB


  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [ list \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3 ]

  set Vaux0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0 ]

  set Vaux1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1 ]

  set Vaux2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux2 ]

  set Vaux4 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux4 ]

  set Vaux5 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux5 ]

  set Vaux6 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux6 ]

  set Vaux7 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux7 ]

  set Vaux9 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9 ]

  set Vaux10 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux10 ]

  set Vaux12 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux12 ]

  set Vaux13 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux13 ]

  set Vaux14 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux14 ]

  set Vaux15 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux15 ]

  set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]

  set eth_mdio_mdc [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 eth_mdio_mdc ]

  set eth_mii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mii_rtl:1.0 eth_mii ]

  set led_4bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 led_4bits ]

  set rgb_led [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 rgb_led ]

  set usb_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 usb_uart ]


  # Create ports
  set SysClk_ClkIn [ create_bd_port -dir I -type clk SysClk_ClkIn ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {SysRstN_RstIn} \
   CONFIG.FREQ_HZ {100000000} \
   CONFIG.PHASE {0.000} \
 ] $SysClk_ClkIn
  set SysRstN_RstIn [ create_bd_port -dir I -type rst SysRstN_RstIn ]
  set eth_ref_clk [ create_bd_port -dir O -type clk eth_ref_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {25000000} \
 ] $eth_ref_clk

  # Create instance: axi_ethernetlite_0, and set properties
  set axi_ethernetlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernetlite:3.0 axi_ethernetlite_0 ]
  set_property -dict [ list \
   CONFIG.MDIO_BOARD_INTERFACE {eth_mdio_mdc} \
   CONFIG.MII_BOARD_INTERFACE {eth_mii} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_ethernetlite_0

  # Create instance: axi_gpio_led, and set properties
  set axi_gpio_led [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_led ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {1} \
   CONFIG.C_GPIO2_WIDTH {12} \
   CONFIG.C_GPIO_WIDTH {4} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.GPIO2_BOARD_INTERFACE {rgb_led} \
   CONFIG.GPIO_BOARD_INTERFACE {led_4bits} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_gpio_led

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.SYNCHRONIZATION_STAGES {2} \
 ] $axi_mem_intercon

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
   CONFIG.C_BAUDRATE {115200} \
   CONFIG.UARTLITE_BOARD_INTERFACE {usb_uart} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uartlite_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {100.0} \
   CONFIG.CLKOUT1_JITTER {130.958} \
   CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT2_JITTER {118.758} \
   CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {166.667} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {114.829} \
   CONFIG.CLKOUT3_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_JITTER {175.402} \
   CONFIG.CLKOUT4_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {25} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {10.000} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {6} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {5} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {40} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {4} \
   CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_1

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0 ]
  set_property -dict [ list \
   CONFIG.C_CACHE_BYTE_SIZE {16384} \
   CONFIG.C_DCACHE_BYTE_SIZE {16384} \
   CONFIG.C_DEBUG_ENABLED {1} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_I_LMB {1} \
   CONFIG.C_USE_DCACHE {1} \
   CONFIG.C_USE_ICACHE {1} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_intc, and set properties
  set microblaze_0_axi_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 microblaze_0_axi_intc ]
  set_property -dict [ list \
   CONFIG.C_HAS_FAST {1} \
 ] $microblaze_0_axi_intc

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {6} \
   CONFIG.SYNCHRONIZATION_STAGES {2} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: microblaze_0_xlconcat, and set properties
  set microblaze_0_xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 microblaze_0_xlconcat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {4} \
 ] $microblaze_0_xlconcat

  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0 ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]
  set str_mig_file_name mig_b.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}

  write_mig_file_MicroblazeBd_mig_7series_0_0 $str_mig_file_path

  set_property -dict [ list \
   CONFIG.BOARD_MIG_PARAM {Custom} \
   CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.XML_INPUT_FILE {mig_b.prj} \
 ] $mig_7series_0

  # Create instance: rst_clk_wiz_1_100M, and set properties
  set rst_clk_wiz_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_1_100M ]
  set_property -dict [ list \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $rst_clk_wiz_1_100M

  # Create instance: rst_mig_7series_0_83M, and set properties
  set rst_mig_7series_0_83M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_mig_7series_0_83M ]

  # Create instance: xadc_wiz_0, and set properties
  set xadc_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.3 xadc_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CHANNEL_ENABLE_TEMPERATURE {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP0_VAUXN0 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP10_VAUXN10 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP11_VAUXN11 {false} \
   CONFIG.CHANNEL_ENABLE_VAUXP12_VAUXN12 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP13_VAUXN13 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP14_VAUXN14 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP15_VAUXN15 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP1_VAUXN1 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP2_VAUXN2 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP4_VAUXN4 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP5_VAUXN5 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP6_VAUXN6 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP7_VAUXN7 {true} \
   CONFIG.CHANNEL_ENABLE_VAUXP9_VAUXN9 {true} \
   CONFIG.CHANNEL_ENABLE_VP_VN {true} \
   CONFIG.ENABLE_RESET {false} \
   CONFIG.ENABLE_TEMP_BUS {true} \
   CONFIG.EXTERNAL_MUX_CHANNEL {VP_VN} \
   CONFIG.INTERFACE_SELECTION {Enable_AXI} \
   CONFIG.OT_ALARM {false} \
   CONFIG.SEQUENCER_MODE {Continuous} \
   CONFIG.SINGLE_CHANNEL_SELECTION {TEMPERATURE} \
   CONFIG.USER_TEMP_ALARM {true} \
   CONFIG.VCCAUX_ALARM {true} \
   CONFIG.VCCINT_ALARM {true} \
   CONFIG.VCCINT_ALARM_LOWER {0.95} \
   CONFIG.VCCINT_ALARM_UPPER {0.98} \
   CONFIG.XADC_STARUP_SELECTION {channel_sequencer} \
 ] $xadc_wiz_0

  # Create interface connections
  connect_bd_intf_net -intf_net Vaux0_1 [get_bd_intf_ports Vaux0] [get_bd_intf_pins xadc_wiz_0/Vaux0]
  connect_bd_intf_net -intf_net Vaux10_1 [get_bd_intf_ports Vaux10] [get_bd_intf_pins xadc_wiz_0/Vaux10]
  connect_bd_intf_net -intf_net Vaux12_1 [get_bd_intf_ports Vaux12] [get_bd_intf_pins xadc_wiz_0/Vaux12]
  connect_bd_intf_net -intf_net Vaux13_1 [get_bd_intf_ports Vaux13] [get_bd_intf_pins xadc_wiz_0/Vaux13]
  connect_bd_intf_net -intf_net Vaux14_1 [get_bd_intf_ports Vaux14] [get_bd_intf_pins xadc_wiz_0/Vaux14]
  connect_bd_intf_net -intf_net Vaux15_1 [get_bd_intf_ports Vaux15] [get_bd_intf_pins xadc_wiz_0/Vaux15]
  connect_bd_intf_net -intf_net Vaux1_1 [get_bd_intf_ports Vaux1] [get_bd_intf_pins xadc_wiz_0/Vaux1]
  connect_bd_intf_net -intf_net Vaux2_1 [get_bd_intf_ports Vaux2] [get_bd_intf_pins xadc_wiz_0/Vaux2]
  connect_bd_intf_net -intf_net Vaux4_1 [get_bd_intf_ports Vaux4] [get_bd_intf_pins xadc_wiz_0/Vaux4]
  connect_bd_intf_net -intf_net Vaux5_1 [get_bd_intf_ports Vaux5] [get_bd_intf_pins xadc_wiz_0/Vaux5]
  connect_bd_intf_net -intf_net Vaux6_1 [get_bd_intf_ports Vaux6] [get_bd_intf_pins xadc_wiz_0/Vaux6]
  connect_bd_intf_net -intf_net Vaux7_1 [get_bd_intf_ports Vaux7] [get_bd_intf_pins xadc_wiz_0/Vaux7]
  connect_bd_intf_net -intf_net Vaux9_1 [get_bd_intf_ports Vaux9] [get_bd_intf_pins xadc_wiz_0/Vaux9]
  connect_bd_intf_net -intf_net Vp_Vn_1 [get_bd_intf_ports Vp_Vn] [get_bd_intf_pins xadc_wiz_0/Vp_Vn]
  connect_bd_intf_net -intf_net axi_ethernetlite_0_MDIO [get_bd_intf_ports eth_mdio_mdc] [get_bd_intf_pins axi_ethernetlite_0/MDIO]
  connect_bd_intf_net -intf_net axi_ethernetlite_0_MII [get_bd_intf_ports eth_mii] [get_bd_intf_pins axi_ethernetlite_0/MII]
  connect_bd_intf_net -intf_net axi_gpio_2_GPIO [get_bd_intf_ports led_4bits] [get_bd_intf_pins axi_gpio_led/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_2_GPIO2 [get_bd_intf_ports rgb_led] [get_bd_intf_pins axi_gpio_led/GPIO2]
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports usb_uart] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DC [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins microblaze_0/M_AXI_DC]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_IC [get_bd_intf_pins axi_mem_intercon/S01_AXI] [get_bd_intf_pins microblaze_0/M_AXI_IC]
  connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins axi_ethernetlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins axi_timer_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI] [get_bd_intf_pins xadc_wiz_0/s_axi_lite]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins axi_gpio_led/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net microblaze_0_intc_axi [get_bd_intf_pins microblaze_0_axi_intc/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_interrupt [get_bd_intf_pins microblaze_0/INTERRUPT] [get_bd_intf_pins microblaze_0_axi_intc/interrupt]
  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_ports DDR3] [get_bd_intf_pins mig_7series_0/DDR3]

  # Create port connections
  connect_bd_net -net axi_ethernetlite_0_ip2intc_irpt [get_bd_pins axi_ethernetlite_0/ip2intc_irpt] [get_bd_pins microblaze_0_xlconcat/In1]
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In0]
  connect_bd_net -net axi_uartlite_0_interrupt [get_bd_pins axi_uartlite_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In3]
  connect_bd_net -net clk_wiz_1_clk_out2 [get_bd_pins clk_wiz_1/clk_out2] [get_bd_pins mig_7series_0/sys_clk_i]
  connect_bd_net -net clk_wiz_1_clk_out3 [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins mig_7series_0/clk_ref_i]
  connect_bd_net -net clk_wiz_1_clk_out4 [get_bd_ports eth_ref_clk] [get_bd_pins clk_wiz_1/clk_out4]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst_clk_wiz_1_100M/dcm_locked]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins axi_ethernetlite_0/s_axi_aclk] [get_bd_pins axi_gpio_led/s_axi_aclk] [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_intc/processor_clk] [get_bd_pins microblaze_0_axi_intc/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk]
  connect_bd_net -net microblaze_0_intr [get_bd_pins microblaze_0_axi_intc/intr] [get_bd_pins microblaze_0_xlconcat/dout]
  connect_bd_net -net mig_7series_0_mmcm_locked [get_bd_pins mig_7series_0/mmcm_locked] [get_bd_pins rst_mig_7series_0_83M/dcm_locked]
  connect_bd_net -net mig_7series_0_ui_clk [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins mig_7series_0/ui_clk] [get_bd_pins rst_mig_7series_0_83M/slowest_sync_clk] [get_bd_pins xadc_wiz_0/s_axi_aclk]
  connect_bd_net -net mig_7series_0_ui_clk_sync_rst [get_bd_pins mig_7series_0/ui_clk_sync_rst] [get_bd_pins rst_mig_7series_0_83M/ext_reset_in]
  connect_bd_net -net resetn_0_1 [get_bd_ports SysRstN_RstIn] [get_bd_pins clk_wiz_1/resetn] [get_bd_pins mig_7series_0/sys_rst] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins rst_clk_wiz_1_100M/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins microblaze_0_axi_intc/processor_rst] [get_bd_pins rst_clk_wiz_1_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins axi_ethernetlite_0/s_axi_aresetn] [get_bd_pins axi_gpio_led/s_axi_aresetn] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_intc/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]
  connect_bd_net -net rst_mig_7series_0_83M_peripheral_aresetn [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins mig_7series_0/aresetn] [get_bd_pins rst_mig_7series_0_83M/peripheral_aresetn] [get_bd_pins xadc_wiz_0/s_axi_aresetn]
  connect_bd_net -net sys_clock_1 [get_bd_ports SysClk_ClkIn] [get_bd_pins clk_wiz_1/clk_in1]
  connect_bd_net -net xadc_wiz_0_ip2intc_irpt [get_bd_pins microblaze_0_xlconcat/In2] [get_bd_pins xadc_wiz_0/ip2intc_irpt]
  connect_bd_net -net xadc_wiz_0_temp_out [get_bd_pins mig_7series_0/device_temp_i] [get_bd_pins xadc_wiz_0/temp_out]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x40E00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_ethernetlite_0/S_AXI/Reg] SEG_axi_ethernetlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40010000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_led/S_AXI/Reg] SEG_axi_gpio_2_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00008000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00008000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_axi_intc/S_AXI/Reg] SEG_microblaze_0_axi_intc_Reg
  create_bd_addr_seg -range 0x10000000 -offset 0x80000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x10000000 -offset 0x80000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs xadc_wiz_0/s_axi_lite/Reg] SEG_xadc_wiz_0_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


