if not LPH_OBFUSCATED then
    LPH_JIT_MAX = function(...)
        return (...)
    end
    LPH_NO_VIRTUALIZE = function(...)
        return (...)
    end
end

LPH_JIT_MAX(
    function()
        local Players, Client, Mouse, RS, Camera, r =
            game:GetService("Players"),
            game:GetService("Players").LocalPlayer,
            game:GetService("Players").LocalPlayer:GetMouse(),
            game:GetService("RunService"),
            game.Workspace.CurrentCamera,
            math.random

        local Circle = Drawing.new("Circle")
        Circle.Color = Color3.new(1, 1, 1)
        Circle.Transparency = 0.5
        Circle.Thickness = 1

        local TracerCircle = Drawing.new("Circle")
        TracerCircle.Color = Color3.new(1, 1, 1)
        TracerCircle.Thickness = 1

        local prey
        local prey2
        local On

        local Vec2 = function(property)
            return Vector2.new(property.X, property.Y + (game:GetService("GuiService"):GetGuiInset().Y))
        end

        local UpdateSilentFOV = function()
            if not Circle then
                return Circle
            end
            Circle.Visible = getgenv().carsenishot.FOV["Visible"]
            Circle.Radius = getgenv().carsenishot.FOV["Radius"] * 3.05
            Circle.Filled = getgenv().carsenishot.FOV["Filled"]
            Circle.Position = Vec2(Mouse)

            return Circle
        end

        local UpdateTracerFOV = function()
            if not TracerCircle then
                return TracerCircle
            end

            TracerCircle.Visible = getgenv().carsenishot.Tracer["ShowFOV"]
            TracerCircle.Radius = getgenv().carsenishot.Tracer["Radius"]
            TracerCircle.Position = Vec2(Mouse)

            return TracerCircle
        end

        game.RunService.RenderStepped:Connect(function ()
            UpdateTracerFOV()
            UpdateSilentFOV()
        end)

        local WallCheck = function(destination, ignore)
            if getgenv().carsenishot.Extras.WallCheck then
                local Origin = Camera.CFrame.p
                local CheckRay = Ray.new(Origin, destination - Origin)
                local Hit = game.workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
                return Hit == nil
            else
                return true
            end
        end

        local useVelocity = function (player) 
            player.Character.HumanoidRootPart.Velocity = Vector3.new(0.36, 0.21, 0.34) * 2
        end

        local checkVelocity = function (player, pos, neg)
            if player and player.Character:FindFirstChild("Humanoid") then
                local velocity = player.Character.HumanoidRootPart.Velocity
                if (velocity.Magnitude > neg or velocity.Magnitude < pos and
                (not player.Character.Humanoid.Jump == true)) then
                    useVelocity(player)
                end
            end
            return false
        end

        task.spawn(function () while task.wait() do if getgenv().carsenishot.Resolver.AutoResolve == true then checkVelocity(prey or prey2, getgenv().carsenishot.Resolver.Positive, getgenv().carsenishot.Resolver.Negative) end end end)

        GetClosestToMouse = function()
            local Target, Closest = nil, 1 / 0

            for _, v in pairs(Players:GetPlayers()) do
                if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
                    local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                    local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

                    if
                        (Circle.Radius > Distance and Distance < Closest and OnScreen and
                            WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}))
                     then
                        Closest = Distance
                        Target = v
                    end
                end
            end
            return Target
        end

        function TargetChecks(Target)
            if getgenv().carsenishot.Extras.UnlockedOnDeath == true and Target.Character then
                return Target.Character.BodyEffects["K.O"].Value and true or false
            end
            return false
        end

        function PredictionictTargets(Target, Value)
            return Target.Character[getgenv().carsenishot.Silent.AimPart].CFrame +
                (Target.Character[getgenv().carsenishot.Silent.AimPart].Velocity * Value)
        end

        local WTS = function(Object)
            local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
            return Vector2.new(ObjectVector.X, ObjectVector.Y)
        end

        local IsOnScreen = function(Object)
            local IsOnScreen = Camera:WorldToScreenPoint(Object.Position)
            return IsOnScreen
        end

        local FilterObjs = function(Object)
            if string.find(Object.Name, "Gun") then
                return
            end
            if table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName) then
                return true
            end
        end
        GetClosestBodyPart = function(character)
            local ClosestDistance = 1 / 0
            local BodyPart = nil
            if (character and character:GetChildren()) then
                for _, x in next, character:GetChildren() do
                    if FilterObjs(x) and IsOnScreen(x) then
                        local Distance = (WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if getgenv().carsenishot.Tracer.UseTracerRadius == true then
                            if (TracerCircle.Radius > Distance and Distance < ClosestDistance) then
                                ClosestDistance = Distance
                                BodyPart = x
                            end
                        else
                            if (Distance < ClosestDistance) then
                                ClosestDistance = Distance
                                BodyPart = x
                            end
                        end
                    end
                end
            end
            return BodyPart
        end

        Mouse.KeyDown:Connect(
            function(Key)
                if (Key == getgenv().carsenishot.Tracer.TracerToggle:lower()) then
                    if getgenv().carsenishot.Tracer.Enabled == true then
                        On = not On
                        if On then
                            prey2 = GetClosestToMouse()
                        else
                            if prey2 ~= nil then
                                prey2 = nil
                            end
                        end
                    end
                end
                if (Key == getgenv().carsenishot.Silent.SilentToggle:lower()) then
                    if getgenv().carsenishot.Silent.Enabled == true then
                        getgenv().carsenishot.Silent.Enabled = false
                    else
                        getgenv().carsenishot.Silent.Enabled = true
                    end
                end
            end
        )

        RS.RenderStepped:Connect(
            function()
                if prey then
                    if prey ~= nil and getgenv().carsenishot.Silent.Enabled and getgenv().carsenishot.Silent.ClosestPart == true then
                        getgenv().carsenishot.Silent["AimPart"] = tostring(GetClosestBodyPart(prey.Character))
                    end
                end
                if prey2 then
                    if
                        prey2 ~= nil and not TargetChecks(prey2) and getgenv().carsenishot.Tracer.Enabled and
                            getgenv().carsenishot.Tracer.TraceClosestPart == true
                     then
                        getgenv().carsenishot.Tracer["AimPart"] = tostring(GetClosestBodyPart(prey2.Character))
                    end
                end
            end
        )

        local TracerPredictioniction = function(Target, Value)
            return Target.Character[getgenv().carsenishot.Tracer.AimPart].Position +
                (Target.Character[getgenv().carsenishot.Tracer.AimPart].Velocity / Value)
        end

        RS.RenderStepped:Connect(
            function()
                if
                    prey2 ~= nil and not TargetChecks(prey2) and getgenv().carsenishot.Tracer.Enabled and
                        getgenv().carsenishot.Tracer.Smoothness == true
                 then
                    local Main = CFrame.new(Camera.CFrame.p, TracerPredictioniction(prey2, getgenv().carsenishot.Tracer.Prediction))
                    Camera.CFrame =
                        Camera.CFrame:Lerp(
                        Main,
                        getgenv().carsenishot.Tracer.SmoothnessValue,
                        Enum.EasingStyle.Elastic,
                        Enum.EasingDirection.InOut,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.Out
                    )
                elseif prey2 ~= nil and getgenv().carsenishot.Tracer.Enabled and getgenv().carsenishot.Tracer.Smoothness == false then
                    Camera.CFrame =
                        CFrame.new(Camera.CFrame.Position, TracerPredictioniction(prey2, getgenv().carsenishot.Tracer.Prediction))
                end
            end
        )

        local grmt = getrawmetatable(game)
        local index = grmt.__index
        local properties = {
            "Hit" 
        }
        setreadonly(grmt, false)

        grmt.__index =
            newcclosure(
            function(self, v)
                if Mouse and (table.find(properties, v)) then
                    prey = GetClosestToMouse()
                    if prey ~= nil and getgenv().carsenishot.Silent.Enabled and not TargetChecks(prey) then
                        local endpoint = PredictionictTargets(prey, getgenv().carsenishot.Silent.Prediction)

                        return (table.find(properties, tostring(v)) and endpoint)
                    end
                end
                return index(self, v)
            end
        )
    end)

