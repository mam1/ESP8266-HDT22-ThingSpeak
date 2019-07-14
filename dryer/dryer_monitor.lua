version = "1.0.0"
CHANNEL_API_KEY = "BNJG6HPJ3LFG2B5X"
delay = 90000
PIN = 7
TEMPF = 1
HUMIDF = 2

--get data from DHT22 sensor on <pin>
function rdDHT22(pin)
    -- print(" ESP8266: reading pin ".. pin)
    --read sensor
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
    -- Float firmware using this example
        temp = (temp*9)/5 + 32
        -- print(" ESP8266: DHT Temperature:"..temp.."; ".."Humidity:"..humi)
        
    elseif status == dht.ERROR_CHECKSUM then
        print( " *** DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( " *** DHT timed out." )
    end
    --release DHT22 module
    dht22 = nil
    package.loaded["dht22"]=nil
    return temp, humi 
end

--post data <value> to ThingSpeak api key <key>, field <field>
function post(key,field,value)
    -- print("    posting pin 7 data to field "..field.." value is "..value)   
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("    Posted OK");
        end
    end)
    connout:on("connection", function(connout, payloadout) 
        -- print ("    Posting...");       
        connout:send("GET /update?api_key="
        .. key
        .. "&field"
        .. field
        .."=" 
        .. value
        .. " HTTP/1.1\r\n"
        .. "Host: api.thingspeak.com\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n")
    end)
    connout:on("disconnection", function(connout, payloadout)
        -- connout:close();
        collectgarbage(); 
    end)
    connout:connect(80,'api.thingspeak.com')
end

function tupdate()
	local t, h

    t, h = rdDHT22(PIN)
    print("  DHT22 read -> t "..t.."  h "..h)
    print("    posting temperature "..tostring(t))
    post(CHANNEL_API_KEY,1,tostring(t))

	local htimer = tmr.create()
	htimer:register(delay/4, tmr.ALARM_SINGLE, hupdate)
	htimer:start()
end

function hupdate()

	local t, h

    t, h = rdDHT22(PIN)
    print("  DHT22 read -> t "..t.."  h "..h)
    print("    posting humidity "..tostring(h))
    post(CHANNEL_API_KEY,2,tostring(h))

end

-- ************** start main loop ********************

print("\n\n*** dryer_monitor.lua  version "..version.." ***\n")
print("  reading pin 7  \n  posting data to ThingSpeak api key "..CHANNEL_API_KEY)
print("  running update every " .. delay .. "ms\n\n")
-- tmr.alarm(0, delay, 1, update) 
-- update()

local mytimer = tmr.create()
mytimer:register(delay, tmr.ALARM_AUTO, tupdate)
mytimer:start()

