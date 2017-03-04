local maxTimestampOffset = 5

local connections = {}
local interfaces = {}

local msgIDs, msgIDLookup = {}, {}

local function forceDetachModem(s)
    if interfaces[s] then
        interfaces[s] = nil
    end
end

local function attachModem(s)
    if peripheral.getType(s) == "modem" then
        interfaces[s] = {
            wireless = peripheral.call(s, "isWireless"),
            connections = {}
        }
    end
end

local function proccessEvents(e)
    if e[1] == "peripheral" and peripheral.getType(side) == "modem" then
        local side = e[2]
        forceDetachModem(side)
        attachModem(side)
    elseif e[1] == "peripheral_detach" and peripheral.getType(side) == "modem" then
        forceDetachmodem(e[2])
    elseif e[1] == "modem_message" and interfaces[e[2]] and type(e[5]) == "table" and e[5].connectionID and type(e[5].timestamp) == "number" and type(e[5].msgID) == "number" then
        local timeDifference = ((os.time() + 24000 * os.day()) - e[5].timestamp
        if timeDifference < 0 or timeDfference >= (maxTimestampOffset * 20) then
            return
        end
        local msgIDsForTimestamp = msgIDs[e[5].timestamp]
        if not msgIDsForTimestamp or not msgIDsForTimestamp[e[5].msgID] then
            msgIDs[e[5].timestamp] = msgIDsForTimestamp or {}
            msgIDs[e[5].timestamp][e[5].msgID] = true
            msgIDLookup[os.startTimer(maxTimestampOffset + 0.2)] = {e[5].timestamp, e[5].msgID}
        else
            return
        else
        local rawMsg, cons = e[5], interfaces[e[2]].connections
        local con = cons[rawMsg.connectionID]
        if con then
            if con.key then
                local msg = AESDecrypt(rawMsg.data)
                if msg then
                    local header = rawMsg.timestamp .. ":" .. rawMsg.msgID
                    msg = textutils.unserilize(msg)
                    os.queueEvent("secure_message", e[2], e[3], e[4], msg, rawMsg.connectionID, e[6])
                end
                
