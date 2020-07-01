# LTE-SIM [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Google group : LTE-Sim](https://img.shields.io/badge/Google%20Group-LTE%20Sim-blue.svg)](https://groups.google.com/group/lte-sim)


**The original github and work can be found at [https://github.com/lte-sim/lte-sim-dev](https://github.com/lte-sim/lte-sim-dev), this repository consists of a set of simple bug fixes and a replaced makefile, to simplify getting started with LTE-Sim.**  

**The original LTE-Sim webpage is available on [TelematicsLab](https://telematics.poliba.it/index.php?option=com_content&view=article&id=28&Itemid=203&lang=en)**

Table of Contents
=================

* [Description](#description)
* [Quick Start](#Quick-Start)
	* [Dependencies](#dependencies)
	* [Installing](#installing)
	* [Executing program](#executing-program)
* [Getting Started](#getting-started)
	* [Adding a custom unitfile](#adding-a-custom-unitfile)
	* [Debugging your custom files](#debugging-your-custom-files)
        * [Advanced debugging](#Advanced-debugging)
	* [Adding a custom scenario or test to the binary](#adding-a-custom-scenario-or-test-to-the-binary)
	* [Changing logging output](#changing-logging-output)
	* [Modifing Handover](#modifing-handover)
	* [Scheduling Simulator Events](#scheduling-simulator-events)
* [Help](#help)
* [Known Issues](#Known-Issues)
* [Authors](#authors)
	* [Original Author](#original-author)
	* [Bugfix Author](#bugfix-author)
* [Version History](#version-history)
* [License](#license)
* [Copyright](#copyright)

## Description

Welcome to LTE-SIM, an advanced packet level E-UTRAN and EPS discrete simulator. Originally made by Giuseppe Piro from Telematics Labs. LTE-Sim is a feature rich simulator and contains many components such as QoS, Frequency Reuse, User Mobility and Handover Procedures.  

This repository is clone, with a set of bug fixes and updates to ease compilation of LTE-Sim with newer versions of the [GNU Compiler Collection](https://gcc.gnu.org/). Additionally the C++ standard used to compile, has been raised from C++ 11 to 14, however, a large part of the codebase does not use C++ 14 features.


## Quick Start

The following section is a short introduction, to getting your first working binary compiled.

### Dependencies

To compile the source code you will require the following:
* A compiler capable of handling C++ 14. The recommendation for this is the GNU Compiler Collection, v7.4 or higher
* GNU Make
* If you want to run some of the pre-made scenarios you will also need a bash terminal or emulator
	* General note: The current version of the simulator has only been tested on Ubuntu 18.04, its highly recommend not to develop on Windows platforms (unless using remote editing).

### 'Installing'

1. Download LTE-Sim from this GitHub repository, e.g. git clone.
1. Navigate to the root directory of the simulator.
1. Check the [makefile in the root directory](makefile), there are several key variables which may need to be set, they are clearly commented. Some examples are:
	1. "TARGET" - The output name of the binary
	1. "CXXFLAGS" - Optional command line flags to be parsed to the compiler (g++)
1. (Optional) Update the path variable within the [load-parameters.h](src/load-parameters.h), it can be found on line 31. This is used by various included scripts in the TOOLS folder and RUN folder.
1. Compile the binary using "make" or "make -j" 
	1. Note: -j will use as many available threads as possible and can cause problems on low spec machines


### Executing program

* If your compilation is successful, you will find the LTE-Sim binary in the root directory of your simulator. The default name for the binary is 'ltesim' an example of using it would be:
```
./ltesim -h
```


## Getting Started

The following section contains some information on simulator components alongside useful tips to help speed up your implementation.

* As part of the repository a small guide can be found in [DOC/tutorial.pdf](DOC/tutorial.pdf), it is available in a variety of formats.
	* This contains the UML diagram for the simulator
	* A quick set of instructions on how to make your first "scenario" 
* The original whitepaper with the simulator design is available online [here](https://doi.org/10.1109/TVT.2010.2091660).
	* Please note you will need an IEEE Xplore subscription  
* The sections below provide some quick pointers and tips on where to look in the code base.

#### Adding a custom unitfile

If you are looking to extend the simulator with your own code files. Ensure they are placed within the ```/src``` directory. The build system automatically adds ```.cpp```  and ```.cc``` files, even if they are nested. If you require additional file types, please see the makefile comments on how to implement a custom target.

The build system stores all intermediary objects in the  ```.objects/```, for example the main simulator file would become:
```./objects/LTE-Sim.o```. 
File directory structure is preserved while doing this, for example the "FlowsManager" can be found in: 
```./objects/componentManagers/FlowsManager.o```
#### Debugging your custom files

If standard the library logging options such as ```std::cout``` and ```std:cerr``` are not enough to debug your program, it is possible to generate a stack trace.

First LTE-Sim must be compiled with debug symbols, this an easy option to enable. First if you an existing build run ```make clean```. Then the makefile must be modified to include debug symbols. The parameters parsed to the compiler can be found on line 4 in the "CXXFLAGS" variable. To add debug symbols for default compiler (g++), the "-g" flag needs to be added. A example of this can be seen below:
```
#Flags
CXXFLAGS = -c --std=c++14 -g -Wall -Wno-unused-variable -Wno-unused-function -Wunused-but-set-variable -fPIC
```
##### Advanced debugging

If you have not used a command line stack trace before, a good place to start is the [GDB: The GNU Project Debugger](https://www.gnu.org/software/gdb/). Assuming you are in the root directory of the simulator, the following commands would load the LTE-Sim binary and print a trace for the "Simple" option.
```shell
gdb
file ltesim
run Simple
quit
```
**Note: A stack trace will not display, if the program exits normally.**
 
#### Adding a custom scenario or test to the binary
Much like with adding custom unit file, scenarios and custom tests can be added the simulator. By convention they should be located in ```src/scenarios/<yourfilename>.h``` or ```src/TEST/<yourfilename>.h``` . You will then need to include them into the menu system, which is located in [src/LTE-Sim.cpp](src/LTE-Sim.cpp) . There is no fall through if mistakes are made with input parameters. If nothing is displayed, when the binary is run, **check your input parameters match - (CASE SENSITIVE)**.
#### Changing logging output
Logging options are controlled by the [load-parameters.h](src/load-parameters.h) file. By default most logging options are done through compiler macros for example:
```
#ifdef SIMPLE_DEBUGG
	std::cout << "My simple debug" <<  std::endl;
#endif
```
This can be then enabled by having the following line with the [load-parameters.h](src/load-parameters.h) file:
```
#define SIMPLE_DEBUGG
```
There are several sets of available variables for configuring tests and traces. The most frequently used ones are the trace options, which can be found on lines 35-38. Each of these options enables a large trace output to be printed to the console. As a consequence, you may find it helpful to pipe the result into a file for later processing. The default settings for the mentioned variables can be found below:
```
/* tracing */
static bool _APP_TRACING_ = true;
static bool _RLC_TRACING_ = false;
static bool _MAC_TRACING_ = false;
static bool _PHY_TRACING_ = false;
```
#### Modifing Handover
A commonly looked into problem is changing handover behaviour. The various handover strategies  as well as the "Handover-entity" can be found in ```src/protocolStack/rrc/ho```. Included with the simulator is two existing strategies position based and power based. By default the power based one is used, to change which handover strategy is used edit the handover-entity.cpp file. On lines 30-34 is where the entity is created and the strategy is set:
```
HandoverEntity::HandoverEntity()
{
  m_device = NULL;
  m_hoManager = new PowerBasedHoManager (); //<----- CHANGE THIS LINE
}
```
#### Scheduling Simulator Events
Lte-Sim uses a discrete event scheduler which can be found in [src/core/eventScheduler/simulator.h](src/core/eventScheduler/simulator.h). It uses templates, to allow for function calls and their associated parameters to be defered to a later point in time.

It is important to note that time provided to "Schedule()" is **relative**. A simple example of how to trigger a logging event for a eNodeB can be seen below, after 3 seconds the function Print() is called on the parsed object "enb".
```
#include "../core/eventScheduler/simulator.h"
simulator->Schedule(3,&ENodeB::Print,enb);
```
## Help

If the above is unable to help or you have further questions, please try:

* Searching the [LTE-Sim google group](https://groups.google.com/group/lte-sim). *Many questions have answers from the author!*
* Contact the original author

## Known Issues

The current known issues are as follows:
* Various included scripts used for automating testing may not currently work. The majority of these are in the [RUN](RUN/) folder.
* Additional components provided in the [TOOLS](TOOLS/) folder is currently not built as part of the new make system. However, This can still be done by hand.

## Authors
There are additional authors and contributors, who are named in the [AUTHORS](AUTHORS) and [CONTRIBUTORS](CONTRIBUTORS) files respectively.
### Original Author

Giuseppe Piro  
Software manager and main developer  
2010,2011, 2012  
TELEMATICS LAB - Politecnico di Bari  
g.piro@poliba.it  
peppe@giuseppepiro.com  
### Bugfix Author
Maxwell Sinclair  
3rd Year Undergraduate  
Department of Computer Science  
University of York
mjas500@york.ac.uk
## Version History

* Release 6.0
    * Replaced the recursive makefile system with a easier to use system.
    	* There are still some issues with using the included scripts in the "TOOLS" folder. 
    * Fixed a series of bugs where functions returned "false" instead of "Nullptr"
    * Updated the compiler to use C++ version 14.
* Release 5.0 or older
    * Please see the included RELEASE_NOTES file

## License

* The original project, is licensed under [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html)
* The work contained within this repository is also licensed under [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html)
* You can find a copy of the license file in the codebase: [LICENSE](./LICENSE)

## Copyright
The original simulator and work remains copyrighted by the original author: © 2015 - TELEMATICS LAB - Politecnico di Bari
