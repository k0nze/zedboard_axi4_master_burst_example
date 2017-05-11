`timescale 1 ns / 1 ps

`define TICK #10
`define HALF_TICK #5

module axi4_master_burst_v1_0_tb ();

        // Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32;
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4;

		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h10000000;
		parameter integer C_M00_AXI_BURST_LEN	= 16;
		parameter integer C_M00_AXI_ID_WIDTH	= 1;
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32;
		parameter integer C_M00_AXI_DATA_WIDTH	= 32;
		parameter integer C_M00_AXI_AWUSER_WIDTH    = 0;
		parameter integer C_M00_AXI_ARUSER_WIDTH	= 0;
		parameter integer C_M00_AXI_WUSER_WIDTH	= 0;
		parameter integer C_M00_AXI_RUSER_WIDTH	= 0;
		parameter integer C_M00_AXI_BUSER_WIDTH	= 0;

        // fake memory
        bit [C_S00_AXI_DATA_WIDTH-1:0] mem[integer];

        reg clk;
        reg reset_n;

        bit [C_S00_AXI_DATA_WIDTH-1:0] data;
        bit txn_done;
        bit txn_error;

        integer i;

		// Ports of Axi Slave Bus Interface S00_AXI
		reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
		reg [2 : 0] s00_axi_awprot;
		reg s00_axi_awvalid;
		wire s00_axi_awready;
		reg [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
		reg [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
		reg s00_axi_wvalid;
		wire s00_axi_wready;
		wire [1 : 0] s00_axi_bresp;
		wire s00_axi_bvalid;
		reg s00_axi_bready;
		reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
		reg [2 : 0] s00_axi_arprot;
		reg s00_axi_arvalid;
		wire s00_axi_arready;
		wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
		wire [1 : 0] s00_axi_rresp;
		wire s00_axi_rvalid;
		reg s00_axi_rready;

		// Ports of Axi Master Bus Interface M00_AXI
		wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid;
		wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr;
		wire [7 : 0] m00_axi_awlen;
		wire [2 : 0] m00_axi_awsize;
		wire [1 : 0] m00_axi_awburst;
		wire m00_axi_awlock;
		wire [3 : 0] m00_axi_awcache;
		wire [2 : 0] m00_axi_awprot;
		wire [3 : 0] m00_axi_awqos;
		wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser;
		wire m00_axi_awvalid;
		reg m00_axi_awready;
		wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata;
		wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb;
		wire m00_axi_wlast;
		wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser;
		wire m00_axi_wvalid;
		reg m00_axi_wready;
		reg [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid;
		reg [1 : 0] m00_axi_bresp;
		reg [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser;
		reg m00_axi_bvalid;
		wire m00_axi_bready;
		wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid;
		wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr;
		wire [7 : 0] m00_axi_arlen;
		wire [2 : 0] m00_axi_arsize;
		wire [1 : 0] m00_axi_arburst;
		wire  m00_axi_arlock;
		wire [3 : 0] m00_axi_arcache;
		wire [2 : 0] m00_axi_arprot;
		wire [3 : 0] m00_axi_arqos;
		wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser;
		wire m00_axi_arvalid;
		reg m00_axi_arready;
		reg [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid;
		reg [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata;
		reg [1 : 0] m00_axi_rresp;
		reg m00_axi_rlast;
		reg [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser;
		reg m00_axi_rvalid;
		wire m00_axi_rready;

        task setAllRegsTo0();
            clk <= 1'b0;
            reset_n <= 1'b0;

            s00_axi_awaddr <= {C_S00_AXI_ADDR_WIDTH{1'b0}};
		    s00_axi_awprot <= 3'b000;
            s00_axi_wdata <= {C_S00_AXI_DATA_WIDTH{1'b0}};
		    s00_axi_wstrb <= {(C_S00_AXI_DATA_WIDTH/8){1'b0}};
		    s00_axi_awvalid <= 1'b0;
		    s00_axi_wvalid <= 1'b0;
            s00_axi_bready <= 1'b0;
            s00_axi_araddr <= {C_S00_AXI_ADDR_WIDTH{1'b0}};
            s00_axi_arprot <= 3'b000;
            s00_axi_arvalid <= 1'b0;
            s00_axi_rready <= 1'b0;

            m00_axi_awready <= 1'b0;
            m00_axi_wready <= 1'b0;
            m00_axi_bid <= {C_M00_AXI_ID_WIDTH{1'b0}};
            m00_axi_bresp <= 2'b0;
            //m00_axi_buser <= {C_M00_AXI_BUSER_WIDTH{1'b0}}; 
            m00_axi_bvalid <= 1'b0;
            m00_axi_arready <= 1'b0;
            m00_axi_rid <= {C_M00_AXI_ID_WIDTH{1'b0}};
            m00_axi_rdata <= {C_M00_AXI_DATA_WIDTH{1'b0}};
            m00_axi_rresp <= 2'b00;
            m00_axi_rlast <= 1'b0;
            //m00_axi_ruser <= {C_M00_AXI_RUSER_WIDTH{1'b0}};
            m00_axi_rvalid <= 1'b0;
        endtask

        task handleAXI4BurstWriteTransaction();
            // store address
            integer write_address;
            integer burst_write_length;

            // store address and burst length
            write_address = m00_axi_awaddr;
            burst_write_length = m00_axi_awlen;

            $display(" * burst write transaction to address 0x%h, length %d", write_address, burst_write_length + 1);

            // tell master that provided address (over m00_axi_awaddr) was
            // recognized
            m00_axi_awready = 1'b1;

            // wait until the first valid data word arrives
            while(m00_axi_wvalid == 1'b0) begin
                `TICK 
                reset_n = reset_n;
            end

            // tell master that transferred data (over m00_axi_wdata) can be stored
            m00_axi_wready = 1'b1;

            if(burst_write_length != 0) begin
                // store data in mem until M_AXI_WLAST is HIGH
                while(m00_axi_wlast == 1'b0) begin
                    `TICK
                    mem[write_address] = m00_axi_wdata;
                    write_address = write_address + 4;
                end
            end
            else begin
                `TICK
                mem[write_address] = m00_axi_wdata;
            end

            // tell master that transfer was successful
            `TICK
            m00_axi_wready = 1'b0;
            m00_axi_bvalid = 1'b1;
            `TICK
            `TICK
            m00_axi_bvalid = 1'b0;

            `TICK reset_n = reset_n;

        endtask

        task handleAXI4BurstReadTransaction();
            integer i;
            integer read_address;
            integer burst_read_length;

            // store address and burst length
            read_address = m00_axi_araddr;
            burst_read_length = m00_axi_arlen;

            $display(" * burst read transaction from address 0x%h, length %d", read_address, burst_read_length + 1);

            // tell master that provided address (over m00_axi_araddr) was
            // recognized
            m00_axi_arready = 1'b1;
            `TICK
            `TICK
            m00_axi_arready = 1'b0;

            if(burst_read_length == 0) begin
                m00_axi_rlast = 1'b1;
                m00_axi_rvalid = 1'b1;
                m00_axi_rdata = mem[read_address];
                `TICK
                `TICK
                m00_axi_rlast = 1'b0;
                m00_axi_rvalid = 1'b0;
                m00_axi_rdata <= {C_M00_AXI_DATA_WIDTH{1'b0}};
            end
            else begin
                for(i = 0; i <= burst_read_length; i = i + 1) begin

                    // tell master that the last piece of data will be transferred
                    if(i == burst_read_length) begin
                        m00_axi_rlast = 1'b1;
                    end

                    // transmit data
                    m00_axi_rvalid = 1'b1;
                    m00_axi_rdata = mem[read_address];

                    // wait until master is ready to receive data
                    while(m00_axi_rready == 1'b0) begin
                        `TICK 
                        reset_n = reset_n;
                    end
                    `TICK
                    read_address = read_address + 4;
                    m00_axi_rvalid = 1'b0;
                end

                m00_axi_rlast = 1'b0;
            end
        endtask

        task doAXI4LiteWriteTransaction(input bit [C_S00_AXI_ADDR_WIDTH-1:0] target_slave_reg, input bit [C_S00_AXI_DATA_WIDTH-1:0] data);

            $display(" * write transaction to slave register %b, data = %d", target_slave_reg, data);

            // tell slave the target register and the data
            s00_axi_awaddr = target_slave_reg;
            s00_axi_awvalid = 1'b1;
            s00_axi_wdata = data;
            s00_axi_wvalid = 1'b1;
            s00_axi_wstrb = 4'b1111;

            // wait until slave recognizes the provided address and data
            while(s00_axi_awready == 1'b0 && s00_axi_wready == 1'b0) begin
                `TICK 
                reset_n = reset_n;
            end

            `TICK
            s00_axi_awaddr = {C_S00_AXI_ADDR_WIDTH{1'b0}};
            s00_axi_awvalid = 1'b0;

            // tell slave the the response can be accepted
            s00_axi_bready = 1'b1;

            // wait until slave has processed provided data
            while(s00_axi_wready == 1'b1) begin
                `TICK 
                reset_n = reset_n;
            end

            s00_axi_wdata = {C_S00_AXI_DATA_WIDTH{1'b0}};
            s00_axi_wvalid = 1'b0;
            s00_axi_wstrb = 4'b0000;

            // wait until slave sends its response
            while(s00_axi_bvalid == 1'b0) begin
                `TICK 
                reset_n = reset_n;
            end

            `TICK
            s00_axi_bready = 1'b0;
        endtask

        task doAXI4LiteReadTransaction(input bit [C_S00_AXI_ADDR_WIDTH-1:0] target_slave_reg, output bit [C_S00_AXI_DATA_WIDTH-1:0] data);

            // tell slave the target register
            s00_axi_araddr = target_slave_reg;
            s00_axi_arvalid = 1'b1;

            // wait until slave recognizes the provided address
            while(s00_axi_arready == 1'b0) begin
                `TICK
                reset_n = reset_n;
            end

            `TICK
            s00_axi_araddr = {C_S00_AXI_ADDR_WIDTH{1'b0}};
            s00_axi_arvalid = 1'b0;
            s00_axi_rready = 1'b1;

            // wait until slave sends its response
            while(s00_axi_rvalid == 1'b0) begin
                `TICK
                reset_n = reset_n;
            end

            // store data provided by slave
            data = s00_axi_rdata;

            $display(" * read transaction from slave register %b, data = %d", target_slave_reg, data);

            `TICK
            s00_axi_rready = 1'b0;
        endtask

        task printMemory();
            foreach(mem[i]) begin
                $display("%h : %d", i, mem[i]);
            end
        endtask

        
        initial begin
            $display("START tb");

            
            setAllRegsTo0();

            `TICK
            `TICK
            `TICK
            reset_n = 1'b1;

            `TICK
            // start burst transactions
            doAXI4LiteWriteTransaction(4'b0000, 1);    

            txn_done = 1'b0;
            txn_error = 1'b0;

            // poll slave until burst transactions are done
            while(txn_done == 1'b0) begin
                doAXI4LiteReadTransaction(4'b0100, data);    
                txn_done = data[0:0];
            end
              
            // check if there was an error during the burst
            doAXI4LiteReadTransaction(4'b1000, data);    
            txn_error = data[0:0];

            printMemory();

            $display("END tb");
        end

        always @(posedge clk) begin
            if(m00_axi_awvalid == 1'b1) begin
                handleAXI4BurstWriteTransaction(); 
            end
            else if(m00_axi_arvalid == 1'b1) begin
                handleAXI4BurstReadTransaction();
            end
        end

        always begin
            `HALF_TICK clk = !clk;
        end


    axi4_master_burst_v1_0 #(
		.C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
		.C_M00_AXI_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M00_AXI_BURST_LEN(C_M00_AXI_BURST_LEN),
		.C_M00_AXI_ID_WIDTH(C_M00_AXI_ID_WIDTH),
		.C_M00_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M00_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M00_AXI_AWUSER_WIDTH(C_M00_AXI_AWUSER_WIDTH),
		.C_M00_AXI_ARUSER_WIDTH(C_M00_AXI_ARUSER_WIDTH),
		.C_M00_AXI_WUSER_WIDTH(C_M00_AXI_WUSER_WIDTH),
		.C_M00_AXI_RUSER_WIDTH(C_M00_AXI_RUSER_WIDTH),
		.C_M00_AXI_BUSER_WIDTH(C_M00_AXI_BUSER_WIDTH)
	) DUT (
		// Ports of Axi Slave Bus Interface S00_AXI
		.s00_axi_aclk(clk),
		.s00_axi_aresetn(reset_n),
		.s00_axi_awaddr(s00_axi_awaddr),
		.s00_axi_awprot(s00_axi_awprot),
		.s00_axi_awvalid(s00_axi_awvalid),
		.s00_axi_awready(s00_axi_awready),
		.s00_axi_wdata(s00_axi_wdata),
		.s00_axi_wstrb(s00_axi_wstrb),
		.s00_axi_wvalid(s00_axi_wvalid),
		.s00_axi_wready(s00_axi_wready),
		.s00_axi_bresp(s00_axi_bresp),
		.s00_axi_bvalid(s00_axi_bvalid),
		.s00_axi_bready(s00_axi_bready),
		.s00_axi_araddr(s00_axi_araddr),
		.s00_axi_arprot(s00_axi_arprot),
		.s00_axi_arvalid(s00_axi_arvalid),
		.s00_axi_arready(s00_axi_arready),
		.s00_axi_rdata(s00_axi_rdata),
		.s00_axi_rresp(s00_axi_rresp),
		.s00_axi_rvalid(s00_axi_rvalid),
		.s00_axi_rready(s00_axi_rready),

		// Ports of Axi Master Bus Interface M00_AXI
		.m00_axi_aclk(clk),
		.m00_axi_aresetn(reset_n),
		.m00_axi_awid(m00_axi_awid),
		.m00_axi_awaddr(m00_axi_awaddr),
		.m00_axi_awlen(m00_axi_awlen),
		.m00_axi_awsize(m00_axi_awsize),
		.m00_axi_awburst(m00_axi_awburst),
		.m00_axi_awlock(m00_axi_awlock),
		.m00_axi_awcache(m00_axi_awcache),
		.m00_axi_awprot(m00_axi_awprot),
		.m00_axi_awqos(m00_axi_awqos),
		.m00_axi_awuser(m00_axi_awuser),
		.m00_axi_awvalid(m00_axi_awvalid),
		.m00_axi_awready(m00_axi_awready),
		.m00_axi_wdata(m00_axi_wdata),
		.m00_axi_wstrb(m00_axi_wstrb),
		.m00_axi_wlast(m00_axi_wlast),
		.m00_axi_wuser(m00_axi_wuser),
		.m00_axi_wvalid(m00_axi_wvalid),
		.m00_axi_wready(m00_axi_wready),
		.m00_axi_bid(m00_axi_bid),
		.m00_axi_bresp(m00_axi_bresp),
		.m00_axi_buser(m00_axi_buser),
		.m00_axi_bvalid(m00_axi_bvalid),
		.m00_axi_bready(m00_axi_bready),
		.m00_axi_arid(m00_axi_arid),
		.m00_axi_araddr(m00_axi_araddr),
		.m00_axi_arlen(m00_axi_arlen),
		.m00_axi_arsize(m00_axi_arsize),
		.m00_axi_arburst(m00_axi_arburst),
		.m00_axi_arlock(m00_axi_arlock),
		.m00_axi_arcache(m00_axi_arcache),
		.m00_axi_arprot(m00_axi_arprot),
		.m00_axi_arqos(m00_axi_arqos),
		.m00_axi_aruser(m00_axi_aruser),
		.m00_axi_arvalid(m00_axi_arvalid),
		.m00_axi_arready(m00_axi_arready),
		.m00_axi_rid(m00_axi_rid),
		.m00_axi_rdata(m00_axi_rdata),
		.m00_axi_rresp(m00_axi_rresp),
		.m00_axi_rlast(m00_axi_rlast),
		.m00_axi_ruser(m00_axi_ruser),
		.m00_axi_rvalid(m00_axi_rvalid),
		.m00_axi_rready(m00_axi_rready)
	);

endmodule
