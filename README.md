# Turtle Control String

Turtle control strings consist of actions and modifiers. Actions can be one or multiple (defined using `{` and `}` to group actions) of the predefined actions. Modifiers can specify how an action will be completed (weather or not it must be sucessful), how many times it should be repeated and how it effects the sucessfulness of any enclosing actions.

The main way to run a string is by running the step function untill it is complete. This allows for easy saving of the current turtle state so with an adiquate runner program the turtle can be unloaded and when its re-loaded it can resume where it was. 

## Actions

| Action          | Arguments        | Description                                                                                           | Function                                                             |
| --------------- | ---------------- | ----------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `l`             |                  | Make the turtle turn left                                                                             | [turnLeft()](https://tweaked.cc/module/turtle.html#v:turnLeft)       |
| `r`             |                  | Make the turtle turn right                                                                            | [turnRight()](https://tweaked.cc/module/turtle.html#v:turnRight)     |
| `f`             |                  | Make the turtle move forward                                                                          | [forward()](https://tweaked.cc/module/turtle.html#v:forward)         |
| `b`             |                  | Make the turtle move backwards                                                                        | [back()](https://tweaked.cc/module/turtle.html#v:back)               |
| `u`             |                  | Make the turtle move up                                                                               | [up()](https://tweaked.cc/module/turtle.html#v:up)                   |
| `d`             |                  | Make the turtle move down                                                                             | [down()](https://tweaked.cc/module/turtle.html#v:down)               |
| `m`             |                  | Make the turtle mine the block in front of it                                                         | [dig()](https://tweaked.cc/module/turtle.html#v:dig)                 |
| `mu`            |                  | Make the turtle mine the block above it                                                               | [digUp()](https://tweaked.cc/module/turtle.html#v:digUp)             |
| `md`            |                  | Make the turtle mine the block below it                                                               | [digDown()](https://tweaked.cc/module/turtle.html#v:digDown)         |
| `p`             |                  | Make the turtle place the selected block in front of it                                               | [place()](https://tweaked.cc/module/turtle.html#v:place)             |
| `pu`            |                  | Make the turtle place the selected block above it                                                     | [placeUp()](https://tweaked.cc/module/turtle.html#v:placeUp)         |
| `pd`            |                  | Make the turtle place the selected block below it                                                     | [placeDown()](https://tweaked.cc/module/turtle.html#v:placeDown)     |
| `c`             |                  | Make the turtle pick up a stack of blocks from in front of it                                         | [suck()](https://tweaked.cc/module/turtle.html#v:suck)               |
| `cu`            |                  | Make the turtle pick up a stack of blocks from above it                                               | [suckUp()](https://tweaked.cc/module/turtle.html#v:suckUp)           |
| `cd`            |                  | Make the turtle pick up a stack of blocks from below it                                               | [suckDown()](https://tweaked.cc/module/turtle.html#v:suckDown)       |
| `o`             |                  | Make the turtle drop the selected stack of items in front of it                                       | [drop()](https://tweaked.cc/module/turtle.html#v:drop)               |
| `ou`            |                  | Make the turtle drop the selected stack of items above it                                             | [dropUp()](https://tweaked.cc/module/turtle.html#v:dropUp)           |
| `od`            |                  | Make the turtle drop the selected stack of items below it                                             | [dropDown()](https://tweaked.cc/module/turtle.html#v:dropDown)       |
| `i`             | `name`           | Check if the block in front of the turtle has the name `name`                                         | [inspect()](https://tweaked.cc/module/turtle.html#v:inspect)         |
| `iu`            | `name`           | Check if the block above of the turtle has the name `name`                                            | [inspectUp()](https://tweaked.cc/module/turtle.html#v:inspectUp)     |
| `id`            | `name`           | Check if the block below front of the turtle has the name `name`                                      | [inspectDown()](https://tweaked.cc/module/turtle.html#v:inspectDown) |
| `s`             | `name` or `slot` | Select the next apperance of the item with name `name` or the slot `slot` from the turtle's inventory | [select()](https://tweaked.cc/module/turtle.html#v:select)           |
| `/`             |                  | Evaluate parent forcefulness modifier early                                                           |                                                                      |
| `{` actions `}` |                  | Create an action from the actions enclosed in the brackets                                            |                                                                      |

If argument is unspecified for a default turtle function in the table above then the argument is passed into the function.

## Modifiers

| Repeat modifier | Description                                                       |
| --------------- | ----------------------------------------------------------------- |
| `number`        | The action is repeated `number` number times, once if unspecified |

| Forcefulness modifier | Description                                                      |
| --------------------- | ---------------------------------------------------------------- |
|                       | The action will continue if it has failed                        |
| .                     | The action will be repeated if it failed until it is successful. |
| ?                     | The action can stop early from repitions if the value is false   |

| Sucesfulnes modifier | Description                                                                                       |
| -------------------- | ------------------------------------------------------------------------------------------------- |
|                      | The succesfilnes of the action does not effect the succesfulness of the enclosing action          |
| ^                    | The succesfulnes of the action is anded with the sucessfulness of the enclosing action            |
| \`                   | The not of the succesfulnes of the action is anded with the sucessfulness of the enclosing action |

Note, the order of the tables must be the order of specified modifiers and at most one modifier can be used from each table.

## Examples

```
{u^ iu (air)^}100?
```
Makes the turtle go up a maximum of 100 blocks but the turtle will stop early if it fails to move up or the block above it is not air.



```
{{f^ id (air)^ / s (cobble_stone). pd.}10?^ / {r2^ / {s (torch)^ / p} l2.}}20?
```
Builds a cobblestone bridge across a gap of maximum width 200, placing torches every 10 blocks if the turtle has any.

`{f^ id (air)^ / s (cobble_stone). pd.}10?^ /`: The turtle tries to move forward one block, it then checks if the block below it is air, if it successfully moves forward and the block below it is air then it continues otherwise it will stop the whole program. If the turtle continues then it must select a cobblestone and place the cobblestone below it. This is repeated 10 times so the turtle places 10 blocks. `{r2^ / {s (torch)^ / p} l2.}` The turtle then tries to turn arround, if it fails then it will just place the next 10 blocks otherwise it will try to select a torch, if it can't it will turn back around and continue, if it can it will first place the torch before turning around. This whole thing is repeated 20 times unless the turtle can't move forward or detects something other than air below it.

```
{{m r. f. l. i (air)`}64? d. {i (air)` / r. f. l.}64? {m l. f. r. i (air)`}64? d. {i (air)` / l. f. r.}64?}10
```
Trim a flat surface of a cliff in a zig zag pattern that is exactly 10 blocks tall and at most 64 blocks wide from the top to the botom.

```
{{m f. mu {id (air)` / s (cobblestone). pd.}}10 s (torch). r. {pu` / r. p. l.} l.}100
```
Dig a tunnle sutible for mining, placing a torch every 10 blocks and building a cobblestone bridge across air gaps.

## Instalation

Run the following command in the terminal.
```
wget https://raw.githubusercontent.com/Mcrevs/cc-turtle-control-string/main/tcs.lua
```

## Implementation

Below is a simple script that can be used to run an action.
```lua
local tcs = require("tcs")

local actions = tcs.interpretString("{{m f. mu {id (air)` / s (cobblestone). pd.}}10 s (torch). r. pu. l.}2")
local state
repeat
    local complete, successful
    complete, state, successful = tcs.step(actions, state)
until complete

print("") --Make next text input on new line
```

## Features
 - [x] Run a tcs using a step function with a saveable state
 - [ ] String validation function
 - [ ] Fuel requirement estimation
 - [ ] Resauce requirement estimation
 - [ ] Progress estimation