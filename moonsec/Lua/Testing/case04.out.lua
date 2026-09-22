--[=[ deobfuscated by sergei.dev @ .gg/svgmV95Apm ]=]--

local placeid = game.PlaceId
if placeid == 6839171747 then
  local var1 = firesignal
  local replicatedstorage = game.ReplicatedStorage
  var2 = replicatedstorage.Bricks.Caption.OnClientEvent
  local var3 = "Doors Hardcore Script - v0.2"
  var1(var2, var3)
  var1 = wait
  var2 = 1
  var1(var2)
  var1 = firesignal
  var2 = game.ReplicatedStorage
  var2 = var2.Bricks.Caption.OnClientEvent
  var3 = "Made by ThatOneAmethystIceCube#0001"
  var1(var2, var3)
  var1 = wait
  var2 = 1
  var1(var2)
  var1 = firesignal
  var2 = game.ReplicatedStorage
  var2 = var2.Bricks.Caption.OnClientEvent
  var3 = "Credits to Oof#0135 for helping!"
  var1(var2, var3)
  var1 = game.ReplicatedStorage
  var2 = var1.GameData.LatestRoom.Changed
  var1 = var1.Wait
  var1(var2)
  var1 = firesignal
  var2 = game.ReplicatedStorage
  var2 = var2.Bricks.Caption.OnClientEvent
  var3 = "Hardcore Started"
  var1(var2, var3)
  var1 = coroutine.wrap
  function var2()
    while true do
      wait(0.5)
      loadstring(game:HttpGet("https://github.com/HollowedOutMods/Doors/blob/main/retexture.lua?raw=true"))()
    end
  end
  var1 = var1(var2)
  var1()
  var1 = loadstring
  var3 = game
  var4 = var2.HttpGet(var3, "https://github.com/HollowedOutMods/Doors/blob/main/music.lua?raw=true")
  var1 = var1(var2, var3, var4)
  var1()
  var1 = coroutine.wrap
  function var2()
    while true do
      wait(80)
      game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait()
      loadstring(game:HttpGet("https://github.com/HollowedOutMods/Doors/blob/main/threat.lua?raw=true"))()
    end
  end
  var1 = var1(var2)
  var1()
  var1 = coroutine.wrap
  function var2()
    while true do
      wait(220)
      if not depthactive == true then
        loadstring(game:HttpGet("https://github.com/HollowedOutMods/Doors/blob/main/depth.lua?raw=true"))()
      end
    end
  end
  var1 = var1(var2)
  var1()
  var1 = coroutine.wrap
  function var2()
    while true do
      wait(60)
      loadstring(game:HttpGet("https://https://github.com/HollowedOutMods/Doors/blob/main/timer.lua?raw=true"))()
    end
  end
  var1 = var1(var2)
  var1()
  var1 = coroutine.wrap
  function var2()
    while true do
      if game.Players.LocalPlayer:FindFirstChildOfClass("Backpack") then
        if game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren() and #game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren() > 2 then
          print("Removing")
          firesignal(game.ReplicatedStorage.Bricks.Caption.OnClientEvent, "Something feels wrong...")
          wait(1)
          while #game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren() > 2 do
            if game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren()[1] then
              game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren()[1]:Destroy()
            end
            wait(0.5)
          end
          loadstring(game:HttpGet("https://github.com/HollowedOutMods/Doors/blob/main/greed.lua?raw=true"))()
        else
          print("Not enough items")
          wait(1)
        end
        print("Script is running!")
        wait(1)
      else
        wait(1)
        print("Script is running, but it didn't exist.")
      end
    end
  end
  var1 = var1(var2)
  var1()
else
  var1 = firesignal
  var2 = game.ReplicatedStorage
  var2 = var2.Bricks.Caption.OnClientEvent
  var3 = "You need to run this when in-game."
  var1(var2, var3)
end
