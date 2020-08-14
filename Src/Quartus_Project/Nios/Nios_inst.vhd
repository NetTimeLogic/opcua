	component Nios is
		port (
			clk_clk                                   : in    std_logic                     := 'X';             -- clk
			clk_sdram_clk                             : out   std_logic;                                        -- clk
			irq_bridge_0_receiver_irq_irq             : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- irq
			locked_export                             : out   std_logic;                                        -- export
			m_axi_ext_awaddr                          : out   std_logic_vector(27 downto 0);                    -- awaddr
			m_axi_ext_awprot                          : out   std_logic_vector(2 downto 0);                     -- awprot
			m_axi_ext_awvalid                         : out   std_logic;                                        -- awvalid
			m_axi_ext_awready                         : in    std_logic                     := 'X';             -- awready
			m_axi_ext_wdata                           : out   std_logic_vector(31 downto 0);                    -- wdata
			m_axi_ext_wstrb                           : out   std_logic_vector(3 downto 0);                     -- wstrb
			m_axi_ext_wlast                           : out   std_logic;                                        -- wlast
			m_axi_ext_wvalid                          : out   std_logic;                                        -- wvalid
			m_axi_ext_wready                          : in    std_logic                     := 'X';             -- wready
			m_axi_ext_bresp                           : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- bresp
			m_axi_ext_bvalid                          : in    std_logic                     := 'X';             -- bvalid
			m_axi_ext_bready                          : out   std_logic;                                        -- bready
			m_axi_ext_araddr                          : out   std_logic_vector(27 downto 0);                    -- araddr
			m_axi_ext_arprot                          : out   std_logic_vector(2 downto 0);                     -- arprot
			m_axi_ext_arvalid                         : out   std_logic;                                        -- arvalid
			m_axi_ext_arready                         : in    std_logic                     := 'X';             -- arready
			m_axi_ext_rdata                           : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rdata
			m_axi_ext_rresp                           : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rresp
			m_axi_ext_rvalid                          : in    std_logic                     := 'X';             -- rvalid
			m_axi_ext_rready                          : out   std_logic;                                        -- rready
			reset_reset_n                             : in    std_logic                     := 'X';             -- reset_n
			reset_bridge_0_in_reset_reset_n           : in    std_logic                     := 'X';             -- reset_n
			sdram_controller_0_addr                   : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_controller_0_ba                     : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_controller_0_cas_n                  : out   std_logic;                                        -- cas_n
			sdram_controller_0_cke                    : out   std_logic;                                        -- cke
			sdram_controller_0_cs_n                   : out   std_logic;                                        -- cs_n
			sdram_controller_0_dq                     : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_controller_0_dqm                    : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_controller_0_ras_n                  : out   std_logic;                                        -- ras_n
			sdram_controller_0_we_n                   : out   std_logic;                                        -- we_n
			sys_clk_clk                               : out   std_logic;                                        -- clk
			tse_mac_mac_mdio_connection_mdc           : out   std_logic;                                        -- mdc
			tse_mac_mac_mdio_connection_mdio_in       : in    std_logic                     := 'X';             -- mdio_in
			tse_mac_mac_mdio_connection_mdio_out      : out   std_logic;                                        -- mdio_out
			tse_mac_mac_mdio_connection_mdio_oen      : out   std_logic;                                        -- mdio_oen
			tse_mac_mac_mii_connection_mii_rx_d       : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- mii_rx_d
			tse_mac_mac_mii_connection_mii_rx_dv      : in    std_logic                     := 'X';             -- mii_rx_dv
			tse_mac_mac_mii_connection_mii_rx_err     : in    std_logic                     := 'X';             -- mii_rx_err
			tse_mac_mac_mii_connection_mii_tx_d       : out   std_logic_vector(3 downto 0);                     -- mii_tx_d
			tse_mac_mac_mii_connection_mii_tx_en      : out   std_logic;                                        -- mii_tx_en
			tse_mac_mac_mii_connection_mii_tx_err     : out   std_logic;                                        -- mii_tx_err
			tse_mac_mac_mii_connection_mii_crs        : in    std_logic                     := 'X';             -- mii_crs
			tse_mac_mac_mii_connection_mii_col        : in    std_logic                     := 'X';             -- mii_col
			tse_mac_mac_misc_connection_ff_tx_crc_fwd : in    std_logic                     := 'X';             -- ff_tx_crc_fwd
			tse_mac_mac_misc_connection_ff_tx_septy   : out   std_logic;                                        -- ff_tx_septy
			tse_mac_mac_misc_connection_tx_ff_uflow   : out   std_logic;                                        -- tx_ff_uflow
			tse_mac_mac_misc_connection_ff_tx_a_full  : out   std_logic;                                        -- ff_tx_a_full
			tse_mac_mac_misc_connection_ff_tx_a_empty : out   std_logic;                                        -- ff_tx_a_empty
			tse_mac_mac_misc_connection_rx_err_stat   : out   std_logic_vector(17 downto 0);                    -- rx_err_stat
			tse_mac_mac_misc_connection_rx_frm_type   : out   std_logic_vector(3 downto 0);                     -- rx_frm_type
			tse_mac_mac_misc_connection_ff_rx_dsav    : out   std_logic;                                        -- ff_rx_dsav
			tse_mac_mac_misc_connection_ff_rx_a_full  : out   std_logic;                                        -- ff_rx_a_full
			tse_mac_mac_misc_connection_ff_rx_a_empty : out   std_logic;                                        -- ff_rx_a_empty
			tse_mac_mac_status_connection_set_10      : in    std_logic                     := 'X';             -- set_10
			tse_mac_mac_status_connection_set_1000    : in    std_logic                     := 'X';             -- set_1000
			tse_mac_mac_status_connection_eth_mode    : out   std_logic;                                        -- eth_mode
			tse_mac_mac_status_connection_ena_10      : out   std_logic;                                        -- ena_10
			tse_mac_pcs_mac_rx_clock_connection_clk   : in    std_logic                     := 'X';             -- clk
			tse_mac_pcs_mac_tx_clock_connection_clk   : in    std_logic                     := 'X';             -- clk
			uart_0_rxd                                : in    std_logic                     := 'X';             -- rxd
			uart_0_txd                                : out   std_logic                                         -- txd
		);
	end component Nios;

	u0 : component Nios
		port map (
			clk_clk                                   => CONNECTED_TO_clk_clk,                                   --                                 clk.clk
			clk_sdram_clk                             => CONNECTED_TO_clk_sdram_clk,                             --                           clk_sdram.clk
			irq_bridge_0_receiver_irq_irq             => CONNECTED_TO_irq_bridge_0_receiver_irq_irq,             --           irq_bridge_0_receiver_irq.irq
			locked_export                             => CONNECTED_TO_locked_export,                             --                              locked.export
			m_axi_ext_awaddr                          => CONNECTED_TO_m_axi_ext_awaddr,                          --                           m_axi_ext.awaddr
			m_axi_ext_awprot                          => CONNECTED_TO_m_axi_ext_awprot,                          --                                    .awprot
			m_axi_ext_awvalid                         => CONNECTED_TO_m_axi_ext_awvalid,                         --                                    .awvalid
			m_axi_ext_awready                         => CONNECTED_TO_m_axi_ext_awready,                         --                                    .awready
			m_axi_ext_wdata                           => CONNECTED_TO_m_axi_ext_wdata,                           --                                    .wdata
			m_axi_ext_wstrb                           => CONNECTED_TO_m_axi_ext_wstrb,                           --                                    .wstrb
			m_axi_ext_wlast                           => CONNECTED_TO_m_axi_ext_wlast,                           --                                    .wlast
			m_axi_ext_wvalid                          => CONNECTED_TO_m_axi_ext_wvalid,                          --                                    .wvalid
			m_axi_ext_wready                          => CONNECTED_TO_m_axi_ext_wready,                          --                                    .wready
			m_axi_ext_bresp                           => CONNECTED_TO_m_axi_ext_bresp,                           --                                    .bresp
			m_axi_ext_bvalid                          => CONNECTED_TO_m_axi_ext_bvalid,                          --                                    .bvalid
			m_axi_ext_bready                          => CONNECTED_TO_m_axi_ext_bready,                          --                                    .bready
			m_axi_ext_araddr                          => CONNECTED_TO_m_axi_ext_araddr,                          --                                    .araddr
			m_axi_ext_arprot                          => CONNECTED_TO_m_axi_ext_arprot,                          --                                    .arprot
			m_axi_ext_arvalid                         => CONNECTED_TO_m_axi_ext_arvalid,                         --                                    .arvalid
			m_axi_ext_arready                         => CONNECTED_TO_m_axi_ext_arready,                         --                                    .arready
			m_axi_ext_rdata                           => CONNECTED_TO_m_axi_ext_rdata,                           --                                    .rdata
			m_axi_ext_rresp                           => CONNECTED_TO_m_axi_ext_rresp,                           --                                    .rresp
			m_axi_ext_rvalid                          => CONNECTED_TO_m_axi_ext_rvalid,                          --                                    .rvalid
			m_axi_ext_rready                          => CONNECTED_TO_m_axi_ext_rready,                          --                                    .rready
			reset_reset_n                             => CONNECTED_TO_reset_reset_n,                             --                               reset.reset_n
			reset_bridge_0_in_reset_reset_n           => CONNECTED_TO_reset_bridge_0_in_reset_reset_n,           --             reset_bridge_0_in_reset.reset_n
			sdram_controller_0_addr                   => CONNECTED_TO_sdram_controller_0_addr,                   --                  sdram_controller_0.addr
			sdram_controller_0_ba                     => CONNECTED_TO_sdram_controller_0_ba,                     --                                    .ba
			sdram_controller_0_cas_n                  => CONNECTED_TO_sdram_controller_0_cas_n,                  --                                    .cas_n
			sdram_controller_0_cke                    => CONNECTED_TO_sdram_controller_0_cke,                    --                                    .cke
			sdram_controller_0_cs_n                   => CONNECTED_TO_sdram_controller_0_cs_n,                   --                                    .cs_n
			sdram_controller_0_dq                     => CONNECTED_TO_sdram_controller_0_dq,                     --                                    .dq
			sdram_controller_0_dqm                    => CONNECTED_TO_sdram_controller_0_dqm,                    --                                    .dqm
			sdram_controller_0_ras_n                  => CONNECTED_TO_sdram_controller_0_ras_n,                  --                                    .ras_n
			sdram_controller_0_we_n                   => CONNECTED_TO_sdram_controller_0_we_n,                   --                                    .we_n
			sys_clk_clk                               => CONNECTED_TO_sys_clk_clk,                               --                             sys_clk.clk
			tse_mac_mac_mdio_connection_mdc           => CONNECTED_TO_tse_mac_mac_mdio_connection_mdc,           --         tse_mac_mac_mdio_connection.mdc
			tse_mac_mac_mdio_connection_mdio_in       => CONNECTED_TO_tse_mac_mac_mdio_connection_mdio_in,       --                                    .mdio_in
			tse_mac_mac_mdio_connection_mdio_out      => CONNECTED_TO_tse_mac_mac_mdio_connection_mdio_out,      --                                    .mdio_out
			tse_mac_mac_mdio_connection_mdio_oen      => CONNECTED_TO_tse_mac_mac_mdio_connection_mdio_oen,      --                                    .mdio_oen
			tse_mac_mac_mii_connection_mii_rx_d       => CONNECTED_TO_tse_mac_mac_mii_connection_mii_rx_d,       --          tse_mac_mac_mii_connection.mii_rx_d
			tse_mac_mac_mii_connection_mii_rx_dv      => CONNECTED_TO_tse_mac_mac_mii_connection_mii_rx_dv,      --                                    .mii_rx_dv
			tse_mac_mac_mii_connection_mii_rx_err     => CONNECTED_TO_tse_mac_mac_mii_connection_mii_rx_err,     --                                    .mii_rx_err
			tse_mac_mac_mii_connection_mii_tx_d       => CONNECTED_TO_tse_mac_mac_mii_connection_mii_tx_d,       --                                    .mii_tx_d
			tse_mac_mac_mii_connection_mii_tx_en      => CONNECTED_TO_tse_mac_mac_mii_connection_mii_tx_en,      --                                    .mii_tx_en
			tse_mac_mac_mii_connection_mii_tx_err     => CONNECTED_TO_tse_mac_mac_mii_connection_mii_tx_err,     --                                    .mii_tx_err
			tse_mac_mac_mii_connection_mii_crs        => CONNECTED_TO_tse_mac_mac_mii_connection_mii_crs,        --                                    .mii_crs
			tse_mac_mac_mii_connection_mii_col        => CONNECTED_TO_tse_mac_mac_mii_connection_mii_col,        --                                    .mii_col
			tse_mac_mac_misc_connection_ff_tx_crc_fwd => CONNECTED_TO_tse_mac_mac_misc_connection_ff_tx_crc_fwd, --         tse_mac_mac_misc_connection.ff_tx_crc_fwd
			tse_mac_mac_misc_connection_ff_tx_septy   => CONNECTED_TO_tse_mac_mac_misc_connection_ff_tx_septy,   --                                    .ff_tx_septy
			tse_mac_mac_misc_connection_tx_ff_uflow   => CONNECTED_TO_tse_mac_mac_misc_connection_tx_ff_uflow,   --                                    .tx_ff_uflow
			tse_mac_mac_misc_connection_ff_tx_a_full  => CONNECTED_TO_tse_mac_mac_misc_connection_ff_tx_a_full,  --                                    .ff_tx_a_full
			tse_mac_mac_misc_connection_ff_tx_a_empty => CONNECTED_TO_tse_mac_mac_misc_connection_ff_tx_a_empty, --                                    .ff_tx_a_empty
			tse_mac_mac_misc_connection_rx_err_stat   => CONNECTED_TO_tse_mac_mac_misc_connection_rx_err_stat,   --                                    .rx_err_stat
			tse_mac_mac_misc_connection_rx_frm_type   => CONNECTED_TO_tse_mac_mac_misc_connection_rx_frm_type,   --                                    .rx_frm_type
			tse_mac_mac_misc_connection_ff_rx_dsav    => CONNECTED_TO_tse_mac_mac_misc_connection_ff_rx_dsav,    --                                    .ff_rx_dsav
			tse_mac_mac_misc_connection_ff_rx_a_full  => CONNECTED_TO_tse_mac_mac_misc_connection_ff_rx_a_full,  --                                    .ff_rx_a_full
			tse_mac_mac_misc_connection_ff_rx_a_empty => CONNECTED_TO_tse_mac_mac_misc_connection_ff_rx_a_empty, --                                    .ff_rx_a_empty
			tse_mac_mac_status_connection_set_10      => CONNECTED_TO_tse_mac_mac_status_connection_set_10,      --       tse_mac_mac_status_connection.set_10
			tse_mac_mac_status_connection_set_1000    => CONNECTED_TO_tse_mac_mac_status_connection_set_1000,    --                                    .set_1000
			tse_mac_mac_status_connection_eth_mode    => CONNECTED_TO_tse_mac_mac_status_connection_eth_mode,    --                                    .eth_mode
			tse_mac_mac_status_connection_ena_10      => CONNECTED_TO_tse_mac_mac_status_connection_ena_10,      --                                    .ena_10
			tse_mac_pcs_mac_rx_clock_connection_clk   => CONNECTED_TO_tse_mac_pcs_mac_rx_clock_connection_clk,   -- tse_mac_pcs_mac_rx_clock_connection.clk
			tse_mac_pcs_mac_tx_clock_connection_clk   => CONNECTED_TO_tse_mac_pcs_mac_tx_clock_connection_clk,   -- tse_mac_pcs_mac_tx_clock_connection.clk
			uart_0_rxd                                => CONNECTED_TO_uart_0_rxd,                                --                              uart_0.rxd
			uart_0_txd                                => CONNECTED_TO_uart_0_txd                                 --                                    .txd
		);

