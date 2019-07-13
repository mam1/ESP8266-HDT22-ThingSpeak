-- --init.lua

-- version="1.0.1"
-- ip="192.168.254.205"

-- print('\n *** dryer_monitor_init.lua ver 2.0')

-- wifi.setmode(wifi.STATION);
-- --connect to Access Point (DO NOT save config to flash)
-- station_cfg={}
-- station_cfg.ssid="FrontierHSIC"
-- station_cfg.pwd=""
-- station_cfg.save=false
-- wifi.sta.config(station_cfg)
-- wifi.sta.sethostname("dryer")
-- wifi.sta.autoconnect(1)

-- print('    set mode=STATION (mode='..wifi.getmode()..')')
-- print('    MAC: ',wifi.sta.getmac())
-- print('    chip: ',node.chipid())
-- print('    heap: ',node.heap())
-- print(' ')

-- local mytimer = tmr.create()
-- mytimer:register(6000, tmr.ALARM_SINGLE, function (t) print("expired"); t:unregister() end)
-- mytimer:start()

-- tmr.alarm(1,1000,1,function()
--   if wifi.sta.getip()==nil then
--      print("    IP unavailable, waiting")
--   else
--      tmr.stop(1)
--      print("\n    Config done, IP is "..wifi.sta.getip())
--      print("    hostname: "..wifi.sta.gethostname())
--      print("    ESP8266 mode is: " .. wifi.getmode())
--      print("    MAC address is: " .. wifi.ap.getmac())
--      print("\n    starting sensor read loop")
--      print("    sending data to: " ..ip)
--      dofile("dryer_monitor.lua")
--   end
-- end)

-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
dofile("credentials.lua")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        -- the actual application is stored in 'application.lua'
        dofile("dryer_monitor.lua")
    end
end

-- Define WiFi station event callbacks
wifi_connect_event = function(T)
  print("Connection to AP("..T.SSID..") established!")
  print("Waiting for IP address...")
  if disconnect_ct ~= nil then disconnect_ct = nil end
end

wifi_got_ip_event = function(T)
  -- Note: Having an IP address does not mean there is internet access!
  -- Internet connectivity can be determined with net.dns.resolve().
  print("Wifi connection is ready! IP address is: "..T.IP)
  print("Startup will resume momentarily, you have 3 seconds to abort.")
  print("Waiting...")
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
end

wifi_disconnect_event = function(T)
  if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
    --the station has disassociated from a previously connected AP
    return
  end
  -- total_tries: how many times the station will attempt to connect to the AP. Should consider AP reboot duration.
  local total_tries = 75
  print("\nWiFi connection to AP("..T.SSID..") has failed!")

  --There are many possible disconnect reasons, the following iterates through
  --the list and returns the string corresponding to the disconnect reason.
  for key,val in pairs(wifi.eventmon.reason) do
    if val == T.reason then
      print("Disconnect reason: "..val.."("..key..")")
      break
    end
  end

  if disconnect_ct == nil then
    disconnect_ct = 1
  else
    disconnect_ct = disconnect_ct + 1
  end
  if disconnect_ct < total_tries then
    print("Retrying connection...(attempt "..(disconnect_ct+1).." of "..total_tries..")")
  else
    wifi.sta.disconnect()
    print("Aborting connection to AP!")
    disconnect_ct = nil
  end
end

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=SSID, pwd=PASSWORD})
-- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
