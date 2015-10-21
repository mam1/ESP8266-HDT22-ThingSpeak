

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
i = 1
temp[i], humdy[i] = readHDT22(4)
print("temperature <" .. temp[i] .. ">  humidity <" .. humdy[i] .. ">")

