local Elimination = {}
Elimination.__index = Elimination

local __ELEMENT = game.ReplicatedStorage.UI.Kill;
local Effects = require(script.Parent.Parent.Parent.Utilities.Effects)

function Elimination.New()
    
    local self = {}

    self._name = "Eliminations"
    self._Elims = {}
    self._offsets = {

        --0.090
        --0.265
        [1] =  CFrame.new(-0.265, -0.50, -1.20) * CFrame.Angles(0, math.rad(180), 0);
        [2] =  CFrame.new(-0.175, -0.50, -1.20) * CFrame.Angles(0, math.rad(180), 0);
        [3] =  CFrame.new(-0.085, -0.50, -1.20) * CFrame.Angles(0, math.rad(180), 0);
        [4] =  CFrame.new(0.005, -0.50, -1.20) * CFrame.Angles(0, math.rad(180), 0);
        [5] =  CFrame.new(0.095, -0.50, -1.20) * CFrame.Angles(0, math.rad(180), 0);
        [6] =  CFrame.new(0.185, -0.50, -1.20) * CFrame.Angles(0, math.rad(180), 0);

    }

    return setmetatable(self, Elimination)

end

function Elimination:Parse(Action, Arguments)
	if Action == "GrantElimination" then
		self:GrantElimination(Arguments)
	end
end

function Elimination:SetAdornee()
	
end


function Elimination:Deploy()
    
end

function Elimination:GrantElimination(Arguments)
    
    local Position = Arguments.Index;
    print(Position)

    local newElement : Part = __ELEMENT:Clone()
    newElement.Parent = workspace;

    self._Elims[Position] = {
        _element = newElement;
        _offset = self._offsets[Position];
    }   

    local _main = self._Elims[Position];
    Effects._Emit(newElement.Appear)

    print("GRANTED ELIMINATION", _main)
    
    _main.RunnerThread = task.spawn(function()
        game:GetService("RunService").RenderStepped:Connect(function()
            _main._element.CFrame = workspace.CurrentCamera.CFrame * self._offsets[Position];
        end)
    end)
end

function Elimination:Cleanup()
    for _, v in ipairs(self._Elims) do
       if v then
        task.cancel(v.RunnerThread)
        v._element:Destroy()
        v = nil;
       end
    end
 end

return Elimination