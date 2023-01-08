--[[
  06/01/2023 10:24
--]]

local function GetService(Service: string)
  return game.GetService(game, Service)
end

local Players = GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = GetService("ReplicatedStorage")

local Loops = {}
local Functions = {}
local Character = nil
local HumanoidRootPart = nil
local Toggles = {
  ["Speed"] = false,
  ["KillAura"] = false,
  ["InfiniteStamina"] = false,
  ["CustomRunSpeed"] = false,
  ["NoFallDamage"] = false,
  ["Noclip"] = false,
  ["AutoSelfRevive"] = false,
}
local Values = {
  ["Speed"] = 0.5,
  ["RunSpeed"] = 25,
}


function Functions:CreateLoop(Name: string, Function, Time: number)
  Loops[Name] = {
    Running = false,
    Destroy = false,
    Loop = task.spawn(function()
        while task.wait(Time) do
          if Loops[Name].Destroy then break end
          if Loops[Name].Running then
            Function()
          end
        end
    end)
  }
end

do --Functions
  function Functions:RunLoop(Name: string)
    if Loops[Name] then
      Loops[Name].Running = true
    else
      warn(Name.. " doesn't exist in Loops table!")
    end
  end

  function Functions:StopLoop(Name: string)
    if Loops[Name] then
      Loops[Name].Running = false
    else
      warn(Name.. " doesn't exist in Loops table!")
    end
  end

  function Functions:DestroyLoop(Name: string)
    if Loops[Name] then
      Loops[Name].Destroy = true
    else
      warn(Name.. " doesn't exist in Loops table!")
    end
  end

  function Functions:WhitelistCheck(Target)
      if Target:IsFriendsWith(Player.UserId) then
          return true
      end
      return false
  end

  function Functions:FindPlayer(N: string)
      local PlayersT = {}
      local Given = string.lower(N)
      for I, V in pairs(Players:GetPlayers()) do
          if V ~= Player then
            if string.lower(string.sub(V.Name, 1, string.len(Given))) == Given then
              table.insert(PlayersT, V)
            end
            if string.lower(string.sub(V.DisplayName, 1, string.len(Given))) == Given and not table.find(PlayersT, V) then
              table.insert(PlayersT, V)
            end
          end
      end
      return PlayersT
  end


end

do  --Character

  local function CharacterAdded()
    task.wait()
    Character = Player.Character
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 999)

    task.delay(1, function()
      for I, V in pairs(getgc(true)) do
          if type(V) == "table" and rawget(V, "WalkSpeed") then
              task.spawn(function()
                  while task.wait() do
                      if Toggles.InfiniteStamina then
                          rawset(V, "Current", 9e9)
                      end
                      if Toggles.CustomRunSpeed then
                          rawset(V, "RunSpeed", Values.RunSpeed)
                      end
                  end
              end)
          end
      end
    end)
  end
  Player.CharacterAdded:Connect(CharacterAdded)
  if Player.Character then
      CharacterAdded()
  end

end


local List = {'Bat','Katana','Bayonet','Superpunch','Nunchaku','Fire Axe','Scythe','Zweihander','Cleaver','Kukri','Crowbar','Rapier','Fist','Hand Axe','Chainsaw','Dual Tomahawks','Shovel','Hammer','Hook Blade','Baton','Spear', }

do  --Loops

  Functions:CreateLoop("Speed", function()
    if HumanoidRootPart and Character and Toggles.Speed then
      HumanoidRootPart.CFrame += Character.Humanoid.MoveDirection * Values.Speed
    end
  end, 0)

  Functions:CreateLoop("AutoSelfRevive", function()
    if Character and Character:FindFirstChild("Humanoid") and Toggles.AutoSelfRevive then
        if Character.Humanoid.Health < 16 then
          Character.Scripts.Client.Stomp_Kick_Revive_Client.Self_Event:FireServer(Character.Humanoid, "(#%*#%*#%A@$#*%#)lol(%#)%&#*")
          Character.Scripts.Client.ScreenAnimation_Client.Remote:FireServer("Stop")
        end
    end
  end, 0.05)

  Functions:CreateLoop("KillAura", function()
    if Toggles.KillAura then
			if Character and Character:FindFirstChild("HumanoidRootPart") then
				for I, V in pairs(Players:GetPlayers()) do
					if V.Character and V.Character:FindFirstChild("HumanoidRootPart") and V ~= Player then
            if V.Character:FindFirstChild("HumanoidRootPart") then
						if (Player.Character.HumanoidRootPart.Position - V.Character.HumanoidRootPart.Position).Magnitude <= 13 then
              local Tool = Character:FindFirstChildOfClass("Tool")
							if V.Character:FindFirstChild("Head") and Tool and table.find(List, Tool.Name) and Functions:WhitelistCheck(V) == false then
								local HeadPosition = V.Character.Head.Position
								local HeadCFrame = V.Character.Head.CFrame
								task.spawn(function()
									if Tool and Tool.Parent == Character then
                    pcall(function() --incase server errors
                        Tool.Scripts.Damage:InvokeServer(Tool, V.Character.Humanoid, V.Character.Head, HeadPosition, HeadPosition, HeadCFrame, HeadCFrame, 70, nil, HeadPosition)
                    end)
                  end
								end)
							end
						end
          end
					end
				end
			end
		end
  end, 0)

  --Run
  for Loop, Table in pairs(Loops) do
    Functions:RunLoop(Loop)
  end
end

do  --RunService
  GetService("RunService").RenderStepped:Connect(function()
    if Character then
      for I, V in pairs(Character:GetDescendants()) do
          if V:IsA("BasePart") then
            if V.CanCollide == true then
              V.CanCollide = not Toggles.Noclip
            end
          end
      end
    end
  end)
