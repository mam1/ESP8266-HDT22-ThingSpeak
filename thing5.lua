--    Demo thingspeak.com client with sensor DHT11/22
--    Tested with Lua NodeMCU 0.9.5 build 20150127 floating point !!!
-- 1. Flash Lua NodeMCU to ESP module.
-- 2. Set in program ts_fpmdht.lua humidity sensor type. This is parameter typeSensor="dht11" or "dht22".
-- 3. Set in program ts_fpmdht.lua your thingspeak.com write API key
-- 4. You can rename the program ts_fpmdht.lua to init.lua
-- 5. Load program ts_fpmdht.lua and dht.lua to ESP8266 with LuaLoader
-- 6. HW reset module
-- 7. Login module to your AP - wifi.setmode(wifi.STATION),wifi.sta.config("yourSSID","yourPASSWORD")
-- 8. Run program ts_fpmdht.lua - dofile(ts_fpmdht.lua)
-- 9. The sensor is repeatedly read and data are send to api.thingspeak.com every minute.
--10. Minimal period for data send to api.thingspeak.com is 15s
--    The author of the program module dht.lua for reading DHT sensor is Javier Yanez
--    The author of the http client part is Peter Jennings

sensorType="dht22"             -- set sensor type dht11 or dht22
WRITEKEY="ASBDBJSVR3PJNUBJ"  -- set your thingspeak.com key
PIN = 4                     --  data pin, GPIO2
--    wifi.setmode(wifi.STATION)
--    wifi.sta.config("FrontierHSI","")
--    wifi.sta.connect()
    tmr.delay(1000000)
    humi=0
    temp=0
    fare=0
--load DHT module and read sensor
function ReadDHT()
    dht=require("dht22")
    dht.read(PIN)
    if sensorType=="dht11"then
    humi=dht.getHumidity()/256
    temp=dht.getTemperature()/256
    else
    humi=dht.getHumidity()/10
    temp=dht.getTemperature()/10
    end
    fare=(temp*9/5+32)
    print("Humidity:    "..humi.."%")
    print("Temperature: "..temp.." deg C")
    print("Temperature: "..fare.." deg F")
    -- release module
    dht=nil
    package.loaded["dht"]=nil
end
-- send to https://api.thingspeak.com
function sendTS(humi,temp)
conn = nil
conn = net.createConnection(net.TCP, 0)
conn:on("receive", function(conn, payload)success = true print(payload)end)
conn:on("connection",
    function(conn, payload)
    print("Connected")
    conn:send('GET /update?key='..WRITEKEY..'&field1='..temp..'&field3='..humi..'HTTP/1.1\r\n\
    Host: api.thingspeak.com\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n')end)
conn:on("disconnection", function(conn, payload) print('Disconnected') end)
conn:connect(80,'184.106.153.149')
end
ReadDHT()
sendTS(humi,temp)
tmr.alarm(1,10000,1,function()ReadDHT()sendTS(humi,temp)end)