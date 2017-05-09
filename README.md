# Creating a Custom AXI4 Master in Vivado (Zedboard)

This tutorial shows how to generate a custom AXI4 Master with burst functionality in Vivado and how to connect it to the HP Port of the Zynq PS on the Zedboard. 

## Requirements

- Vivado 2016.2
- Zedboard

## Creating a New Vivado Project

1. Start Vivado.
2. Choose "Create New Project" in the Vivado welcome menu.

    ![create new project](./images/new_vivado_project01.png "create new project")


3. Click "Next >".

    ![click next](./images/new_vivado_project02.png "click next")


4. Choose a name for your project and a location. The project name in this tutorial is `axi4_master_burst_example`.

    ![choose project name and location](./images/new_vivado_project03.png "choose project name and location")


5. Choose "RTL Project".

    ![choose RTL project](./images/new_vivado_project04.png "choose rtl project")


6. Don't add any HDL sources or netlists.

    ![dont add any hdl sources or netlists](./images/new_vivado_project05.png "dont add any hdl sources or netlists")


7. Don't add any existing IP components.

    ![dont add any existing ip components](./images/new_vivado_project06.png "dont add any existing ip components")


8. Don't add any constraints.

    ![dont add any constraints](./images/new_vivado_project07.png "dont add any constraints")


9. Choose "Boards" and select "Zedboard Zynq Evaluation and Development Kit"

    ![choose boards and select zedboard](./images/new_vivado_project08.png "choose boards and select zedboard")


10. Click "Finish" to create the Vivado project.

    ![click finish to create the vivado project](./images/new_vivado_project09.png "click finish to create the vivado project")
