-- ***************************************************************************
-- DHT11/21 with CSS STA Demo
--
-- Written by Martin Han
--
-- WTFPL license, You just DO WHAT THE F*** YOU WANT TO.
-- ***************************************************************************
--==================================================================
--Some boring but splendid CSS/HTML Codes
--==================================================================
CSS_Sheet=[[<html>
<head>
<meta http-equiv="refresh" content="10">
<style type="text/css">
#customers
  {
  font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;
  width:100%;
  border-collapse:collapse;
  }
#customers td, #customers th 
  {
  font-size:1em;
  border:1px solid #98bf21;
  padding:3px 7px 2px 7px;
  }
#customers th 
  {
  font-size:1.1em;
  text-align:left;
  padding-top:5px;
  padding-bottom:4px;
  background-color:#A7C942;
  color:#ffffff;
  }
#customers tr.alt td 
  {
  color:#000000;
  background-color:#EAF2D3;
  }
</style>
</head>
<body>
<table id="customers">
<tr>
<th>Input Source</th>
<th>Temperature</th>
<th>Humidity</th>
</tr>
<tr>
<td>DHT Temp&Humi Sensor</td>
<td>]]
CSS_2=[[ deg C</td>
<td>]]
CSS_3=[[ %</td>
</tr>
</table>
</body>
</html>
]]
--==================================================================
--Some lovely Lua code
--==================================================================
pin = 4 -- The pin you connected the DHTXX
wifi.sta.config("YOUR SSID","YOUR PASSWORD")
wifi.sta.connect()
dht = require("dht_lib")
tmr.alarm(0,1000,1, function()
if wifi.sta.setip() ~= nil then
print("NodeMcu's IP Address:"..wifi.sta.getip())
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
    print(payload) 
    dht.read(pin)
    conn:send(CSS_Sheet..dht.getTemperature()..CSS_2..dht.getHumidity()..CSS_3))
    end) 
end)
end
end)