# Creating a Custom AXI4 Master in Vivado (Zedboard)

This tutorial shows how to generate a custom AXI4 Master with burst functionality in Vivado and how to connect it to the HP Port of the Zynq PS on the Zedboard. 

## Requirements

- Vivado 2016.2
- Zedboard

## Creating a New Vivado Project

1. Start Vivado.
2. Choose "Create New Project" in the Vivado welcome menu.

    ![create new project](./images/new_vivado_project01.png "create new project")


3. Click _Next >_.

    ![click next](./images/new_vivado_project02.png "click next")


4. Choose a name for your project and a location. The project name in this tutorial is `axi4_master_burst_example`.

    ![choose project name and location](./images/new_vivado_project03.png "choose project name and location")


5. Choose _RTL Project_.

    ![choose RTL project](./images/new_vivado_project04.png "choose rtl project")


6. Don't add any HDL sources or netlists.

    ![dont add any hdl sources or netlists](./images/new_vivado_project05.png "dont add any hdl sources or netlists")


7. Don't add any existing IP components.

    ![dont add any existing ip components](./images/new_vivado_project06.png "dont add any existing ip components")


8. Don't add any constraints.

    ![dont add any constraints](./images/new_vivado_project07.png "dont add any constraints")


9. Choose _Boards_ and select _Zedboard Zynq Evaluation and Development Kit_.

    ![choose boards and select zedboard](./images/new_vivado_project08.png "choose boards and select zedboard")


10. Click "Finish" to create the Vivado project.

    ![click finish to create the vivado project](./images/new_vivado_project09.png "click finish to create the vivado project")


## Creating a Custom AXI IP

1. Open: _Menu -> Tools -> Create and Package IP_.


    ![menu - tools - create and package ip](./images/create_and_package_ip01.png "menu - tools - create and package ip")


2. Click _Next >_.

    ![click next](./images/create_and_package_ip02.png "click next")


3. Choose _Create a new AXI4 peripheral_.

    ![choose create a new axi4 peripheral](./images/create_and_package_ip03.png "choose create a new axi4 peripheral")


4. Choose a name, description and location for the new AXI4 peripheral. The name in this tutorial is `axi4_master_burst` and the location is `[...]/ip_repo`.

    ![choose name and description](./images/create_and_package_ip04.png "choose name and description")

5. Keep the AXI4-Lite Slave interface.

    ![keep the axi4-lite slave interface](./images/create_and_package_ip05.png "keep the axi4-lite slave interface")


6. Click on the green plus sign to add another interface.

    ![click on green plus](./images/create_and_package_ip06.png "click on green plus")


7. The added interface should be an AXI4-Full Master interface.


    ![axi4-full interface](./images/create_and_package_ip07.png "axi4-full interface")


8. Choose _Edit IP_ and click on _Finish_

    ![edit ip](./images/create_and_package_ip08.png "edit ip")


## Edit AXI4 IP

After the successful creation of the new IP a new Vivado project was opened. In this project we can find the Vivado generated Verilog code for the AXI4-Lite slave, AXI4-Full master, and a wrapper which contains those two components.

![edit ip source tree](./images/edit_ip01.png "edit ip source tree")

* `axi4_master_burst_v1_0` contains the wrapper.
* `axi4_master_burst_v1_0_S00_AXI_inst` contains the Verilog code for the AXI4-Lite slave.
* `axi4_master_burst_v1_0_M00_AXI_inst` contains the Verilog code for the AXI4-Full master.

The AXI4-Lite slave will be used to start and monitor a burst write/read of the AXI4-Full master from the Zynq PS. In order to do that you have to customize the AXI4-Lite slave a little. 

Double click on `axi4_master_burst_v1_0_S00_AXI_inst` and navigate to the ports definition and add your own ports under `// Users to add ports here`

```verilog 
// Users to add ports here
output wire init_txn,
input wire txn_done,
input wire txn_error,
// User ports ends
```

The output wire `init_txn` will later be connected to the AXI4-Full master to start a burst write/read. The input wires `txn_done` and `txn_error` will also be connected to the master and indicate if a write/read transaction was completed and if errors occured during a write/read transaction.

The output wire `init_txn` will be connected to the `slv_reg0` of the AXI4-Lite slave. Navigate to `// Add user logic here` and add the following:

```verilog
// Add user logic here
assign init_txn = slv_reg0[0:0];
// User logic ends
```

The input wires `txn_done` and `txn_error` are directly connected to the `slv_reg1` and `slv_reg2` registers of the AXI4-Lite slave. Navigate to `// Address decoding for reading registers` and change the code like this:

