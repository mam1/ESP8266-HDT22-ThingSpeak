version = "0.4"
CHANNEL_API_KEY = "ASBDBJSVR3PJNUBJ"
delay = 1000
PINS = {4,2,1}
FIELDS = {1,2,3,4,5,6}
--ecount = #PINS
pinptr = 1
fieldptr = 1

function readDHT22(pin)
    print("reading pin "..PINS[pinptr])
    
end

function post(key,field,value)
    print("posting pin "..PINS[pinptr].." data to field "..FIELDS[pinptr].." value is "..value)   

end

function tostr(num)


end

function update()
	
    readDHT22(PINS[pinptr])
    tostring(number)


 
    post(CHANNEL_API_KEY,FIELDS[fieldptr],"99.9")





 
	pinptr = pinptr + 1
	if pinptr > #PINS then pinptr = 1 end
    fieldptr = fieldptr + 1
    if fieldptr > #FIELDS then fieldptr = 1 end
end

if (#PINS ~= (#FIELDS * 2)) then print("\n***** pin count and field cound do not match\naborting") 
else tmr.alarm(0, delay, 1, update) end
