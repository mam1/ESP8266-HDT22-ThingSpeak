version = "0.6"
KEY = "1Y898KJ1K8YQJTU4"
PINS = {2,4}  -- HDT22 sensor's data pins
delay = 10000
 
-- *************** read sensor return temp and humidity converted to text ****************
function readHDT22(pin)
    print("\ngeting HDT22 data from pin "..pin)

    dht22 = require("dht22_min")
    local t,h,ttt,hhh
    t = 200
    h = 100
 --   dht22.read(pin)
 --   t = dht22.getTemperature()
--    print("t = <"..t..">")
--    h = dht22.getHumidity()
--    if h == nil then
--      print("Error reading from DHT22")
--    else
  --convert values to text strings
      print("converting to string 1, t = " .. t)
--      ttt = ((9 * t / 50 + 32).."."..(9 * t / 5 % 10))
        ttt = "34.5"
      print("converting to string 2")
--      hhh = (((h - (h % 10)) / 10).."."..(h % 10))
        hhh = "23.9"
      print("converting to string 3")
--    end   
  --release DHT22 module
  print("about to release module")
--    dht22 = nil
--    package.loaded["dht22"]=nil 
--    print("module is released") 
  --return temperature and humidly text strings
  return ttt, hhh
end

-- *************** send readings to ThingSpeak channel ****************************
-- function postThingSpeak(v1,v2,v3,v4,v5,v6)
function postThingSpeak(v1,v2,v3,v4)

    local command
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    command = "GET /update?api_key="
        .. KEY
        .. "&field1=("
        .. v1
        .. ")&field2=("
        .. v2
        .. ")&field3=("
        .. v3
        .. ")&field4=("
        .. v4
        .. ")"
--        .. "&field5="
--        .. v5
--        .. "&field6="
--        .. v6
        .. " HTTP/1.1\r\n"
        .. "Host: api.thingspeak.com\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n"
    print (command)
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
    connout:on("connection", function(connout, payloadout) 
        print ("Posting...");       
        connout:send(command)
    end)
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        collectgarbage(); 
    end)
    connout:connect(80,'api.thingspeak.com')
end
    
-- *************** read sensors ************************************************
function update()
    local i = 1
    local ta
    local ha

    local tt = {}
    local hh = {}

    
    print("read sensor " .. i);

 --       ta, ha = readHDT22(2)
        ta = "34.2"
        ha = "77.8"
        tt[i] = ta
        hh[i] = ha
        print("    pin " .. PINS[i] .. " - temperature ".. tt[i] .. ",  humidity " .. hh[i]) 
        i = i + 1
   print("read sensor " .. i);
--        ta, ha = readHDT22(4)
        ta = "34.2"
        ha = "77.8"
        tt[i] = ta
        hh[i] = ha
        print("    pin " .. PINS[i] .. " - temperature ".. tt[i] .. ",  humidity " .. hh[i]) 

--    tt[3] = 50
--    hh[3] = 60
  --send values to thingspeak
    print("    send data to thingspeak")
    postThingSpeak("44.4","22.2","66.6","35.5")
    print("update complete")    
end

-- ***************************start main code **********************************
print("\n\nHDT22 sensor / write to thingspeak  - version "..version.."\n") 
print("running update every " .. delay .. "ms")
tmr.alarm(0, delay, 1, function() update() end )
    
    