```verilog
// Implement memory mapped register select and read logic generation
// Slave register read enable is asserted when valid address is available
// and the slave is ready to accept the read address.
assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
always @(*)
begin
    // Address decoding for reading registers
    case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
        2'h0   : reg_data_out <= slv_reg0;
        2'h1   : reg_data_out <= {{31{1'b0}},txn_done};
        2'h2   : reg_data_out <= {{31{1'b0}},txn_error};
        2'h3   : reg_data_out <= slv_reg3;
        default : reg_data_out <= 0;
    endcase
end
```

With those changes the Zynq PS is able to start a write/read transaction by setting the LSB of `slv_reg0` to 1 and is also able to read from the LSB of `slv_reg1` and `slv_reg2` to see if the write/read transaction was completed successfully.

The newly added ports of the AXI4-Lite slave also have to be added to the wrapper `axi4_master_burst_v1_0`. Double click on `axi4_master_burst_v1_0` and navigate to `// Instantiation of Axi Bus Interface S00_AXI` and add the ports to the port map:

```verilog
// Instantiation of Axi Bus Interface S00_AXI
axi4_master_burst_v1_0_S00_AXI # ( 
    .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
) axi4_master_burst_v1_0_S00_AXI_inst (

    .init_txn(m00_axi_init_axi_txn),
    .txn_done(m00_axi_txn_done),
    .txn_error(m00_axi_error),

```
Currently the wire `m00_*` are output or input ports of the top module. Those have to be removed from the interface and added as wire in the top module. To do that navigate in `axi4_master_burst_v1_0` to `// Ports of Axi Master Bus Interface M00_AXI` and remove the following lines:

```verilog
input wire  m00_axi_init_axi_txn,
output wire  m00_axi_txn_done,
output wire  m00_axi_error,
```

Under the interface definition of the top module `axi4_master_burst_v1_0` add the following lines:

```verilog
wire  m00_axi_init_axi_txn;
wire  m00_axi_txn_done;
wire  m00_axi_error;
```

Those `m00_*` wires are connecting the the AXI4-Full master and the AXI4-Lite slave in the top module. 

When you look at the verilog code of the AXI4-Full master in `axi4_master_burst_v1_0_M00_AXI_inst` you will see a lot of finite state machines which handle the AXI4 transactions. One of those finite state machine is responsible for the overall functionality of the AXI4-Full master. You can find this state machine when you navigate to `//implement master command interface state machine`. This state machine consists of four states:

* `IDLE`
* `INIT_WRITE`
* `INIT_READ`
* `INIT_COMPARE`

Initially the AXI4-Full master is in `IDLE` until the `init_txn_pulse` is set to high (this will be done by the AXI4-Lite slave `slv_reg0`). 

Then the AXI4-Full master will start to write `C_NO_BURSTS_REQ` bursts consisting of `C_M_AXI_BURST_LEN` data values to memory address `C_M_TARGET_SLAVE_BASE_ADDR`.

After the burst writes are completed the AXI4-Full master starts burst reads on the same memory addresses and compares the read values to the previously written values.

If the comparison was successful the master goes back into `IDLE` and waits for the next high signal on `init_txn_pulse`. To complete the changes in the verilog code do the following:

1. Click on the tab _Package IP - axi4\_master\_burst_.

    ![edit ip tab package ip](./images/edit_ip02.png "edit ip tab package ip")


2. Click on _Customization Parameters_ in _Packaging Steps_.

    ![edit ip customization parameters](./images/edit_ip03.png "edit ip customization parameters")


3. Click on _Merge changes from Customization Parameters Wizard_.

    ![edit ip merge changes](./images/edit_ip04.png "edit ip merge changes")


4. Click on _Review and Package_ in _Packaging Steps_.

    ![edit ip review and package](./images/edit_ip05.png "edit ip review and package")


5. To finish the work on this custom AXI4 IP click on _Re-Package IP_

    ![edit ip re-package ip](./images/edit_ip06.png "edit ip re-package ip")


6. Quit the project by click on _Yes_.

    ![edit ip close project](./images/edit_ip07.png "edit ip close project")


You can go back to the verilog code by clicking on _Flow Navigator -> Project Manager -> IP Catalog_.

![edit ip ip catalog](./images/edit_ip08.png "edit ip ip catalog")

And navigate to _User Repository -> AXI Peripheral -> axi4\_master\_burst\_v1.0_ and right-click to open the context menu an choose _Edit in IP Packager_.

