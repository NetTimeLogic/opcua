
/* Standard includes. */
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>




// include LwIP
#include <lwip_main.h>
#include <lwip/dhcp.h>
#include <lwip/sockets.h>
#include <lwip/stats.h>
#include <lwip/ip4_addr.h>
#include <netif/etharp.h>
#include <ping.h>
#include <math.h>

// include low-level network support
#include <triple_speed_ethernet_regs.h>
#include <altera_tse_ethernetif.h>
#include <altera_avalon_tse.h>

#include "system.h"

// include FreeRTOS headers
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

#include <arch/cc.h>

#include "open62541.h"

#define THREAD_STACKSIZE 4096
#define mssleep(x)						vTaskDelay(x)
#define MDIO_IFACE						mdio1

#define LWIP_DEBUG 1


int main_thread();

//  Define netif for lwIP
struct netif eth_tse;

struct ip4_addr lwipStaticIp;
struct ip4_addr PingIp;

static int nw_ready;
static sys_thread_t main_thread_handle;

// hook functions
void vApplicationMallocFailedHook(){
    for(;;){
        vTaskDelay(pdMS_TO_TICKS(1000));
        alt_printf("vApplicationMallocFailedHook \r\n");
    }
}

void vApplicationStackOverflowHook( TaskHandle_t xTask, char *pcTaskName ){
    for(;;){
        vTaskDelay(pdMS_TO_TICKS(1000));
        alt_printf("vApplicationStackOverflowHook \r\n");
    }
}

// callback function for when the DHCP subsystem acquires an IP address.
static void StatusCallback(struct netif* netif)
{
	// get IP and stuff
	printf("[ethernet] Acquired IP address via DHCP client for interface: %s\n", netif->name);

	char buf[255];

	print_ipad(netif->ip_addr.addr, buf);
	printf("[ethernet] IP address : %s\n", buf);

	print_ipad(netif->netmask.addr, buf);
	printf("[ethernet] Subnet     : %s\n", buf);

    print_ipad(netif->gw.addr, buf);
	printf("[ethernet] Gateway    : %s\n", buf);
}

static void LinkCallback(struct netif* netif)
{
	// link change callback
	// TODO release semaphore
	// TODO switch context

	alt_printf("[ethernet] Link Callback for interface: %s\n", netif->name);
}

int InitNetwork(void)
{
	// register new DHCP "IP attained" callback function.
	// if DHCP is acquired, ws_ipset will be called instead of dhc_main_ipset().
	lwip_set_status_callback(StatusCallback);
	lwip_set_link_callback(LinkCallback);

	// Initialize LwIP TCP/IP stack.
	// This function is blocking till the the interface is up.
	lwip_initialize(1);

	return EXIT_SUCCESS;
}

static int WaitOnPHY(void)
{
	int phyadd;
	int phyid;
	int phyid2 = 0;

	np_tse_mac* pmac;
	bool bInitialized = false;

	while (!bInitialized) {
		alt_printf("[ethernet] PHY INFO: Interface: %d Waiting for PHY\n", 0);

		// initialize the structure necessary for "pmac" to function.
		pmac = (np_tse_mac*)TSE_MAC_0_BASE;


		for (phyadd = 0x00; phyadd < 0xff; phyadd++) {
			IOWR(&pmac->MDIO_ADDR0, 0, phyadd);

			phyid = IORD(&pmac->MDIO_IFACE.PHY_ID1, 0);
			phyid2 = IORD(&pmac->MDIO_IFACE.PHY_ID2, 0);

			if (phyid != phyid2) {
				alt_printf("[ethernet] PHY INFO: [PHY ID] 0x%x %x %x\n", phyadd, phyid, phyid2);
				phyadd = 0xff;
			}
		}

		if ((phyadd == 0xff) && (phyid == phyid2)) {
			alt_printf("[ethernet] PHY INFO: No PHY found... restart detect\n");
			bInitialized = true;
			mssleep(1000);
		}
		else
			bInitialized = true;
	}

	// issue a PHY reset.
	IOWR(&pmac->MDIO_IFACE.CONTROL, 0, PCS_CTL_an_enable | PCS_CTL_sw_reset);
	if (((IORD(&pmac->MDIO_IFACE.CONTROL, 0) & PCS_CTL_rx_slpbk) != 0) || ((IORD(&pmac->MDIO_IFACE.STATUS, 0) & PCS_ST_an_done) == 0)) {
		IOWR(&pmac->MDIO_IFACE.CONTROL, 0, PCS_CTL_an_enable | PCS_CTL_sw_reset);
		alt_printf("[ethernet] PHY INFO: Issuing PHY Reset\n");
	}

	// holding pattern until autonegotiation completes.
	if ((IORD(&pmac->MDIO_IFACE.STATUS, 0) & PCS_ST_an_done) == 0) {
		alt_printf("[ethernet] PHY INFO: Waiting on PHY link...\n");

		while ((IORD(&pmac->MDIO_IFACE.STATUS, 0) & PCS_ST_an_done) == 0)
			mssleep(10);

		alt_printf("[ethernet] PHY INFO: PHY link detected, allowing network to start.\n");
		
		mssleep(1000);
	}

	mssleep(10);

	return 0;
}