end

do  --GUI
  local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua"))
  local UI = Loader({
    rounding = false,
    theme = "cherry",
    smoothDragging = true
  })

  local Window = UI.newWindow({
    text = 'ricardohook',
    resize = false,
    size = Vector2.new(550, 376),
  })
  local CombatMenu = Window:addMenu({text = 'Combat Menu'})
  local CharacterMenu = Window:addMenu({text = 'Character Menu'})
  local PlayerMenu = Window:addMenu({text = 'Player Menu'})

  do --Combat Section
    local CombatSection = CombatMenu:addSection({text = 'Combat',side = 'auto',})
    local KillAura = CombatSection:addToggle({text = 'Kill Aura'})
    local AutoSelfRevive = CombatSection:addToggle({text = 'Auto Self Revive'})
    KillAura:bindToEvent("onToggle", function(State)
      Toggles.KillAura = State
    end)
    AutoSelfRevive:bindToEvent("onToggle", function(State)
      Toggles.AutoSelfRevive = State
    end)
  end

  do  --Character Section
    local CharacterSection = CharacterMenu:addSection({text = 'Character',side = 'auto',})
    local Speed = CharacterSection:addToggle({text = 'Speed'})
    local Noclip = CharacterSection:addToggle({text = 'Noclip'})
    local InfiniteStamina = CharacterSection:addToggle({text = 'Infinite Stamina'})
    local NoFallDamage = CharacterSection:addToggle({text = 'No Fall Damage'})
    local CustomRunSpeed = CharacterSection:addToggle({text = 'Custom Run Speed'})

    Speed:bindToEvent("onToggle", function(State)
      Toggles.Speed = State
    end)
    Noclip:bindToEvent("onToggle", function(State)
      Toggles.Noclip = State
    end)
    InfiniteStamina:bindToEvent("onToggle", function(State)
      Toggles.InfiniteStamina = State
    end)
    NoFallDamage:bindToEvent("onToggle", function(State)
        Toggles.NoFallDamage = State
    end)
    CustomRunSpeed:bindToEvent("onToggle", function(State)
      Toggles.CustomRunSpeed = State
    end)

    CharacterSection:addSlider({text='Speed Value', min=0.1, max=1, step=0.1, val=0.5}, function(Value)
      Values.Speed = Value
    end)
    CharacterSection:addSlider({text='Run Speed', min=16, max=100, step=1, val=25}, function(Value)
      Values.RunSpeed = Value
    end)
  end

  do  --Player Menu
    local Target = ""
    local AllPlayers = PlayerMenu:addSection({text = 'Players',side = 'auto',})
    AllPlayers:addLabel({text="For anything that is\nkill, please equip your melee."})
    AllPlayers:addTextbox({text="Target(s)"}):bindToEvent("onFocusLost", function(Text)
      Target = string.lower(Text)
    end)
    AllPlayers:addButton({text="Kill Player(s)", style="large"}):bindToEvent("onClick", function()
      local Saved = Character:FindFirstChild("HumanoidRootPart").CFrame
        for I, V in pairs(Functions:FindPlayer(Target)) do
            if V.Character and V.Character:FindFirstChild("HumanoidRootPart") and Character and Character:FindFirstChild("HumanoidRootPart") then
                local Tool = Character:FindFirstChildOfClass("Tool")
                if Tool then
                  local Trys = 0
                  repeat task.wait()
                    Trys += 1
                    if V.Character and Character and Character:FindFirstChild("HumanoidRootPart") and V.Character:FindFirstChild("HumanoidRootPart") and V.Character:FindFirstChild("Head") then
                        Character.HumanoidRootPart.CFrame = V.Character.HumanoidRootPart.CFrame
                        local HeadPosition = V.Character.Head.Position
        								local HeadCFrame = V.Character.Head.CFrame
        								task.spawn(function()
                          pcall(function() --incase server errors
                              Tool.Scripts.Damage:InvokeServer(Tool, V.Character.Humanoid, V.Character.Head, HeadPosition, HeadPosition, HeadCFrame, HeadCFrame, 70, nil, HeadPosition)
                          end)
        								end)
                    end
                  until Trys == 50 or V.Character.Humanoid.Health == 0
                end
            end
        end
        Character:FindFirstChild("HumanoidRootPart").CFrame = Saved
    end)
    AllPlayers:addButton({text="Kill All (Equip Melee)", style="large"}):bindToEvent("onClick", function()
      local Position = Character.HumanoidRootPart.CFrame
      local Old = Toggles.KillAura
      Toggles.KillAura = true --Let kill aura do it man!

      for I, V in pairs(Players:GetPlayers()) do
          if V.Character and V.Character:FindFirstChild("Humanoid") then
              local Head = V.Character:FindFirstChild("HumanoidRootPart")
              if Head and Character and Character:FindFirstChild("HumanoidRootPart") then
                  local Trys = 0
                  repeat task.wait()
                    if Head then
                      Trys += 1
                      Character.HumanoidRootPart.CFrame = Head.CFrame
                    end
                  until Trys == 50 or V.Character.Humanoid.Health == 0
              end
          end
      end
      Toggles.KillAura = Old
      Character.HumanoidRootPart.CFrame = Position
    end)
  end


end

local RemoteHook; RemoteHook = hookmetamethod(game, "__namecall", function(self, ...)
  if self.Name == "Fall" and Toggles.NoFallDamage then
    return
  end
  return RemoteHook(self, ...)
end)
