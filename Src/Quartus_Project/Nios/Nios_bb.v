
module Nios (
	clk_clk,
	clk_sdram_clk,
	irq_bridge_0_receiver_irq_irq,
	locked_export,
	m_axi_ext_awaddr,
	m_axi_ext_awprot,
	m_axi_ext_awvalid,
	m_axi_ext_awready,
	m_axi_ext_wdata,
	m_axi_ext_wstrb,
	m_axi_ext_wlast,
	m_axi_ext_wvalid,
	m_axi_ext_wready,
	m_axi_ext_bresp,
	m_axi_ext_bvalid,
	m_axi_ext_bready,
	m_axi_ext_araddr,
	m_axi_ext_arprot,
	m_axi_ext_arvalid,
	m_axi_ext_arready,
	m_axi_ext_rdata,
	m_axi_ext_rresp,
	m_axi_ext_rvalid,
	m_axi_ext_rready,
	reset_reset_n,
	reset_bridge_0_in_reset_reset_n,
	sdram_controller_0_addr,
	sdram_controller_0_ba,
	sdram_controller_0_cas_n,
	sdram_controller_0_cke,
	sdram_controller_0_cs_n,
	sdram_controller_0_dq,
	sdram_controller_0_dqm,
	sdram_controller_0_ras_n,
	sdram_controller_0_we_n,
	sys_clk_clk,
	tse_mac_mac_mdio_connection_mdc,
	tse_mac_mac_mdio_connection_mdio_in,
	tse_mac_mac_mdio_connection_mdio_out,
	tse_mac_mac_mdio_connection_mdio_oen,
	tse_mac_mac_mii_connection_mii_rx_d,
	tse_mac_mac_mii_connection_mii_rx_dv,
	tse_mac_mac_mii_connection_mii_rx_err,
	tse_mac_mac_mii_connection_mii_tx_d,
	tse_mac_mac_mii_connection_mii_tx_en,
	tse_mac_mac_mii_connection_mii_tx_err,
	tse_mac_mac_mii_connection_mii_crs,
	tse_mac_mac_mii_connection_mii_col,
	tse_mac_mac_misc_connection_ff_tx_crc_fwd,
	tse_mac_mac_misc_connection_ff_tx_septy,
	tse_mac_mac_misc_connection_tx_ff_uflow,
	tse_mac_mac_misc_connection_ff_tx_a_full,
	tse_mac_mac_misc_connection_ff_tx_a_empty,
	tse_mac_mac_misc_connection_rx_err_stat,
	tse_mac_mac_misc_connection_rx_frm_type,
	tse_mac_mac_misc_connection_ff_rx_dsav,
	tse_mac_mac_misc_connection_ff_rx_a_full,
	tse_mac_mac_misc_connection_ff_rx_a_empty,
	tse_mac_mac_status_connection_set_10,
	tse_mac_mac_status_connection_set_1000,
	tse_mac_mac_status_connection_eth_mode,
	tse_mac_mac_status_connection_ena_10,
	tse_mac_pcs_mac_rx_clock_connection_clk,
	tse_mac_pcs_mac_tx_clock_connection_clk,
	uart_0_rxd,
	uart_0_txd);	

	input		clk_clk;
	output		clk_sdram_clk;
	input	[1:0]	irq_bridge_0_receiver_irq_irq;
	output		locked_export;
	output	[27:0]	m_axi_ext_awaddr;
	output	[2:0]	m_axi_ext_awprot;
	output		m_axi_ext_awvalid;
	input		m_axi_ext_awready;
	output	[31:0]	m_axi_ext_wdata;
	output	[3:0]	m_axi_ext_wstrb;
	output		m_axi_ext_wlast;
	output		m_axi_ext_wvalid;
	input		m_axi_ext_wready;
	input	[1:0]	m_axi_ext_bresp;
	input		m_axi_ext_bvalid;
	output		m_axi_ext_bready;
	output	[27:0]	m_axi_ext_araddr;
	output	[2:0]	m_axi_ext_arprot;
	output		m_axi_ext_arvalid;
	input		m_axi_ext_arready;
	input	[31:0]	m_axi_ext_rdata;
	input	[1:0]	m_axi_ext_rresp;
	input		m_axi_ext_rvalid;
	output		m_axi_ext_rready;
	input		reset_reset_n;
	input		reset_bridge_0_in_reset_reset_n;
	output	[12:0]	sdram_controller_0_addr;
	output	[1:0]	sdram_controller_0_ba;
	output		sdram_controller_0_cas_n;
	output		sdram_controller_0_cke;
	output		sdram_controller_0_cs_n;
	inout	[15:0]	sdram_controller_0_dq;
	output	[1:0]	sdram_controller_0_dqm;
	output		sdram_controller_0_ras_n;
	output		sdram_controller_0_we_n;
	output		sys_clk_clk;
	output		tse_mac_mac_mdio_connection_mdc;
	input		tse_mac_mac_mdio_connection_mdio_in;
	output		tse_mac_mac_mdio_connection_mdio_out;
	output		tse_mac_mac_mdio_connection_mdio_oen;
	input	[3:0]	tse_mac_mac_mii_connection_mii_rx_d;
	input		tse_mac_mac_mii_connection_mii_rx_dv;
	input		tse_mac_mac_mii_connection_mii_rx_err;
	output	[3:0]	tse_mac_mac_mii_connection_mii_tx_d;
	output		tse_mac_mac_mii_connection_mii_tx_en;
	output		tse_mac_mac_mii_connection_mii_tx_err;
	input		tse_mac_mac_mii_connection_mii_crs;
	input		tse_mac_mac_mii_connection_mii_col;
	input		tse_mac_mac_misc_connection_ff_tx_crc_fwd;
	output		tse_mac_mac_misc_connection_ff_tx_septy;
	output		tse_mac_mac_misc_connection_tx_ff_uflow;
	output		tse_mac_mac_misc_connection_ff_tx_a_full;
	output		tse_mac_mac_misc_connection_ff_tx_a_empty;
	output	[17:0]	tse_mac_mac_misc_connection_rx_err_stat;
	output	[3:0]	tse_mac_mac_misc_connection_rx_frm_type;
	output		tse_mac_mac_misc_connection_ff_rx_dsav;
	output		tse_mac_mac_misc_connection_ff_rx_a_full;
	output		tse_mac_mac_misc_connection_ff_rx_a_empty;
	input		tse_mac_mac_status_connection_set_10;
	input		tse_mac_mac_status_connection_set_1000;
	output		tse_mac_mac_status_connection_eth_mode;
	output		tse_mac_mac_status_connection_ena_10;
	input		tse_mac_pcs_mac_rx_clock_connection_clk;
	input		tse_mac_pcs_mac_tx_clock_connection_clk;
	input		uart_0_rxd;
	output		uart_0_txd;
endmodule
