version = "0.5"
delay = 60000
done = true

-- send readings to ThingSpeak chanel
function postThingSpeak(f1,v1,f2,v2,f3,v3,f4,v4)
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
    connout:on("connection", function(connout, payloadout) 
        print ("Posting...");       
        connout:send("GET /update?api_key=1Y898KJ1K8YQJTU4&field"
        .. f1
        .."=" 
        .. v1
        .. "&field"
        .. f2
        .. "="
        .. v2
        "&field"
        .. f2
        .. "="
        .. v2
        "&field"
        .. f2
        .. "="
        .. v2
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
 
-- read sensor
function readHDT22(pin)
    dht22 = require("dht22_min")
    local t,h,tt,hh
    print("\ngeting HDT22 data from pin "..pin)
    --read sensor
    dht22.read(PIN)
    t = dht22.getTemperature()
    h = dht22.getHumidity()
    if h == nil then
      print("Error reading from DHT22")
    else
  --convert values to text strings
      tt = ((9 * t / 50 + 32).."."..(9 * t / 5 % 10))
      hh = (((h - (h % 10)) / 10).."."..(h % 10))
    end   
  --release DHT22 module
    dht22 = nil
    package.loaded["dht22"]=nil  
  --return temperature and humidy text strings
  return tt, hh
end

-- read sensors
function update()
    dht22 = require("dht22_min")
    local pins,fields
    local tt, hh

  --read a list of sensor pins
    pins = {1, 2, 4}
    fields = {
    
    iter = list_iter(pins)    -- creates the iterator
    while true do
      local pin = iter(pins)   -- calls the iterator
      if pin == nil then break end
        tt, hh = readHDT22(pin)
      --display value strings on console
        print("    pin "..pin.." - temperature "..tt .. "\n    humidity " ..hh) 
  --send values to thingspeak
    print("    send data to thingspeak")
    done = false
    postThingSpeak(1,tt,3,hh)
    print("done with update")    
end
-- ***************************start main code **********************************
print("\n\nHDT22 sensor / write to thingspeak  - version "..version.."\n") 
print("running update every " .. delay .. "ms")
tmr.alarm(0, delay, 1, function() update() end )
    
    



