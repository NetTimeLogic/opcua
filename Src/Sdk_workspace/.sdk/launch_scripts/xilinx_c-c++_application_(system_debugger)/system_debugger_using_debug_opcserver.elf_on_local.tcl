connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Arty A7-100T 210319A8C6C7A" && level==0} -index 0
fpga -file C:/opcua/Src/Sdk_workspace/MicroblazeBd_wrapper_hw_platform_0/MicroblazeBd_wrapper.bit
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Arty A7-100T 210319A8C6C7A"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Arty A7-100T 210319A8C6C7A"} -index 0
dow C:/opcua/Src/Sdk_workspace/OpcServer/Debug/OpcServer.elf
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Arty A7-100T 210319A8C6C7A"} -index 0
con