void xEthernetRun()
{
    alt_printf("--------- Init Network ---------\r\n");

	// initialize PHY
	WaitOnPHY();

	if (InitNetwork() != EXIT_SUCCESS) {
		// the network initialization has failed.
		alt_printf("[ethernet] Network initialize failed!\n");
	}

    nw_ready = 1;
	alt_printf("--------- Init Done ---------\r\n");


    // starting the network thread
    /*sys_thread_new("ping", PingThread, NULL,
    		THREAD_STACKSIZE,
            DEFAULT_THREAD_PRIO);*/

	struct netif* ethif;
	ethif = get_netif(0);

	IP4_ADDR(&PingIp, 192, 168, 1, 100);
	while(1) {

        //lwip_ping_target(PingIp.addr, 1, 0, 100);
		// sleep for 1 second
		//lwip_ping_target(PingIp.addr, 10, 0, 100);
        ethernetif_input(ethif);
        vTaskDelay(10);
	}


    //vTaskDelete(NULL);
}

// callback wrapper for lwip to get the interface configurations
int get_mac_addr(int iface, struct netif* ethif, unsigned char mac_addr[6])
{
	mac_addr[0] = 0x12;
	mac_addr[1] = 0x23;
	mac_addr[2] = 0x45;
	mac_addr[3] = 0xFF;
	mac_addr[4] = 0xFF;
	mac_addr[5] = 0xF0 + iface;

	// only show info if net is not NULL
	if (ethif)
		printf("[ethernet] Using Ethernet MAC address %02x:%02x:%02x:%02x:%02x:%02x for interface: %d\n",
				mac_addr[0], mac_addr[1], mac_addr[2], mac_addr[3], mac_addr[4], mac_addr[5], iface);

	return EXIT_SUCCESS;
}

// callback wrapper for lwip to get the IP configurations
int get_ip_addr(int iface, ip_addr_t* ipaddr, ip_addr_t* netmask, ip_addr_t* gw, int* use_dhcp)
{
	// set configuration
	IP4_ADDR(ipaddr, 192, 168, 1, 218);
	IP4_ADDR(netmask, 255, 255, 255, 0);
	IP4_ADDR(gw, 192, 168, 1, 1);
	*use_dhcp = 0;

	if (*use_dhcp == 0){
		char buf[255];
		print_ipad(ipaddr->addr, buf);
		printf("[ethernet] Static IP Address for interface %d %s\n", iface, buf);
	}
	else
		printf("[ethernet] Starting get IP via DHCP for interface %d\n", iface);

	return EXIT_SUCCESS;
}

int get_hostname(int iface, const char **hostname)
{
	*hostname = "LwIP";

	return ERR_OK;
}

int get_iface_name(int iface, char name[ETH_IFACE_NAME_LENGTH])
{
	name[0] = 'e';
	name[1] = (iface + 0x30);

	return ERR_OK;
}

int is_interface_active(int iface)
{
	return 1;
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

static void opcua_thread(void *arg) {

    UA_Boolean running = true;

    printf("--------- Init OPC UA Server ---------\r\n");

    UA_Server *server = UA_Server_new();
    UA_ServerConfig *config = UA_Server_getConfig(server);
    UA_ServerConfig_setDefault(UA_Server_getConfig(server));

    // Server buffer size config
    config->networkLayers->localConnectionConfig.recvBufferSize = 32768;
    config->networkLayers->localConnectionConfig.sendBufferSize = 32768;

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
    //addVariableCallback(server);

    printf("---------Starting UA Server ---------\r\n");
    UA_StatusCode retval = UA_Server_run(server, &running);
    printf("--------- Stopping UA Server---------\r\n");

    UA_Server_delete(server);
    vTaskDelete(NULL);
}



int main_thread(){
	alt_printf("------------------------------------------------------\r\n");
	alt_printf("--------- Starting OPC UA Server application ---------\r\n");
	alt_printf("------------------------------------------------------\r\n");
	alt_printf("--------- open62541 example created for a    ---------\r\n");
    alt_printf("--------- MicroBlaze design on a Artix7 FPGA ---------\r\n");
    alt_printf("------------------------------------------------------\r\n");
    alt_printf("--------- NetTImeLogic GmbH, Switzerland     ---------\r\n");
    alt_printf("--------- contact@nettimelogic.com           ---------\r\n");
    alt_printf("------------------------------------------------------\r\n");

	//xTaskCreate(xEthernetRun, "eth0", KB(4), NULL, tskIDLE_PRIORITY + 2, NULL);

	sys_thread_new("NetworkInit", xEthernetRun, NULL,
    		THREAD_STACKSIZE,
            DEFAULT_THREAD_PRIO);

    // starting OPC UA thread
    sys_thread_new("opcua_thread", opcua_thread, NULL,
            THREAD_STACKSIZE,
            DEFAULT_THREAD_PRIO);

    //vTaskStartScheduler();
    while(1);
    return 0;
}

