set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { eth_ref_clk }]; 

# Analog Pin Discriptions
set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { Vaux0_v_n }]; #IO_L1N_T0_AD0N_15 Sch=ck_an_n[5]
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { Vaux0_v_p }]; #IO_L1P_T0_AD0P_15 Sch=ck_an_p[5]
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { Vaux1_v_n }]; #IO_L3N_T0_DQS_AD1N_15 Sch=ad_n[1]
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { Vaux1_v_p }]; #IO_L3P_T0_DQS_AD1P_15 Sch=ad_p[1]
set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports { Vaux2_v_n }]; #IO_L7N_T1_AD2N_15 Sch=ad_n[2]
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports { Vaux2_v_p }]; #IO_L7P_T1_AD2P_15 Sch=ad_p[2]
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { Vaux4_v_n }]; #IO_L1N_T0_AD4N_35 Sch=ck_an_n[0]
set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports { Vaux4_v_p }]; #IO_L1P_T0_AD4P_35 Sch=ck_an_p[0]
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { Vaux5_v_n }]; #IO_L3N_T0_DQS_AD5N_35 Sch=ck_an_n[1]
set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports { Vaux5_v_p }]; #IO_L3P_T0_DQS_AD5P_35 Sch=ck_an_p[1]
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { Vaux6_v_n }]; #IO_L7N_T1_AD6N_35 Sch=ck_an_n[2]
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { Vaux6_v_p }]; #IO_L7P_T1_AD6P_35 Sch=ck_an_p[2]
set_property -dict { PACKAGE_PIN A1    IOSTANDARD LVCMOS33 } [get_ports { Vaux7_v_n }]; #IO_L9N_T1_DQS_AD7N_35 Sch=ck_an_n[3]
set_property -dict { PACKAGE_PIN B1    IOSTANDARD LVCMOS33 } [get_ports { Vaux7_v_p }]; #IO_L9P_T1_DQS_AD7P_35 Sch=ck_an_p[3]
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { Vaux9_v_n }]; #IO_L5N_T0_AD9N_15 Sch=ad_n[9]
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { Vaux9_v_p }]; #IO_L5P_T0_AD9P_15 Sch=ad_p[9]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports { Vaux10_v_n }]; #IO_L8N_T1_AD10N_15 Sch=ad_n[10]
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports { Vaux10_v_p }]; #IO_L8P_T1_AD10P_15 Sch=ad_p[10]
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { Vaux12_v_n }]; #IO_L2N_T0_AD12N_35 Sch=ad_n[12]
set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { Vaux12_v_p }]; #IO_L2P_T0_AD12P_35 Sch=ad_p[12]
set_property -dict { PACKAGE_PIN E5    IOSTANDARD LVCMOS33 } [get_ports { Vaux13_v_n }]; #IO_L5N_T0_AD13N_35 Sch=ad_n[13]
set_property -dict { PACKAGE_PIN E6    IOSTANDARD LVCMOS33 } [get_ports { Vaux13_v_p }]; #IO_L5P_T0_AD13P_35 Sch=ad_p[13]
set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { Vaux14_v_n }]; #IO_L8N_T1_AD14N_35 Sch=ad_n[14]
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { Vaux14_v_p }]; #IO_L8P_T1_AD14P_35 Sch=ad_p[14]
set_property -dict { PACKAGE_PIN B2    IOSTANDARD LVCMOS33 } [get_ports { Vaux15_v_n }]; #IO_L10N_T1_AD15N_35 Sch=ck_an_n[4]
set_property -dict { PACKAGE_PIN B3    IOSTANDARD LVCMOS33 } [get_ports { Vaux15_v_p }]; #IO_L10P_T1_AD15P_35 Sch=ck_an_p[4]

# --------------------------------------------------
# Configuration pins
# --------------------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]