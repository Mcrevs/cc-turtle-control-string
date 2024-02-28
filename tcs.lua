-- MIT License

-- Copyright (c) 2024 Mcrevs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local function i_action(argument)
    argument = argument or "minecraft:air"

    if not string.find(argument, ":") then
        argument = "minecraft:" .. argument
    end

    local has_block, data = turtle.inspect()
    if not has_block then
        return argument == "minecraft:air"
    end

    return data.name == argument
end

local function iu_action(argument)
    argument = argument or "minecraft:air"

    if not string.find(argument, ":") then
        argument = "minecraft:" .. argument
    end

    local has_block, data = turtle.inspectUp()
    if not has_block then
        return argument == "minecraft:air"
    end

    return data.name == argument
end

local function id_action(argument)
    argument = argument or "minecraft:air"

    if not string.find(argument, ":") then
        argument = "minecraft:" .. argument
    end

    local has_block, data = turtle.inspectDown()
    if not has_block then
        return argument == "minecraft:air"
    end

    return data.name == argument
end

local function s_action(argument)
    argument = tonumber(argument) or argument

    if type(argument) == "number" then
        return turtle.select(argument)
    end

    if not string.find(argument, ":") then
        argument = "minecraft:" .. argument
    end

    local slot = turtle.getSelectedSlot() - 1
    for i = 0, 15 do
        local check = (slot + i) % 16 + 1

        local item = turtle.getItemDetail(check)

        if item and item.name == argument then
            return turtle.select(check)
        end
    end

    return false
end

local defaut_actions = {
    l = turtle.turnLeft,
    r = turtle.turnRight,
    f = turtle.forward,
    b = turtle.back,
    u = turtle.up,
    d = turtle.down,
    m = turtle.dig,
    mu = turtle.digUp,
    md = turtle.digDown,
    p = turtle.place,
    pu = turtle.placeUp,
    pd = turtle.placeDown,
    c = turtle.suck,
    cu = turtle.suckUp,
    cd = turtle.suckDown,
    o = turtle.drop,
    ou = turtle.dropUp,
    od = turtle.dropDown,

    i = i_action,
    iu = iu_action,
    id = id_action,
    s = s_action,
}

---Convert the turtle action string into a intermidiate format.
---@param str string The input sting to be interpreted.
---@return table actions The intermediate format
local function interpretString(str, first)
    if first == nil then
        first = true
    end

    local sub_statements = {}
    for statement in string.gmatch(str, "(%b{})") do
        sub_statements[#sub_statements+1] = string.sub(statement, 2, #statement - 1)
    end
    str = string.gsub(str, "%b{}", " $ ")

    local arguments = {}
    for statement in string.gmatch(str, "(%b())") do
        arguments[#arguments+1] = string.sub(statement, 2, #statement - 1)
    end
    str = string.gsub(str, "%b()", " %% ")

    str = string.gsub(str, "/", " / ")

    local sub_statement_index = 1
    local argument_index = 1
    local actions = {}
    for statement_string, argument_string, repititions, forcefulnes, modifier in string.gmatch(str, "([%l/$]+)%s*(%%?)%s*(%d*)%s*([%.%?]?)%s*([%^`]?)") do
        local statement
        if statement_string == "$" then
            statement = interpretString(sub_statements[sub_statement_index], false)
            sub_statement_index = sub_statement_index + 1
        else
            statement = statement_string
        end

        local argument
        if argument_string == "%" then
            argument = arguments[argument_index]
            argument_index = argument_index + 1
        else
            argument = argument_string
        end
        if argument == "" then
            argument = nil
        end

        actions[#actions+1] = {
            action = statement,
            argument = argument,
            repititions = tonumber(repititions) or 1,
            forcefulnes = forcefulnes,
            modifier = modifier,
        }
    end

    if first then
        return {
            action = actions,
            argument = "",
            repititions = 1,
            forcefulnes = "",
            modifier = "",
        }
    else
        return actions
    end
end

---Perform a single action from the interpreted actions from the state provided, if nil is provided it performs the first action.
---@param action table The interpreted action to be executed.
---@param state table The current state of the step function, may be modified.
---@return boolean complete Weather or not the full action has been completed. Running after complete has undefined behaviour.
---@return table state The new state for the step function.
---@return boolean successful Weather or not the action is currently sucessful, Unintuitive meaning when the action is not complete.
local function step(action, state)
    state = state or {step = 1, repitition = 1, successful = true, state = nil}
    local complete = false

    if type(action.action) == "table" then
        local sub_complete, sub_state, sub_successful = true, nil, true

        if action.action[state.step].action == "/" then
            if not state.successful then
                if action.forcefulnes == "." then
                    state.step = 1
                    state.successful = true
                elseif action.forcefulnes == "?" then
                    complete = true
                else
                    state.step = 1
                    state.repitition = state.repitition + 1
                end
            else
                state.step = state.step + 1
            end
        else
            sub_complete, sub_state, sub_successful = step(action.action[state.step], state.state)
            state.state = sub_state
            if sub_complete then
                state.state = nil
                state.successful = state.successful and sub_successful
                state.step = state.step + 1
            end
        end

        if state.step > #action.action then
            state.step = 1
            if action.forcefulnes == "." and not state.successful then
                state.successful = true
            elseif action.forcefulnes == "?" and not state.successful then
                complete = true
            else
                state.repitition = state.repitition + 1
            end
        end
    else
        local _, y = term.getCursorPos()
        term.setCursorPos(1, y)
        term.clearLine()
        if action.argument then
            term.write(action.action .. " (" .. action.argument .. ") ")
        else
            term.write(action.action .. " ")
        end

        if defaut_actions[action.action] then
            local sucessful, sucessful_action = pcall(
                defaut_actions[action.action], action.argument
            )

            sucessful = sucessful and sucessful_action

            if sucessful then
                term.write("Success!")
            else
                term.write("Failure.")
            end
            state.successful = state.successful and sucessful
        else
            state.successful = state.successful and false
        end

        if action.forcefulnes == "." and not state.successful then
            state.successful = true
        elseif action.forcefulnes == "?" and not state.successful then
            complete = true
        else
            state.repitition = state.repitition + 1
        end
    end
    complete = complete or state.repitition > action.repititions

    local sucess = true
    if complete then
        if action.modifier == "^" then
            sucess = state.successful
        elseif action.modifier == "`" then
            sucess = not state.successful
        end
    end
    return complete, state, sucess
end

return {
    interpretString = interpretString,
    step = step
}
