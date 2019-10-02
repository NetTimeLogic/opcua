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

#include "iicNs.h"

#define THREAD_STACKSIZE 102400
//#define THREAD_STACKSIZE 16384

int main_thread();


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

UA_NodeId connectionIdent, publishedDataSetIdent, writerGroupIdent;

static void
addPubSubConnection(UA_Server *server, UA_String *transportProfile,
                    UA_NetworkAddressUrlDataType *networkAddressUrl){
    /* Details about the connection configuration and handling are located
     * in the pubsub connection tutorial */
    UA_PubSubConnectionConfig connectionConfig;
    memset(&connectionConfig, 0, sizeof(connectionConfig));
    connectionConfig.name = UA_STRING("UADP Connection 1");
    connectionConfig.transportProfileUri = *transportProfile;
    connectionConfig.enabled = UA_TRUE;

    UA_Variant_setScalar(&connectionConfig.address, networkAddressUrl,
                         &UA_TYPES[UA_TYPES_NETWORKADDRESSURLDATATYPE]);
    /* Changed to static publisherId from random generation to identify
     * the publisher on Subscriber side */
    connectionConfig.publisherId.numeric= 1;
    UA_Server_addPubSubConnection(server, &connectionConfig, &connectionIdent);
}

/**
 * **PublishedDataSet handling**
 *
 * The PublishedDataSet (PDS) and PubSubConnection are the toplevel entities and
 * can exist alone. The PDS contains the collection of the published fields. All
 * other PubSub elements are directly or indirectly linked with the PDS or
 * connection. */
static void
addPublishedDataSet(UA_Server *server) {
    /* The PublishedDataSetConfig contains all necessary public
    * informations for the creation of a new PublishedDataSet */
    UA_PublishedDataSetConfig publishedDataSetConfig;
    memset(&publishedDataSetConfig, 0, sizeof(UA_PublishedDataSetConfig));
    publishedDataSetConfig.publishedDataSetType = UA_PUBSUB_DATASET_PUBLISHEDITEMS;
    publishedDataSetConfig.name = UA_STRING("iic TSN test");
    UA_Server_addPublishedDataSet(server, &publishedDataSetConfig, &publishedDataSetIdent);
}

/**
 * **DataSetField handling**
 *
 * The DataSetField (DSF) is part of the PDS and describes exactly one published
 * field. */
static void
addDataSetField(UA_Server *server, int nsIndex, int nsId, char* fieldNameAlias) {
    /* Add a field to the previous created PublishedDataSet */
    UA_NodeId dataSetFieldIdent;
    UA_DataSetFieldConfig dataSetFieldConfig;
    memset(&dataSetFieldConfig, 0, sizeof(UA_DataSetFieldConfig));
    dataSetFieldConfig.dataSetFieldType = UA_PUBSUB_DATASETFIELD_VARIABLE;
    dataSetFieldConfig.field.variable.fieldNameAlias = UA_STRING(fieldNameAlias);
    dataSetFieldConfig.field.variable.promotedField = UA_FALSE;
    dataSetFieldConfig.field.variable.publishParameters.publishedVariable = UA_NODEID_NUMERIC(nsIndex, nsId);
    dataSetFieldConfig.field.variable.publishParameters.attributeId = UA_ATTRIBUTEID_VALUE;

    UA_Server_addDataSetField(server, publishedDataSetIdent,
                              &dataSetFieldConfig, &dataSetFieldIdent);
}

/**
 * **WriterGroup handling**
 *
 * The WriterGroup (WG) is part of the connection and contains the primary
 * configuration parameters for the message creation. */
