version = "0.0"
delay = 6000
flip = 0

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

function sendTemp(ttt)
    print("    Send temperature data to thingspeak.com")
    print("ttt = "..ttt)
    print("      GET /update?key=ASBDBJSVR3PJNUBJ&field4="..(9 * ttt / 50 + 32).."."..(9 * ttt / 5 % 10).." HTTP/1.1")
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) print(payload) end)
--    print("payload = "..payload)
    -- api.thingspeak.com 184.106.153.149
    conn:connect(80,'184.106.153.149')
    conn:send("GET /update?key=ASBDBJSVR3PJNUBJ&field4="..(9 * ttt / 50 + 32).."."..(9 * ttt / 5 % 10).." HTTP/1.1") 
    conn:send("Host: api.thingspeak.com\r\n") 
    conn:send("Accept: */*\r\n") 
    conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
    conn:send("\r\n")
    conn:on("sent",function(conn) print("    Closing connection") conn:close() end)
    conn:on("disconnection", function(conn) print("    Got disconnection...")  end)  

end

function tp()
    print("\n*********************************************************\n")
end

function sendHumdy(hhh,ttt)
    print("    Send humidity data to thingspeak.com")
    print("      GET /update?key=ASBDBJSVR3PJNUBJ&field3="..((hhh - (hhh % 10)) / 10).."."..(hhh % 10).." HTTP/1.1")
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) print(payload) end)
--    print("payload = "..payload)
    -- api.thingspeak.com 184.106.153.149
    conn:connect(80,'184.106.153.149') 
    conn:send("GET /update?key=ASBDBJSVR3PJNUBJ&field3="..((hhh - (hhh % 10)) / 10).."."..(hhh % 10).." HTTP/1.1\r\n") 
    conn:send("Host: api.thingspeak.com\r\n") 
    conn:send("Accept: */*\r\n") 
    conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
    conn:send("\r\n")
    conn:on("sent",function(conn) print("    Closing connection") conn:close()  end)
    conn:on("disconnection", function(conn) print("    Got disconnection...") sendTemp(ttt) end)

end 

-- read sensor and write results to oled and console
function update()
    local PIN = 2 --  oled data pin, GPIO2
    local tt, hh

    if flip == 0
    then
        flip = 1
        PIN = 2
    else
        flip = 0
        PIN =4
    end
          
    print("\nget HDT22 data from pin "..PIN)  
    dht22 = require("dht22_min")
    dht22.read(PIN)
    t = dht22.getTemperature()
    h = dht22.getHumidity()
    if h == nil then
      print("Error reading from DHT22")
    else
      -- temperature only integer version:
      tt = ("    Temperature: "..(9 * t / 50 + 32).."."..(9 * t / 5 % 10).." deg F")
      hh = ("    Humidity: "..((h - (h % 10)) / 10).."."..(h % 10).."%")
      -- humidity floating point and integer version
      print(tt .. "\n" ..hh)
    end
    
    -- release DHT22 module
    dht22 = nil
    package.loaded["dht22"]=nil
        
--    sendTemp(t,h)
    
    print("    display sensor data on oled")
    disp:firstPage()
      repeat
        disp:drawStr(0, 0, "HDT22 test sensor")
        disp:drawStr(0, 20, tt)
        disp:drawStr(0, 35, hh)
        until disp:nextPage() == false
--        print("looping")
 --       tmr.delay(5000)
         -- re-trigger Watchdog!
 --       tmr.wdclr()

--    sendHumdy(h,t)
    sendTemp(t)
end

print("initializing oled display")
--tp()
init_i2c_display() 
print("running update every " .. delay .. "ms")
tmr.alarm(0, delay, 1, function() update() end )
    
    