if genv().carsenishot.Resolver == true then
    local function zeroOutYVelocity(hrp)
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
    end
    
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            local hrp = character:WaitForChild("HumanoidRootPart")
            zeroOutYVelocity(hrp)
        end)
    end
    
    local function onPlayerRemoving(player)
        player.CharacterAdded:Disconnect()
    end
    
    game.Players.PlayerAdded:Connect(onPlayerAdded)
    game.Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    RunService.Heartbeat:Connect(function()
        pcall(function()
            for i, player in pairs(game.Players:GetChildren()) do
                if player.Name ~= game.Players.LocalPlayer.Name then
                    local hrp = player.Character.HumanoidRootPart
                    zeroOutYVelocity(hrp)
                end
            end
        end)
    end)
    local RunService = game:GetService("RunService")
    
    local function zeroOutYVelocity(hrp)
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
    end
    
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            local hrp = character:WaitForChild("HumanoidRootPart")
            zeroOutYVelocity(hrp)
        end)
    end
    
    local function onPlayerRemoving(player)
        player.CharacterAdded:Disconnect()
    end
    
    game.Players.PlayerAdded:Connect(onPlayerAdded)
    game.Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    RunService.Heartbeatfunction()
        pcall(function()
            for i, player in pairs(game.Players:GetChildren()) do
                if player.Name ~= game.Players.LocalPlayer.Name then
                    local hrp = player.Character.HumanoidRootPart
                    zeroOutYVelocity(hrp)
                end
            end
        end)
    end