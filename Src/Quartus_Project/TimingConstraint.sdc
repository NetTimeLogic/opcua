#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Clock
#**************************************************************
create_clock -name {DummyClk}      -period 20.000 -waveform {0.000 10.000}
create_clock -name {Mhz25Clk}      -period 40.000 -waveform {0.000 20.000} [get_ports { Mhz25Clk_ClkIn }]
create_clock -name {MiiClk}        -period 40.000 -waveform {0.000 20.000} 
create_clock -name {SmiClk}        -period 20.000 -waveform {0.000 10.000} 
create_clock -name {Port1MiiRxClk} -period 40.000 -waveform {0.000 20.000} [get_ports {Port1MiiRxClk_ClkIn}]
create_clock -name {Port1MiiTxClk} -period 40.000 -waveform {0.000 20.000} [get_ports {Port1MiiTxClk_ClkIn}]

derive_pll_clocks

create_generated_clock -name {PllMhz50Clk} -source [get_pins {u0|altpll_0|sd1|pll7|clk[0]}]
create_generated_clock -name {PllMhz50ClkSdram} -source [get_pins {u0|altpll_0|sd1|pll7|clk[1]}] [get_ports {Sdram_ClkOut}]

derive_clock_uncertainty

#**************************************************************
# SDRAM
#**************************************************************
# t_AC, max delay and t_OH, min delay
# added 0.5 ns turn-around time to max delay
set_input_delay -add_delay -rise -max -clock [get_clocks {PllMhz50Clk}]  5.900 [get_ports {Sdram_DqInOut[*]}]
set_input_delay -add_delay -rise -min -clock [get_clocks {PllMhz50Clk}]  2.500 [get_ports {Sdram_DqInOut[*]}]

# t_CS, max delay and t_CH, min delay
set_output_delay -add_delay -rise -max -clock [get_clocks {PllMhz50Clk}]  -1.500 [get_ports {Sdram_CsNOut Sdram_RasNOut Sdram_CasNOut Sdram_WeNOut}]
set_output_delay -add_delay -rise -min -clock [get_clocks {PllMhz50Clk}]  0.800 [get_ports {Sdram_CsNOut Sdram_RasNOut Sdram_CasNOut Sdram_WeNOut}]

# t_AS, max delay and t_AH, min delay
set_output_delay -add_delay -rise -max -clock [get_clocks {PllMhz50Clk}]  -1.500 [get_ports {Sdram_AddrOut[*] Sdram_BaOut[*]}]
set_output_delay -add_delay -rise -min -clock [get_clocks {PllMhz50Clk}]  0.800 [get_ports {Sdram_AddrOut[*] Sdram_BaOut[*]}]

# t_DS, max delay and Hold time t_DH, min delay
set_output_delay -add_delay -rise -max -clock [get_clocks {PllMhz50Clk}]  -1.500 [get_ports {Sdram_DqInOut[*]}]
set_output_delay -add_delay -rise -min -clock [get_clocks {PllMhz50Clk}]  0.800 [get_ports {Sdram_DqInOut[*]}]

#**************************************************************
# Port1
#**************************************************************
set_max_delay -from [get_clocks {PllMhz50Clk}] -to [get_clocks {Port1MiiRxClk}] 18.000
set_max_delay -from [get_clocks {PllMhz50Clk}] -to [get_clocks {Port1MiiTxClk}] 18.000

set_min_delay -from [get_clocks {Port1MiiRxClk}] -to [get_clocks {PllMhz50Clk}] 12.000
set_max_delay -from [get_clocks {Port1MiiRxClk}] -to [get_clocks {PllMhz50Clk}] 18.000
set_min_delay -from [get_clocks {Port1MiiTxClk}] -to [get_clocks {PllMhz50Clk}] 12.000
set_max_delay -from [get_clocks {Port1MiiTxClk}] -to [get_clocks {PllMhz50Clk}] 18.000

set_input_delay -min 10.000 -clock [get_clocks {MiiClk}] [get_ports {Port1MiiRxDv_EnaIn Port1MiiRxErr_ErrIn Port1MiiRxData_DatIn* Port1MiiCol_DatIn Port1MiiCrs_DatIn}]
set_input_delay -max 30.000 -clock [get_clocks {MiiClk}] [get_ports {Port1MiiRxDv_EnaIn Port1MiiRxErr_ErrIn Port1MiiRxData_DatIn* Port1MiiCol_DatIn Port1MiiCrs_DatIn}]
  
set_output_delay -min 32.000 -clock [get_clocks {MiiClk}] [get_ports {Port1MiiTxEn_EnaOut Port1MiiTxData_DatOut*}]
set_output_delay -max 12.000 -clock [get_clocks {MiiClk}] [get_ports {Port1MiiTxEn_EnaOut Port1MiiTxData_DatOut*}]

set_input_delay -min 0.000 -clock [get_clocks {SmiClk}] [get_ports {Port1SmiMdio_DatInOut}]
set_input_delay -max 5.000 -clock [get_clocks {SmiClk}] [get_ports {Port1SmiMdio_DatInOut}]

set_output_delay -min 15.000 -clock [get_clocks {SmiClk}] [get_ports {Port1SmiMdc_ClkOut Port1SmiMdio_DatInOut Port1RstN_RstOut}]
set_output_delay -max 0.000 -clock [get_clocks {SmiClk}] [get_ports {Port1SmiMdc_ClkOut Port1SmiMdio_DatInOut Port1RstN_RstOut}]

#**************************************************************
# General
#**************************************************************
set_input_delay -min 0.000 -clock [get_clocks {DummyClk}] [get_ports {RstN_RstIn Uart_DatIn}]
set_input_delay -max 5.000 -clock [get_clocks {DummyClk}] [get_ports {RstN_RstIn Uart_DatIn}]

set_output_delay -min 15.000 -clock [get_clocks {DummyClk}] [get_ports {Uart_DatOut Led_DatOut*}]
set_output_delay -max 0.000 -clock [get_clocks {DummyClk}] [get_ports {Uart_DatOut Led_DatOut*}]
   