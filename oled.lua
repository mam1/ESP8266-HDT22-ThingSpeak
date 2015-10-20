version = "0.0"
delay = 6000

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

-- read sensor and write results to oled and console
function update()
    local PIN = 4 --  oled data pin, GPIO2
    local tt, hh
--    print("initializing oled display")
--    init_i2c_display()   
    print("get HDT22 data")   
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
      print(tt .. "\n" ..hh .. "\n")
    end
    
    -- release DHT22 module
    dht22 = nil
    package.loaded["dht22"]=nil
    
    print("display sensor data on oled\n")
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
end

print("initializing oled display")
init_i2c_display() 
print("running update every " .. delay .. "ms")
tmr.alarm(0, delay, 1, function() update() end )
    
    



