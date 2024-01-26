# Electronic Door Lock System

The Electronic Door Lock System is a hardware project that involves designing and programming a simple electronic door lock system. This system utilizes a Rotary Pulse Generator (RPG) to manipulate the value displayed on a 7-segment display. Users can select each digit of a 5-digit password using the RPG and submit their selections with a pushbutton. Once all 5 digits are submitted, the passcode is evaluated for correctness, and the system provides feedback through a built-in LED.

## Table of Contents
- Schematic
- Hardware
- Software
- Conclusion

## Schematic!
<img width="1000" alt="Screen Shot 2024-01-25 at 3 15 03 PM" src="https://github.com/anshuljg07/ElectronicDoorLock/assets/72891464/7d25df50-a711-4709-bf3d-abe9f1a4cf0e">
<br />
Figure 1:
<br />
Diagram for the lock system. The system consists of the following components:
- One sn74hc595n shift register
- One 5161AS 7-segment display
- One Rotary Pulse Generator (RPG)
- One mechanical pushbutton
- Eight 1 KΩ resistors
- Five 10 KΩ resistors
- Two 0.1 µF capacitors
- One 0.2 µF capacitor
- One 100 KΩ resistor

## Hardware

The hardware implementation of the Electronic Door Lock System involves connecting and configuring various components. Here are the key hardware aspects:

- **Shift Register Configuration:** The shift register (sn74hc595n) is configured to control the 7-segment display. Clock inputs to the shift register are received from the microcontroller, allowing the display of hexadecimal digits (0-F). 1 KΩ resistors are used to limit the current from the shift register to the 7-segment display.

- **RPG Integration:** The RPG is integrated into the circuit and debounced for accurate input. Pull-up and pull-down resistors are used, along with capacitors, to smooth the signal and eliminate ripple. The RPG channels (A and B) are connected to the microcontroller for input.

- **Mechanical Pushbutton:** A mechanical pushbutton is used to submit user selections. Similar to the RPG, the pushbutton is mechanically debounced and connected to the microcontroller.
  
## Software

The software aspect of the Electronic Door Lock System plays a crucial role in managing user input, displaying digits on the 7-segment display, and controlling timing. Here's a more detailed look at the software components:

### Display Function

The heart of the software lies in the display function, responsible for showing the selected digits on the 7-segment display. This function simplifies the task of updating the display by encapsulating the following steps:

1. **Digit Mapping:** An array called `digits` is defined to map hexadecimal digits (0-F) to their corresponding 7-segment display patterns. This array contains 8-bit binary values for each digit.

2. **Bitwise Manipulation:** The software manipulates individual bits within the 8-bit values to control which segments of the 7-segment display are illuminated. This allows the system to display digits from 0 to F.

3. **Shift Register Handling:** The display function takes care of loading these 8-bit values into the shift register and shifting the bits to display the desired digit on the 7-segment display.

### Timer Implementation

Accurate timing is essential for this system's functionality. To achieve this, the software leverages the built-in 8-bit timer/counter 0. Here's how it's implemented:

- **Timer Configuration:** The timer is set up in normal mode with a prescaler of 1024. This configuration ensures that the timer overflows at specific intervals, allowing the software to create precise delays.

- **Micro Delay:** A subroutine named `microDelay10ms` is used to create a 10-millisecond delay. This delay is achieved by configuring the timer to overflow at a specific count. The software waits for the timer's overflow flag to indicate that the desired time has elapsed.

### User Input Handling

The system provides two main mechanisms for user input: the Rotary Pulse Generator (RPG) and a mechanical pushbutton. Here's how each is handled:

- **RPG Input:** The software constantly monitors the input from the RPG to detect both clockwise (CW) and counterclockwise (CCW) rotations. When a complete turn is detected, the display is updated accordingly.

- **Pushbutton Input:** A mechanical pushbutton is used to submit user selections and initiate password verification. The software monitors the button's status, detects the duration of button presses, and responds accordingly. Short presses are used to input digits, while long presses trigger actions like hard resets or code verification.

## Conclusion

The Electronic Door Lock System project taught me the intricacies of microcontroller programming and electronic circuit design. Through the software components I was able to manage user interactions, including input from RPGs and pushbuttons, as well as managing delays. I learned how to interface with a 7-segment delay through assmebly, which was challenging but rewarding. 

This project served as a look under the hood of an actual product by learning its low level assembly implementation. Future improvements include interfacing with a locking mechanism to create a functional lock.

## Contributors
This project was developed and is currently maintained by Anshul Gowda and Rafael Ragel de la Tejera.

## Get in Contact:
 [Anshul Gowda's LinkedIn](https://www.linkedin.com/in/anshul-gowda)
<br />
Rafa Rangel de la Tejera's LinkedIn
<br />
