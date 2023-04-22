--Custom constant

-- Set card
SET_AZURIST                        = 0xf16
SET_STARRYTAIL                     = 0xf13

-- Card id
CARD_THE_AZURE_PROJECT             = 2100000027

-- __________________________________________
-- Custom function

-- Card method
function Card.HasMultipleRaces(c)
    if not c:IsMonster() then return false end
    local races=c:GetRace()
    return races>0 and races&(races-1)~=0
end

-- Auxiliary method
function Auxiliary.GetTypeStrings(v)
	local t = {
		[TYPE_RITUAL] = 1057,
        [TYPE_FUSION] = 1056,
		[TYPE_SYNCHRO] = 1063,
		[TYPE_XYZ] = 1073,
		[TYPE_LINK] = 1076
	}
	local res={}
	local ct=0
	for _,type in aux.BitSplit(v) do
		if t[type] then
			table.insert(res,t[type])
			ct=ct+1
		end
	end
	return pairs(res)
end

-- Used to get columns other than the column of (card|group)
-- (int left|nil): left column
-- (int right|nil): right column
function Auxiliary.GetOtherColumnGroup(c_or_group,left,right)
  local result = Group.CreateGroup()
  if c_or_group then
    if type(c_or_group)=="Group" then
      for tc in aux.Next(c_or_group) do
        local seq=tc:GetColumnGroup(left,right)-tc:GetColumnGroup()
        result:AddCard(seq)
      end
      return result
    elseif type(c_or_group)=="Card" then
      local seq = c_or_group:GetColumnGroup(left,right)-c_or_group:GetColumnGroup()
      result:AddCard(seq)
      return result
   end
  else
    return nil
   end
end

function Auxiliary.selftogravecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

local Azurist={}
function Azurist.registerflag(id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,0,1,3399)
	end
end
function Azurist.resetflag(id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():ResetFlagEffect(id)
	end
end
function Azurist.matlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_SPELLCASTER)
end
function Auxiliary.CreateAzuristRestriction(c,id)
	-- Cannot be material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(Azurist.registerflag(id))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)>0 end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local ep1=Effect.CreateEffect(c)
	ep1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ep1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ep1:SetCode(EVENT_CUSTOM+id)
	ep1:SetRange(LOCATION_MZONE)
	ep1:SetCondition(function(e) return e:GetHandler():GetFlagEffect(CARD_THE_AZURE_PROJECT)>0 end)
	ep1:SetOperation(Azurist.resetflag(id))
	c:RegisterEffect(ep1)
	local ep2=Effect.CreateEffect(c)
	ep2:SetType(EFFECT_TYPE_SINGLE)
	ep2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ep2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	ep2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(CARD_THE_AZURE_PROJECT)>0 end)
	ep2:SetValue(Azurist.matlimit)
	c:RegisterEffect(ep2)
	return e1 and e2 and ep1 and ep2
end