![edit ip edit in ip packager](./images/edit_ip09.png "edit ip edit in ip packager")

## Zynq Block Diagram

That your custom AXI4 IP can be implemented on the Zynq PL and connected to the Zynq PS you have to create a block diagram in Vivado. The following steps will show you how to do that:

1. Click on _Flow Navigator -> IP Integrator -> Create Block Diagram_

    ![create block diagram](./images/block_diagram01.png "create block diagram")


2. Choose a name, directory, and specify a source set for the block diagram. In this tutorial everything stays at the default.

    ![block diagram choose name](./images/block_diagram02.png "block diagram choose name")


3. Right-click on the white background of the _Diagram_ tab and choose _Add IP_.

    ![block diagram add ip](./images/block_diagram03.png "block diagram add ip")


4. From the list of IPs choose _ZYNQ7 Processing System_ (this is the Zynq PS) and double-click on it. 

    ![block diagram zynq ps](./images/block_diagram04.png "block diagram zynq ps")


5. You can now see the Zynq PS in the block diagram. Now click on _Run Block Automation_ to connect the Zynq PS with the memory.

    ![block diagram run block automation](./images/block_diagram05.png "block diagram run block automation")


6. Leave everything at the default values and click on _OK_.

    ![block diagram run block automation ok](./images/block_diagram06.png "block diagram run block automation ok")


7. To connect the your custom AXI4 IP to the Zynq PS the Zynq PS needs an AXI4-Full slave high performance port. To enable this port double-click on the Zynq PS in the block diagram.

    ![block diagram zynq ps](./images/block_diagram07.png "block diagram zynq ps")


8. In the _Re-customize IP_ window go to _Page Navigator -> PS-PL Configuration_.

    ![block diagram ps-pl](./images/block_diagram08.png "block diagram ps-pl")


9. Go to _PS-PL Configuration -> HP Slave AXI Interface_ and check _S AXI HP0 interface_ and click on _OK_.

    ![block diagram s axi hp0](./images/block_diagram09.png "block diagram s axi hp0")


10. In the next step add your custom AXI4 IP by right-clicking on the white background and choosing _Add IP_. Choose _axi4\_master\_burst\_v1.0_ from the list of IPs and double-click on it.

    ![block diagram add custom axi4 ip](./images/block_diagram10.png "block diagram add custom axi4 ip")


11. To connect the custom AXI4 IP on the Zynq PL to the Zynq PS click on _Run Connection Automation_.

    ![block diagram run connection automation](./images/block_diagram11.png "block diagram run connection automation")


12. In the _Run Connection Automation_ window click on _S00\_AXI_ and choose _/processing\_system7\_0/FCLK\_CLK0_ for _Clock Connection (...)_ and do the same with _S\_AXI\_HP0_.

    ![block diagram clock connection](./images/block_diagram12.png "block diagram clock connection")


13. Check all checkboxes on the left-hand side of the _Run Connection Automation_ window to connect those ports automatically and click on _OK_.

    ![block diagram checkboxes](./images/block_diagram13.png "block diagram checkboxes")


14. After the auto connection is finished the block diagram should look like this:

    ![block diagram overview](./images/block_diagram14.png "block diagram overview")


15. Click on the _Address Editor_ tab and unfold the _axi4\_master\_burst\_0_ tree to see the address range of the _S_AXI_HP0_ port which is connected to the memory. On the Zedboard the address range goes from `0x00000000` to `0x1FFFFFFF`.

    ![block diagram adress editor](./images/block_diagram15.png "block diagram address editor")


16. In the _Diagram_ tab double-click on the _axi4\_master\_burst\_0_ to open the _Re-customize IP_ window. Set the _C M 00 AXI TARGET SLAVE BASE ADDR_ to ` 0x10000000` (The default value `0x40000000` is not within the range of the memory)

    ![block diagram recustomize ip](./images/block_diagram16.png "block diagram recustomize ip")


17. In the _Sources_ panel navigate to _Design Sources -> design\_1_

    ![block diagram sources](./images/block_diagram17.png "block diagram sources")


18. Right-click on _design\_1_ and choose _Create HDL Wrapper_. This generates HDL code for the block diagram which is necessary for the synthesis.

    ![block diagram hdl wrapper](./images/block_diagram18.png "block diagram hdl wrapper")

19. Choose _Let Vivado manage wrapper and auto-update_ and click _OK_. This will always update your HDL wrapper when the block diagram was changed.

    ![block diagram hdl wrapper dialog](./images/block_diagram19.png "block diagram hdl wrapper dialog")

## AXI4-Full Master Simulation

