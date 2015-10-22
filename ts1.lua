PINS = {4,2}


function readHDT22(pin)
--    local ttt, hhh
    ttt = "33.3"
    hhh = "55.5"
    print("readHTD22 called - geting data from pin "..pin)
    dht22 = require("dht22_min")
    dht22.read(pin)
    t = dht22.getTemperature()
    print("t = <"..t..">")
    h = dht22.getHumidity()
    print("h = <"..h..">")    
    if ((h == nil) or (t == nil)) then
       print("Error reading from DHT22")
  --   else
  -- --convert values to text strings
         print("HDT22 read suceeded")
  --     print("converting to string 1, t = " .. t)
  --     ttt = ((9 * t / 50 + 32).."."..(9 * t / 5 % 10))
  --     print("converted string <"..ttt..">")
  --     print("converting to string 2, h = "..h)
  --     hhh = (((h - (h % 10)) / 10).."."..(h % 10))
  --     print("converted string <"..hhh..">")
     end   
  -- --release DHT22 module
  -- print("about to release module")
  --   dht22 = nil
  --   package.loaded["dht22"]=nil 
  --   print("module is released") 
  --return temperature and humidly text strings
  return ttt, hhh
end

for i, pin in ipairs(PINS) do
    print("\ni="..i.." pin="..pin)
    x, y = readHDT22(pin)
    print("temperature <" .. x .. ">  humidity <" .. y .. ">")
end
