# ELEC5566M ASSIGNMENT 2 : State Machine Based Digital Lock 

This repository contains multiple Verilog HDL files that define a state machine based digital lock. The code was designed for and implemented on the DE1-SoC board. The full list of module hierarchy, properties and functions can be seen in sections below. A video demonstration of the implemented code can be seeing using the link provided:
[VIDEO DEMO](https://github.com/leeds-embedded-systems/ELEC5566M-Assignment2-jamesheavey/blob/6cca6de2a3854d2b45c6a78d0e5444cad8d6c4b4/DEMO%20&%20DIAGRAMS/Digital_Lock_demo.mp4)

This code parameterised so that the length of password can be altered, along with the number of seven segemnt displays to match the number available on the given hardware board.

## Module List
This repository includes the following files:

| MODULE | PARAMETERS | INPUTS | OUTPUTS | FUNCTION |
| ---  | --- | ---  | --- | --- |
| `DigitalLock.v`    | PASSWORD_LENGTH, NUM_DISPLAYS | clock, reset, key[4] | LEDs[6], 7Seg[NUM_DISPLAYS] | Toplevel module for digital lock system. takes a clock and reset signal as inputs aswell as a set of 4 keys. Instantiates relevant submodules and returns user interfacing outputs in the form of LEDs and seven segment displays (number of displays defined by `NUM_DISPLAYS` parameter). |
| `KeyPressFilter.v` | N/A | clock, reset, key[4] | posedge_key[4] | Module to detect the positive edge of any any button state change. This module prevents additional buttons from being pressed if another is already pressed. |
| `DigitalLockFSM.v` | PASSWORD_LENGTH, NUM_DISPLAYS, MAX_IDLE | clock, reset, key[4] | state_flags[4], display_digits[NUM_DISPLAYS] | Module to define the function of the lock FSM. Sequentially processes key input (processed by `KeyPressFilter.v`), updates internal state, outputs state flags and digits to display on the 7 segments for user interaction. Further explanation of this module can be observed in the 'Finite State Machine' section below. |
| `PasswordTo7Seg.v` |  NUM_DISPLAYS | password[NUM_DISPLAYS] | SevenSeg[NUM_DISPLAYS] | Module to instantiate and connect the correct number of Hex converter modules with the selected display digits of the password (recieved from `DigitalLockFSM.v` 'display_digits' output). |
| `HexTo7Seg.v`      | N/A | hex[4] | SevenSeg[7] | Module to convert a 4 bit hex value to desired 7 segment representation. Module edited so that standard conversion not exhibited to allow for advanced UI messages to be displayed.  |

## Module Hierarchy
![HIERARCHY](https://github.com/leeds-embedded-systems/ELEC5566M-Assignment2-jamesheavey/blob/6cca6de2a3854d2b45c6a78d0e5444cad8d6c4b4/DEMO%20&%20DIAGRAMS/Assignment2ModuleHierarchy.png)

## Finite State Machine
![FSM](https://github.com/leeds-embedded-systems/ELEC5566M-Assignment2-jamesheavey/blob/f6622b21350074fc04de344a3500a411e6c64359/DEMO%20&%20DIAGRAMS/Assignment2StateMachine.png)

---

#### By James Heavey

#### SID: 201198933

#### University of Leeds, Department of Electrical Engineering
