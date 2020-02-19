#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Clock
#**************************************************************

derive_pll_clocks -create_base_clocks
derive_clock_uncertainty



#**************************************************************
# RAM
#**************************************************************


#**************************************************************
# Port1
#**************************************************************

# Port2
#**************************************************************


#**************************************************************
# General
#**************************************************************
set_input_delay -min 0.000 -clock [get_clocks {DummyClk}] [get_ports {RstN_RstIn Uart_DatIn}]
set_input_delay -max 5.000 -clock [get_clocks {DummyClk}] [get_ports {RstN_RstIn Uart_DatIn}]

#set_output_delay -min 15.000 -clock [get_clocks {DummyClk}] [get_ports {Pps_EvtOut Uart_DatOut Led_DatOut*}]
#set_output_delay -max 0.000 -clock [get_clocks {DummyClk}] [get_ports {Pps_EvtOut Uart_DatOut Led_DatOut*}]
   