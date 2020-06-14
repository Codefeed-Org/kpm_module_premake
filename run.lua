function getopt( arg, options )
  local tab = {}
  for k, v in ipairs(arg) do
    if string.sub( v, 1, 2) == "--" then
      local x = string.find( v, "=", 1, true )
      if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
      else      tab[ string.sub( v, 3 ) ] = true
      end
    elseif string.sub( v, 1, 1 ) == "-" then
      local y = 2
      local l = string.len(v)
      local jopt
      while ( y <= l ) do
        jopt = string.sub( v, y, y )
        if string.find( options, jopt, 1, true ) then
          if y < l then
            tab[ jopt ] = string.sub( v, y+1 )
            y = l
          else
            tab[ jopt ] = arg[ k + 1 ]
          end
        else
          tab[ jopt ] = true
        end
        y = y + 1
      end
    end
  end
  return tab
end

function open_temp_script()
  local handle
  local fname
  while true do
    fname = "yourfile" .. tostring(math.random(11111111,99999999) .. ".bat")
    handle = io.open(fname, "r")
    if not handle then
      handle = io.open(fname, "w")
      break
    end
    io.close(handle)
  end
  return handle, fname
end

function exists(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
     if code == 13 then
        -- Permission denied, but it exists
        return true
     end
  end
  return ok, err
end

function cmakeBuild(options)
  script, name = open_temp_script()
  script:write("premake5 vs2019 ..\n")
  script:write("devenv " .. options["name"] .. " /Build " .. options["buildtype"] .. " \n")
  io.close(script)
  os.execute(name)
  os.remove(name)
  
end

options = getopt(arg, "")
--options["builddir"]
--options["buildtype"]
--options["creates"]
--options["name"]
--options["parameters]
if options["buildtype"] == nil then
  options["buildtype"] = "Release"
end

if options["parameters"] == nil then
  options["parameters"] = ""
end

local build = true
if options["creates"] ~= nil then
  if exists(options["creates"]) then
    build = false
  end
end

if build then
  cmakeBuild(options)
end
print(options["builddir"])
local result = {path = options["builddir"] .. "\\" .. options["buildtype"]}
return result