static void
addWriterGroup(UA_Server *server) {
    /* Now we create a new WriterGroupConfig and add the group to the existing
     * PubSubConnection. */
    UA_WriterGroupConfig writerGroupConfig;
    memset(&writerGroupConfig, 0, sizeof(UA_WriterGroupConfig));
    writerGroupConfig.name = UA_STRING("iic TSN WriterGroup");
    writerGroupConfig.publishingInterval = 5000;
    writerGroupConfig.enabled = UA_FALSE;
    writerGroupConfig.writerGroupId = 1;            //0x100
    writerGroupConfig.encodingMimeType = UA_PUBSUB_ENCODING_UADP;


    /* The configuration flags for the messages are encapsulated inside the
     * message- and transport settings extension objects. These extension
     * objects are defined by the standard. e.g.
     * UadpWriterGroupMessageDataType */
    UA_UadpWriterGroupMessageDataType *writerGroupMessage  = UA_UadpWriterGroupMessageDataType_new();
    UA_UadpWriterGroupMessageDataType_init(writerGroupMessage);

    /* Change message settings of writerGroup to send PublisherId,
     * WriterGroupId in GroupHeader and DataSetWriterId in PayloadHeader
     * of NetworkMessage */
    writerGroupMessage->networkMessageContentMask          = (UA_UADPNETWORKMESSAGECONTENTMASK_PUBLISHERID |
                                                              UA_UADPNETWORKMESSAGECONTENTMASK_GROUPHEADER |
                                                              UA_UADPNETWORKMESSAGECONTENTMASK_WRITERGROUPID |
                                                              UA_UADPNETWORKMESSAGECONTENTMASK_GROUPVERSION |
                                                              UA_UADPNETWORKMESSAGECONTENTMASK_NETWORKMESSAGENUMBER |
                                                              UA_UADPNETWORKMESSAGECONTENTMASK_SEQUENCENUMBER |
                                                              UA_UADPNETWORKMESSAGECONTENTMASK_PAYLOADHEADER |
                                                              UA_UADPNETWORKMESSAGECONTENTMASK_TIMESTAMP);

    /*
    UA_UADPNETWORKMESSAGECONTENTMASK_NONE = 0,
    UA_UADPNETWORKMESSAGECONTENTMASK_PUBLISHERID = 1,
    UA_UADPNETWORKMESSAGECONTENTMASK_GROUPHEADER = 2,
    UA_UADPNETWORKMESSAGECONTENTMASK_WRITERGROUPID = 4,
    UA_UADPNETWORKMESSAGECONTENTMASK_GROUPVERSION = 8,
    UA_UADPNETWORKMESSAGECONTENTMASK_NETWORKMESSAGENUMBER = 16,
    UA_UADPNETWORKMESSAGECONTENTMASK_SEQUENCENUMBER = 32,
    UA_UADPNETWORKMESSAGECONTENTMASK_PAYLOADHEADER = 64,
    UA_UADPNETWORKMESSAGECONTENTMASK_TIMESTAMP = 128,
    UA_UADPNETWORKMESSAGECONTENTMASK_PICOSECONDS = 256,
    UA_UADPNETWORKMESSAGECONTENTMASK_DATASETCLASSID = 512,
    UA_UADPNETWORKMESSAGECONTENTMASK_PROMOTEDFIELDS = 1024,
    */

    writerGroupMessage->groupVersion = 569608500;   // 0x21F38934 (34 89 F3 21 in little endian)
    writerGroupMessage->dataSetOrdering = UA_DATASETORDERINGTYPE_ASCENDINGWRITERID;

    writerGroupConfig.messageSettings.encoding             = UA_EXTENSIONOBJECT_DECODED;
    writerGroupConfig.messageSettings.content.decoded.type = &UA_TYPES[UA_TYPES_UADPWRITERGROUPMESSAGEDATATYPE];

    writerGroupConfig.messageSettings.content.decoded.data = writerGroupMessage;
    UA_Server_addWriterGroup(server, connectionIdent, &writerGroupConfig, &writerGroupIdent);
    UA_UadpWriterGroupMessageDataType_delete(writerGroupMessage);
}

/**
 * **DataSetWriter handling**
 *
 * A DataSetWriter (DSW) is the glue between the WG and the PDS. The DSW is
 * linked to exactly one PDS and contains additional informations for the
 * message generation. */
