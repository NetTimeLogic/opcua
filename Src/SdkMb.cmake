set (CMAKE_SYSTEM_NAME "generic")
set (CMAKE_SYSTEM_VERSION 1)

set (CMAKE_MAKE_PROGRAM     "C:/Xilinx/SDK/2019.1/gnuwin/bin/make.exe" CACHE PATH "" FORCE)
set (CMAKE_C_COMPILER       "C:/Xilinx/SDK/2019.1/gnu/microblaze/nt/bin/mb-gcc.exe" CACHE PATH "" FORCE)
set (CMAKE_CXX_COMPILER     "C:/Xilinx/SDK/2019.1/gnu/microblaze/nt/bin/mb-g++.exe" CACHE PATH "" FORCE)
set (CMAKE_ASM_COMPILER     "C:/Xilinx/SDK/2019.1/gnu/microblaze/nt/bin/mb-gcc.exe" CACHE PATH "" FORCE)
set (CMAKE_AR               "C:/Xilinx/SDK/2019.1/gnu/microblaze/nt/bin/mb-ar.exe" CACHE FILEPATH "Archiver")

set (UA_ARCHITECTURE "freertosLWIP" CACHE STRING "Architecture to build open62541 on")
set (UA_ENABLE_AMALGAMATION ON CACHE STRING "" FORCE)
set (UA_ENABLE_HARDENING OFF CACHE STRING "" FORCE)

set(UA_ENABLE_PUBSUB ON CACHE STRING "" FORCE)
set(UA_ENBALE_PUBSUB_INFORMATIONMODEL ON CACHE STRING "" FORCE)
# set(UA_NAMESPACE_ZERO FULL)

SET (UA_ARCH_EXTRA_INCLUDES "C:/NetTimeLogic/TimeSync/CLK/Refdesign/Xilinx/Arty/Open62541/MicroblazeArtyA7/MicroblazeArtyA7.sdk/OpcServer_bsp/microblaze_0/include" CACHE STRING "" FORCE)

SET (UA_ARCH_REMOVE_FLAGS "-Wpedantic -Wno-static-in-inline -Wredundant-decls" CACHE STRING "" FORCE)
SET (CMAKE_C_FLAGS "-Wno-error=format= -mlittle-endian -DconfigUSE_PORT_OPTIMISED_TASK_SELECTION=0 -DconfigAPPLICATION_ALLOCATED_HEAP=3 -DUA_ARCHITECTURE_FREERTOSLWIP" CACHE STRING "" FORCE)
