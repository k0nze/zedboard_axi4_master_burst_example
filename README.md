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


4. Choose a name, description and location for the new AXI4 peripheral. The name in this tutorial is `axi4_master_burst` and the location is [...]/ip_repo.

    ![choose name and description](./images/create_and_package_ip04.png "choose name and description")

5. Keep the AXI4-Lite Slave interface.

    ![keep the axi4-lite slave interface](./images/create_and_package_ip05.png "keep the axi4-lite slave interface")


6. Click on the green plus sign to add another interface.

    ![click on green plus](./images/create_and_package_ip06.png "click on green plus")


7. The added interface should be an AXI4-Full Master interface.


    ![axi4-full interface](./images/create_and_package_ip07.png "axi4-full interface")


8. Choose _Edit IP_ and click on _Finish_

    ![edit ip](./images/create_and_package_ip08.png "edit ip")


## Edit AXI4 Master IP

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

With those changes the Zynq PS is able to start a write/read transaction by setting the LSB of `slv_reg0` and is also able to read from `slv_reg1` and `slv_reg2` to see if the write/read transaction was completed successfully.
