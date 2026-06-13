# Car-Game

Car-Game is a car racing and obstacle avoidance game developed in Assembly Language for the Intel 8088 architecture. The project demonstrates low-level game development concepts including graphics rendering, keyboard input handling, collision detection, score tracking, and game loop implementation.

## Overview

The game begins with a start screen displaying basic information and instructions. The player can start the game by pressing the **Space** key. During gameplay, the objective is to control the player's car, avoid incoming traffic, and collect bonus coins to increase the score.

As the game progresses, the player must survive by avoiding collisions with other vehicles while collecting as many coins as possible. When a collision occurs, the game ends and a game over screen is displayed with an option to restart and play again.

## Features

* Developed entirely in Assembly Language
* Designed for Intel 8088 architecture
* Interactive start screen
* Player-controlled car movement
* Incoming obstacle vehicles
* Collectible bonus coins
* Real-time score tracking
* Collision detection system
* Game over screen
* Restart functionality

## Controls

| Key        | Action                           |
| ---------- | -------------------------------- |
| Space      | Start the game                   |
| Arrow Keys | Move the car                     |
| R          | Restart the game after Game Over |

## Requirements

* DOSBox
* NASM (Netwide Assembler)

## Running the Game

### Compile and Run

1. Open DOSBox and mount the project directory:

```dos
mount c path\to\Car-Game
c:
```

2. Assemble the source code:

```dos
nasm -f bin CarGame.asm -o CarGame.com -l CarGame.lst
```

3. Run the game:

```dos
CarGame.com
```

> Replace the filenames with the actual names used in your project if they are different.

## Learning Objectives

This project was created to explore and practice:

* Assembly Language programming
* Intel 8088 architecture
* Low-level graphics programming
* Keyboard input handling
* Collision detection techniques
* Game loop design
* Memory and hardware interaction

## Technologies Used

* Assembly Language
* Intel 8088 Architecture
* NASM
* DOSBox

## Author

Developed as an educational project to demonstrate game development concepts using Assembly Language and low-level system programming.
