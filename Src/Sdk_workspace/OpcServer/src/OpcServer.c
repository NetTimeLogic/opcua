/*
 * OpcServer.c
 *
 *  Created on: 30.08.2019
 *  Author:     NetTimeLogic GmbH
 */

#include <signal.h>
#include <stdlib.h>

#include <open62541.h>

#include "xparameters.h"
#include "netif/xadapter.h"
#include "xil_printf.h"

#include "xgpio.h"

#define THREAD_STACKSIZE 4096

int main_thread();

static volatile UA_Boolean running = true;
static struct netif server_netif;

static int nw_ready;
static sys_thread_t main_thread_handle;

XGpio Gpio;

// hook functions
void vApplicationMallocFailedHook(){
    for(;;){
        vTaskDelay(pdMS_TO_TICKS(1000));
        xil_printf("vApplicationMallocFailedHook \r\n");
    }
}

void vApplicationStackOverflowHook( TaskHandle_t xTask, char *pcTaskName ){
    for(;;){
        vTaskDelay(pdMS_TO_TICKS(1000));
        xil_printf("vApplicationStackOverflowHook \r\n");
    }
}

int main(){
    main_thread_handle = sys_thread_new("main_thrd", (void(*)(void*))main_thread, 0,
                    THREAD_STACKSIZE,
                    DEFAULT_THREAD_PRIO);
    vTaskStartScheduler();
    while(1);
    return 0;
}

static void addObject(UA_Server *server) {
    UA_NodeId NetTimeLogicId = UA_NODEID_STRING(1, "NetTimeLogic");
    UA_ObjectAttributes oAttr = UA_ObjectAttributes_default;
    oAttr.displayName = UA_LOCALIZEDTEXT("en-US", "NetTimeLogic GmbH");
    UA_Server_addObjectNode(server, UA_NODEID_NULL,
                            UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
                            UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
                            UA_QUALIFIEDNAME(1, "NetTimeLogic"), 
                            UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE),
                            oAttr, NULL, &NetTimeLogicId);
}

static void addVariable(UA_Server *server) {
    UA_Boolean ledValue = false;

    UA_VariableAttributes vAttr = UA_VariableAttributes_default;
    vAttr.description = UA_LOCALIZEDTEXT("en_US","LED on/off");
    vAttr.displayName = UA_LOCALIZEDTEXT("en_US","LED");
    vAttr.accessLevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE;

    UA_Variant_setScalar(&vAttr.value, &ledValue, &UA_TYPES[UA_TYPES_BOOLEAN]);

    UA_NodeId currentNodeId  = UA_NODEID_STRING(1, "LedNode");
    UA_Server_addVariableNode(server, currentNodeId, 
                            UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
                            UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES), 
                            UA_QUALIFIEDNAME(1, "LedNode"),
                            UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE), 
                            vAttr, NULL, NULL);

}

static void readValue(UA_Server *server, const UA_NodeId *sessionId, void *sessionContext,
               const UA_NodeId *nodeid, void *nodeContext, const UA_NumericRange *range, const UA_DataValue *data) {
    // Do something
    // xil_printf("--------- Client read value ---------\r\n");
}

static void writeValue(UA_Server *server, const UA_NodeId *sessionId, void *sessionContext,
                    const UA_NodeId *nodeId, void *nodeContext,const UA_NumericRange *range, const UA_DataValue *data) {

    UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_USERLAND, "The variable was updated");

    // Get the value after write
    UA_Boolean ledValue = *(UA_Boolean *)data->value.data;

    // Switch on/off LEDs
    if (ledValue == true) {
        XGpio_DiscreteWrite(&Gpio, 1, 0x0F);
    }
    else {
        XGpio_DiscreteClear(&Gpio, 1, 0x0F);
    }

}

static void addVariableCallback(UA_Server *server) {
    UA_NodeId currentNodeId = UA_NODEID_STRING(1, "LedNode");
    UA_ValueCallback callback ;
    callback.onRead = readValue;
    callback.onWrite = writeValue;
    UA_Server_setVariableNode_valueCallback(server, currentNodeId, callback);
}

