version = "0.4"
CHANNEL_API_KEY = "ASBDBJSVR3PJNUBJ"
delay = 60000
flip = 0
done = true

-- setup I2c and connect display
function init_i2c_display()
    -- SDA and SCL can be assigned freely to available GPIOs
    local sda = 5 -- GPIO14
    local scl = 6 -- GPIO12
    local sla = 0x3c
    i2c.setup(0, sda, scl, i2c.SLOW)
    disp = u8g.ssd1306_128x64_i2c(sla)
    disp:begin()  
    disp:setFont(u8g.font_6x10)
    disp:setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
end

function postThingSpeak(f1,v1,f2,v2)
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
 
    connout:on("connection", function(connout, payloadout) 
        print ("Posting...");       
        connout:send("GET /update?api_key=ASBDBJSVR3PJNUBJ&field"
        .. f1
        .."=" 
        .. v1
        .. "&field"
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
 
--tmr.alarm(1, 10000, 1, function() postThingSpeak(0) end)


-- read sensor and write results to oled and console
function update()
    dht22 = require("dht22_min")
    local PIN
    local tt, hh
    local i = 0
  --alternate between 2 DHT22 sensors
    if flip == 0
    then
        flip = 1
        PIN = 2 -- GPIO4
    else
        flip = 0
        PIN =4 -- GPIO12
    end          
    print("\nget HDT22 data from pin "..PIN)  
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
  --display value strings on console
      print("    temperature "..tt .. "\n    humidity " ..hh.."\n")
    end   
  --release DHT22 module
    dht22 = nil
    package.loaded["dht22"]=nil
  --display sensor data on oled   
    print("    display sensor data on oled")
    disp:firstPage()
      repeat
        disp:drawStr(0, 0, "HDT22 test sensor")
        disp:drawStr(5, 20, "temperature "..tt.." deg F")
        disp:drawStr(5, 35, "   humidity "..hh.." %")
        until disp:nextPage() == false
  --send values to thingspeak
    print("    send data to thingspeak")
    done = false
    postThingSpeak(1,tt,3,hh)
    print("done with update")    
end
-- ***************************start main code **********************************
print("\n\nHDT22 sensor / oled u8g display / write to thingspeak  - version "..version.."\n")
print("initializing oled display")
init_i2c_display() 
print("running update every " .. delay .. "ms")
--tmr.alarm(0, delay, 1, function() update() end )
tmr.alarm(0, delay, 1, update)   
    



