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