static void opcua_thread(void *arg) {

    UA_Boolean running = true;

    xil_printf("--------- Init OPC UA Server ---------\r\n");

    UA_Server *server = UA_Server_new();
    UA_ServerConfig *config = UA_Server_getConfig(server);
    UA_ServerConfig_setDefault(UA_Server_getConfig(server));

    // Server buffer size config
    config->networkLayers->localConnectionConfig.recvBufferSize = 32768;
    config->networkLayers->localConnectionConfig.sendBufferSize = 32768;
    config->networkLayers->localConnectionConfig.maxMessageSize = 32768;

    // Discovery/Url config
    UA_String UaUrl = UA_String_fromChars("opc.tcp://192.168.1.10:4840");
    config->networkLayers[0].discoveryUrl = UA_STRING("opc.tcp://192.168.1.10:4840");

    config->applicationDescription.discoveryUrls = &UaUrl;
    config->applicationDescription.discoveryUrlsSize = 1;
    config->applicationDescription.applicationUri = UA_STRING("192.168.1.10");
    config->applicationDescription.applicationName = UA_LOCALIZEDTEXT("en-US", "NetTimeLogic");
    config->applicationDescription.applicationType = UA_APPLICATIONTYPE_SERVER;

    UA_ServerConfig_setCustomHostname(config, UA_STRING("192.168.1.10"));

    // Define object and variables
    addObject(server);
    addVariable(server);
    addVariableCallback(server);

    xil_printf("---------Starting UA Server ---------\r\n");
    UA_StatusCode retval = UA_Server_run(server, &running);
    xil_printf("--------- Stopping UA Server---------\r\n");

    UA_Server_delete(server);
    vTaskDelete(NULL);
}

static void network_thread(void *arg) {

    xil_printf("\r\n\r\n");

    xil_printf("--------- Init Network ---------\r\n");
    struct netif *netif;

    netif = &server_netif;

    // Configure MAC address
    unsigned char mac_ethernet_address[] = { 0x00, 0x0a, 0x35, 0x00, 0x12, 0x34 };
    ip_addr_t ipaddr, netmask, gw;

    // Configure IP
    IP4_ADDR(&ipaddr,  192, 168, 1, 10);
    IP4_ADDR(&netmask, 255, 255, 255,  0);
    IP4_ADDR(&gw,      192, 168, 1, 1);

    // Add network interface to the netif_list
    if (!xemac_add(netif, &ipaddr, &netmask, &gw, mac_ethernet_address, XPAR_AXI_ETHERNETLITE_0_BASEADDR)) {
        xil_printf("Error adding N/W interface\r\n");
    }

    netif_set_default(netif);
    // specify that the network if is up
    netif_set_up(netif);

    // start packet receive thread - required for lwIP operation
    sys_thread_new("xemacif_input_thread", (void(*)(void*))xemacif_input_thread, netif,
            THREAD_STACKSIZE,
            DEFAULT_THREAD_PRIO);

    nw_ready = 1;

    vTaskResume(main_thread_handle);
    vTaskDelete(NULL);
}

int main_thread(){
    xil_printf("------------------------------------------------------\r\n");
    xil_printf("--------- Starting OPC UA Server application ---------\r\n");
    xil_printf("------------------------------------------------------\r\n");
    xil_printf("--------- open62541 example created for a    ---------\r\n");
    xil_printf("--------- MicroBlaze design on a Artix7 FPGA ---------\r\n");
    xil_printf("------------------------------------------------------\r\n");
    xil_printf("--------- NetTImeLogic GmbH, Switzerland     ---------\r\n");
    xil_printf("--------- contact@nettimelogic.com           ---------\r\n");
    xil_printf("------------------------------------------------------\r\n");

    // initialize GPIO
    XGpio_Initialize(&Gpio, XPAR_GPIO_0_DEVICE_ID);
    XGpio_SetDataDirection(&Gpio, 1, ~0x0F);
    XGpio_DiscreteClear(&Gpio, 1, 0x0F);

    // initialize lwIP first
    lwip_init();

    // starting the network thread
    sys_thread_new("nw_thread", network_thread, NULL,
            THREAD_STACKSIZE,
            DEFAULT_THREAD_PRIO);


    // suspend until auto negotiation is done
    if (!nw_ready)
        vTaskSuspend(NULL);

    xil_printf("auto negotiation done\r\n");

    // starting OPC UA thread
    sys_thread_new("opcua_thread", opcua_thread, NULL,
            THREAD_STACKSIZE,
            DEFAULT_THREAD_PRIO);

    vTaskDelete(NULL);
    return 0;
}
