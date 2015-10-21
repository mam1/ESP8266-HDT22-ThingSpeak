version = "0.6"
KEY = "1Y898KJ1K8YQJTU4"
PINS = {2,4}  -- HDT22 sensor's data pins
delay = 10000
 
-- *************** read sensor return temp and humidity converted to text ****************
function readHDT22(pin)
    print("\ngeting HDT22 data from pin "..pin)
    dht22 = require("dht22_min")
    local t,h,ttt,hhh
    dht22.read(pin)
    print("read complete")

    t = dht22.getTemperature()
    print("t = <"..t..">")
    h = dht22.getHumidity()
    if h == nil then
      print("Error reading from DHT22")
    else
  --convert values to text strings
      print("converting to string 1, t = " .. t)
      ttt = ((9 * t / 50 + 32).."."..(9 * t / 5 % 10))
      print("converting to string 2")
      hhh = (((h - (h % 10)) / 10).."."..(h % 10))
      print("converting to string 3")
    end   
  --release DHT22 module
  print("about to release module")
    dht22 = nil
    package.loaded["dht22"]=nil 
    print("module is released") 
  --return temperature and humidly text strings
  return ttt, hhh
end

-- *************** send readings to ThingSpeak channel ****************************
-- function postThingSpeak(v1,v2,v3,v4,v5,v6)
function postThingSpeak(v1,v2,v3,v4)
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
    connout:on("connection", function(connout, payloadout) 
        print ("Posting...");       
        connout:send("GET /update?api_key="
        .. KEY
        .. "&field1="
        .. v1
        .. "&field2="
        .. v2
        .. "&field3="
        .. v3
        .. "&field4="
        .. v4
--        .. "&field5="
--        .. v5
--        .. "&field6="
--        .. v6
        .. " HTTP/1.1\r\n"
        .. "Host: api.thingspeak.com\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n")
    end)
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        collectgarbage(); 
    end)
    connout:connect(80,'api.thingspeak.com')
end
    
-- *************** read sensors ************************************************
function update()
    dht22 = require("dht22_min")
    local i = 1
    local tt = {"",""}
    local hh = {"",""} 

    while PINS[i] ~= nil do
        tt[i], hh[i] = readHDT22(PINS[i])
        print("    pin " .. PINS[i] .. " - temperature ".. tt[i] .. ",  humidity " .. hh[i]) 
        i = i + 1
    end
--    tt[3] = 50
--    hh[3] = 60
  --send values to thingspeak
    print("    send data to thingspeak")
    postThingSpeak(tt[1],hh[1],tt[2],hh[2])
    print("update complete")    
end

-- ***************************start main code **********************************
print("\n\nHDT22 sensor / write to thingspeak  - version "..version.."\n") 
print("running update every " .. delay .. "ms")
tmr.alarm(0, delay, 1, function() update() end )
    
    



