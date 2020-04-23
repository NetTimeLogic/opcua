set( CMAKE_SYSTEM Altera-Nios2 )
set( CMAKE_SYSTEM_NAME Generic )
set( CMAKE_SYSTEM_PROCESSOR nios2 )
set (CMAKE_SYSTEM_VERSION 1)

set (CMAKE_MAKE_PROGRAM     "C:/Altera/18.1/nios2eds/bin/gnu/H-x86_64-mingw32/bin/make.exe" CACHE PATH "" FORCE)
set (CMAKE_C_COMPILER       "C:/Altera/18.1/nios2eds/bin/gnu/H-x86_64-mingw32/bin/nios2-elf-gcc.exe" CACHE PATH "" FORCE)
set (CMAKE_CXX_COMPILER     "C:/Altera/18.1/nios2eds/bin/gnu/H-x86_64-mingw32/bin/nios2-elf-c++.exe" CACHE PATH "" FORCE)
set (CMAKE_ASM_COMPILER     "C:/Altera/18.1/nios2eds/bin/gnu/H-x86_64-mingw32/bin/nios2-elf-as.exe" CACHE PATH "" FORCE)
set (CMAKE_AR               "C:/Altera/18.1/nios2eds/bin/gnu/H-x86_64-mingw32/bin/nios2-elf-ar.exe" CACHE FILEPATH "Archiver")

set (UA_ARCHITECTURE "freertosLWIP" CACHE STRING "Architecture to build open62541 on")
set (UA_ENABLE_AMALGAMATION ON CACHE STRING "" FORCE)
set (UA_ENABLE_HARDENING OFF CACHE STRING "" FORCE)

set(UA_ENABLE_PUBSUB ON CACHE STRING "" FORCE)
set(UA_ENBALE_PUBSUB_INFORMATIONMODEL ON CACHE STRING "" FORCE)
set(UA_ENBALE_DA OFF CACHE STRING "" FORCE)
# set(UA_NAMESPACE_ZERO FULL)

set (UA_ARCH_EXTRA_INCLUDES "C:/opcua/Src/Quartus_Project/software/FreeRTOS_bsp/;C:/opcua/Src/Quartus_Project/software/FreeRTOS_bsp/HAL/inc/;C:/opcua/Src/Quartus_Project/software/FreeRTOS_bsp/drivers/inc/;C:/opcua/Src/Quartus_Project/software/FreeRTOS_bsp/FreeRTOS/inc/;C:/opcua/Src/Quartus_Project/software/FreeRTOS_bsp/LwIP/inc/;" CACHE STRING "" FORCE)

SET (UA_ARCH_REMOVE_FLAGS "-Wno-static-in-inline -Wredundant-decls" CACHE STRING "" FORCE)
SET (CMAKE_C_FLAGS "-Wno-error=format= -Wfatal-errors -mel -DUA_ARCHITECTURE_FREERTOSLWIP" CACHE STRING "" FORCE)