static void
addDataSetWriter(UA_Server *server) {
    /* We need now a DataSetWriter within the WriterGroup. This means we must
     * create a new DataSetWriterConfig and add call the addWriterGroup function. */
    UA_NodeId dataSetWriterIdent;
    UA_DataSetWriterConfig dataSetWriterConfig;
    memset(&dataSetWriterConfig, 0, sizeof(UA_DataSetWriterConfig));
    dataSetWriterConfig.name = UA_STRING("iic TSN DataSetWriter");
    dataSetWriterConfig.dataSetWriterId = 0;
    dataSetWriterConfig.keyFrameCount = 1;
    dataSetWriterConfig.messageSettings.encoding = UA_EXTENSIONOBJECT_DECODED;
    dataSetWriterConfig.messageSettings.content.decoded.type = &UA_TYPES[UA_TYPES_UADPDATASETWRITERMESSAGEDATATYPE];

   UA_UadpDataSetWriterMessageDataType *dataSetWriterMessage = UA_UadpDataSetWriterMessageDataType_new();
   UA_UadpDataSetWriterMessageDataType_init(dataSetWriterMessage);

   dataSetWriterMessage->dataSetMessageContentMask = UA_UADPDATASETMESSAGECONTENTMASK_NONE;
		    /*UA_UADPDATASETMESSAGECONTENTMASK_NONE = 0,
		    UA_UADPDATASETMESSAGECONTENTMASK_TIMESTAMP = 1,
		    UA_UADPDATASETMESSAGECONTENTMASK_PICOSECONDS = 2,
		    UA_UADPDATASETMESSAGECONTENTMASK_STATUS = 4,
		    UA_UADPDATASETMESSAGECONTENTMASK_MAJORVERSION = 8,
		    UA_UADPDATASETMESSAGECONTENTMASK_MINORVERSION = 16,
		    UA_UADPDATASETMESSAGECONTENTMASK_SEQUENCENUMBER = 32,*/

   dataSetWriterConfig.dataSetFieldContentMask = UA_DATASETFIELDCONTENTMASK_NONE;
    	   /* UA_DATASETFIELDCONTENTMASK_NONE = 0,
    	    UA_DATASETFIELDCONTENTMASK_STATUSCODE = 1,
    	    UA_DATASETFIELDCONTENTMASK_SOURCETIMESTAMP = 2,
    	    UA_DATASETFIELDCONTENTMASK_SERVERTIMESTAMP = 4,
    	    UA_DATASETFIELDCONTENTMASK_SOURCEPICOSECONDS = 8,
    	    UA_DATASETFIELDCONTENTMASK_SERVERPICOSECONDS = 16,
    	    UA_DATASETFIELDCONTENTMASK_RAWDATA = 32,		*/

    dataSetWriterConfig.messageSettings.content.decoded.data = dataSetWriterMessage;

    UA_Server_addDataSetWriter(server, writerGroupIdent, publishedDataSetIdent,
                               &dataSetWriterConfig, &dataSetWriterIdent);

    UA_UadpDataSetWriterMessageDataType_delete(dataSetWriterMessage);
}

