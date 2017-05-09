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
