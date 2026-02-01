-- mativilasanti_ pro player script - Loader

local KeySystem = false

local function LoadScript(path, name)
  local done = 0
  local repo = "https://raw.githubusercontent.com/s9y9qkfx7t-lang/mativilasanti_-script-dmvs/main/"  -- CAMBIA TUUSUARIO por tu username real de GitHub!!
  local URLs = {
    lib = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    init = repo .. "extra/Test.lua",
    script = repo .. game:GetService("HttpService"):UrlEncode(path),
    credits = repo .. "extra/Credits.lua"
  }

  local function Proceed()
    done = done + 1
    if done ~= 4 then return end
    loadstring(string.format([[
      local WindUI = loadstring(%q)()
      %s
      Window:EditOpenButton({Title = "mativilasanti_ pro player script", Draggable = true})
      Window:SetToggleKey(Enum.KeyCode.H)
      WindUI:Notify({Title = "Sigueme en Instagram 🔥", Content = "@mativilasanti_", Duration = 12})
      do local ok, err = pcall(function() loadstring(%q)() end) 
        if not ok then warn("Error: "..tostring(err)) end
      end
      %s
    ]], URLs.lib, URLs.init, URLs.script, URLs.credits))()
  end

  for k, url in pairs(URLs) do
    task.spawn(function()
      URLs[k] = game:HttpGet(url)
      Proceed()
    end)
  end
end

-- Agrega tus supported games y el resto como antes...
print("mativilasanti_ cargado! IG @mativilasanti_")