static int opcua_pubsub() {

    UA_Boolean running = true;

    UA_String transportProfile = UA_STRING("http://opcfoundation.org/UA-Profile/Transport/pubsub-udp-uadp");
    UA_NetworkAddressUrlDataType networkAddressUrl = {UA_STRING_NULL , UA_STRING("opc.udp://224.0.0.22:4840/")};

    xil_printf("--------- Init OPC UA Server (pub/sub) ---------\r\n");

    //UA_String transportProfile = UA_STRING("http://opcfoundation.org/UA-Profile/Transport/pubsub-eth-uadp");
    //UA_NetworkAddressUrlDataType networkAddressUrl = {UA_STRING_NULL , UA_STRING("opc.eth://192.168.1.10:4840/")};


    UA_Server *server = UA_Server_new();
    xil_printf("--------- Get Server Config---------\r\n");
    UA_ServerConfig *config = UA_Server_getConfig(server);
    xil_printf("--------- Set Server Config ---------\r\n");
    UA_ServerConfig_setDefault(config);

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


    xil_printf("--------- Calloc PubSubConnection ---------\r\n");
    /* Details about the connection configuration and handling are located in
     * the pubsub connection tutorial */
    config->pubsubTransportLayers = (UA_PubSubTransportLayer *) UA_calloc(2, sizeof(UA_PubSubTransportLayer));
    if(!config->pubsubTransportLayers) {
        UA_Server_delete(server);
        return EXIT_FAILURE;
    }
    config->pubsubTransportLayers[0] = UA_PubSubTransportLayerUDPMP();
    config->pubsubTransportLayersSize++;

    //config->pubsubTransportLayers[1] = UA_PubSubTransportLayerEthernet();
    //config->pubsubTransportLayersSize++;


    UA_StatusCode retval;
    /* create nodes from nodeset */
    if (iicNs(server) != UA_STATUSCODE_GOOD) {
            UA_LOG_ERROR(UA_Log_Stdout, UA_LOGCATEGORY_SERVER, "Could not add the example nodeset. "
               "Check previous output for any error.");
           retval = UA_STATUSCODE_BADUNEXPECTEDERROR;
       } else {


           xil_printf("--------- Add PubSubConnection ---------\r\n");
           addPubSubConnection(server, &transportProfile, &networkAddressUrl);
           xil_printf("--------- Publish PubSubConnection ---------\r\n");
           addPublishedDataSet(server);
           xil_printf("--------- Data set field PubSubConnection  ---------\r\n");


           UA_Variant myVar;
           UA_Variant_init(&myVar);
           // Create DS fields
           // 32 Byte (ByteString size 32)
           addDataSetField(server, 2, 6046, "ApplicationSpecificData");
           UA_NodeId myNodeId = UA_NODEID_NUMERIC(2, 6046);

           UA_ByteString AppDataByteString[1];
           AppDataByteString[0] = UA_STRING("TSN ApplicationSpecificData 32xB");
           UA_Variant_setArray(&myVar, &AppDataByteString, (UA_Int32) 1, &UA_TYPES[UA_TYPES_BYTESTRING]);


           UA_Server_writeValue(server, myNodeId, myVar);
           UA_StatusCode retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing ApplicationSpecificData returned statuscode %s\n", UA_StatusCode_name(retval));

           // Byte
           addDataSetField(server, 2, 6044, "ApplicationId");
           myNodeId = UA_NODEID_NUMERIC(2, 6044);
           UA_Byte byteValue = 0x4;
           UA_Variant_init(&myVar);
           UA_Variant_setScalar(&myVar, &byteValue, &UA_TYPES[UA_TYPES_BYTE]);
           UA_Server_writeValue(server, myNodeId, myVar);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing ApplicationId returned statuscode %s\n", UA_StatusCode_name(retval));

           // Byte
           addDataSetField(server, 2, 6054, "AS_GrandmasterChanges");
           myNodeId = UA_NODEID_NUMERIC(2, 6054);
           byteValue = 0x5;
           UA_Variant_init(&myVar);
           UA_Variant_setScalar(&myVar, &byteValue, &UA_TYPES[UA_TYPES_BYTE]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing AS_GrandmasterChanges returned statuscode %s\n", UA_StatusCode_name(retval));;

           // int32
           addDataSetField(server, 2, 6074, "As_TimeOffset");
           myNodeId = UA_NODEID_NUMERIC(2, 6074);
           UA_Int32 int32Value = 0x1000;
           UA_Variant_init(&myVar);
           UA_Variant_setScalar(&myVar, &int32Value, &UA_TYPES[UA_TYPES_INT32]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing As_TimeOffset returned statuscode %s\n", UA_StatusCode_name(retval));

           // ByteString (8 Bytes)
           addDataSetField(server, 2, 6055, "As_GrandmasterId");
           myNodeId = UA_NODEID_NUMERIC(2, 6055);
           UA_ByteString GmIdByteString[1];
           GmIdByteString[0] = UA_STRING("12345678");
           UA_Variant_setArray(&myVar, &GmIdByteString, (UA_Int32) 1, &UA_TYPES[UA_TYPES_BYTESTRING]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing As_GrandmasterId returned statuscode %s\n", UA_StatusCode_name(retval));

           // Byte
           addDataSetField(server, 2, 6073, "As_State");
           myNodeId = UA_NODEID_NUMERIC(2, 6073);
           byteValue = 0x0;
           UA_Variant_init(&myVar);
           UA_Variant_setScalar(&myVar, &byteValue, &UA_TYPES[UA_TYPES_BYTE]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing As_State returned statuscode %s\n", UA_StatusCode_name(retval));

           // int64
           addDataSetField(server, 2, 6047, "ApplicationTimeStamp");
           myNodeId = UA_NODEID_NUMERIC(2, 6047);
           UA_UInt64 uint64Value = 0x0;
           UA_Variant_init(&myVar);
           UA_Variant_setScalar(&myVar, &uint64Value, &UA_TYPES[UA_TYPES_UINT64]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing ApplicationTimeStamp returned statuscode %s\n", UA_StatusCode_name(retval));

           // unsigned int16
           addDataSetField(server, 2, 6045, "ApplicationSequenceNr");
           myNodeId = UA_NODEID_NUMERIC(2, 6045);
           UA_UInt16 uint16Value = 0x0;
           UA_Variant_init(&myVar);
           UA_Variant_setScalar(&myVar, &uint16Value, &UA_TYPES[UA_TYPES_UINT16]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing ApplicationSequenceNr returned statuscode %s\n", UA_StatusCode_name(retval));

           // unsigned int64
           addDataSetField(server, 2, 6076, "Tsn_LastTxTimeStamp");
           myNodeId = UA_NODEID_NUMERIC(2, 6076);
           uint64Value = 0x12345;
           UA_Variant_init(&myVar);
           UA_Variant_setScalar(&myVar, &uint64Value, &UA_TYPES[UA_TYPES_UINT64]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing Tsn_LastTxTimeStamp returned statuscode %s\n", UA_StatusCode_name(retval));

           // unsigned int32
           addDataSetField(server, 2, 6075, "ExpectedTxOffset");
           myNodeId = UA_NODEID_NUMERIC(2, 6075);
           UA_UInt32 uint32Value = 0x2000;
           UA_Variant_init(&myVar);
           UA_Variant_setScalar(&myVar, &uint32Value, &UA_TYPES[UA_TYPES_UINT32]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing ExpectedTxOffset returned statuscode %s\n", UA_StatusCode_name(retval));

           // 10 Bytes (String size 10)
           addDataSetField(server, 2, 6048, "DeviceName");
           myNodeId = UA_NODEID_NUMERIC(2, 6048);
           UA_Variant_init(&myVar);

           UA_String DeviceNameString[1];
           DeviceNameString[0] = UA_STRING("Arty A7_-_");
           UA_Variant_setArray(&myVar, &DeviceNameString, (UA_Int32) 1, &UA_TYPES[UA_TYPES_STRING]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing DeviceName returned statuscode %s\n", UA_StatusCode_name(retval));

           // 32 Bytes (String size 32)
           addDataSetField(server, 2, 6053, "VendorName");
           myNodeId = UA_NODEID_NUMERIC(2, 6053);
           UA_Variant_init(&myVar);
           UA_String VendorNameString[1];
           VendorNameString[0] = UA_STRING("NetTimeLogic_GmbH_-_-_-_-_-_-_-_");
           UA_Variant_setArray(&myVar, &VendorNameString, (UA_Int32) 1, &UA_TYPES[UA_TYPES_STRING]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing VendorName returned statuscode %s\n", UA_StatusCode_name(retval));

           // Byte
           addDataSetField(server, 2, 6049, "InteropAppCmd");
           myNodeId = UA_NODEID_NUMERIC(2, 6049);
           byteValue = 0x0;
           UA_Variant_setScalar(&myVar, &byteValue, &UA_TYPES[UA_TYPES_BYTE]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing InteropAppCmd returned statuscode %s\n", UA_StatusCode_name(retval));

           // Byte
           addDataSetField(server, 2, 6050, "InteropAppStatus");
           myNodeId = UA_NODEID_NUMERIC(2, 6050);
           byteValue = 0xC;
           UA_Variant_setScalar(&myVar, &byteValue, &UA_TYPES[UA_TYPES_BYTE]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing InteropAppStatus returned statuscode %s\n", UA_StatusCode_name(retval));

           // Byte
           addDataSetField(server, 2, 6051, "InteropAppVersion");
           myNodeId = UA_NODEID_NUMERIC(2, 6051);
           byteValue = 0xEE;
           UA_Variant_setScalar(&myVar, &byteValue, &UA_TYPES[UA_TYPES_BYTE]);
           retval = UA_Server_writeValue(server, myNodeId, myVar);
           //printf("Writing InteropAppVersion returned statuscode %s\n", UA_StatusCode_name(retval));


           //addDataSetField(server, 2, 6052, "TalkedId");
           //addDataSetField(server, 2, 5012, "GeneralInfo");


           xil_printf("--------- Write Group ---------\r\n");
           addWriterGroup(server);
           addDataSetWriter(server);

           //iicNs(server);


           retval = UA_Server_run(server, &running);
     }





    //retval = UA_Server_run(server, &running);

    UA_Server_delete(server);
    return retval == UA_STATUSCODE_GOOD ? EXIT_SUCCESS : EXIT_FAILURE;
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
    sys_thread_new("opcua_pubsub", opcua_pubsub, NULL,
            THREAD_STACKSIZE,
            DEFAULT_THREAD_PRIO);


    vTaskDelete(NULL);
    return 0;
}
