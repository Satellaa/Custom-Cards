--Customconstant
SET_AZURIST                        = 0xf16
CARD_THE_AZURE_PROJECT             = 2100000027
FLAG_ATK           = 1412
FLAG_DEF           = 1413
EVENT_STATS_CHANGE = 0x50000
CASE_JUST_CHANGE   = 0x50001
CASE_GAIN          = 0x50002
CASE_LOSE          = 0x50003
CASE_DOUBLE        = 0x50003
CASE_HALVED        = 0x50004

-- A function used to check if (Card c) has more than one race
function Card.HasMultipleRaces(c)
    if not c:IsMonster() then return false end
    local races=c:GetRace()
    return races>0 and races&(races-1)~=0
end

function Auxiliary.BitSplit(v)
	local res={}
	local i=0
	while 2^i<=v do
		local p=2^i
		if v & p~=0 then
			table.insert(res,p)
		end
		i=i+1
	end
	return pairs(res)
end

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
	for _,type in Auxiliary.BitSplit(v) do
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


local Lilac = {}

-- (Card c) is the card that will be the owner of this event
-- (int case) are cases where stats change
-- (bool stats) if true, an event occurs when the monster's ATK is changed, and vice versa if false
function Auxiliary.StatsChangeEvent(c,case,boolean)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetOperation(Lilac.checkop(case,boolean))
    Duel.RegisterEffect(e1,0)
end
function Lilac.RaiseEvent(tc,case,boolean,ep,re,r,rp)
	-- stats is current stats
	-- prestats is pre stats
	local flag=boolean and FLAG_ATK or FLAG_DEF
	local stats=boolean and tc:GetAttack() or tc:GetDefense()
	if tc:GetFlagEffect(flag)==0 then
		tc:RegisterFlagEffect(flag,RESET_EVENT+RESETS_STANDARD,0,0,stats)
	else
		local prestats=tc:GetFlagEffectLabel(flag)
		if prestats~=stats and case==CASE_JUST_CHANGE then
			Duel.RaiseEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0) 
			Duel.RaiseSingleEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0) 
		elseif (prestats<stats and case==CASE_GAIN) or (prestats>stats and case==CASE_LOSE) or (stats==prestats*2 and case==CASE_DOUBLE) or (stats==prestats/2 and case==CASE_HALVED) then
			Duel.RaiseEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0)
			Duel.RaiseSingleEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0) 
		end
		tc:SetFlagEffectLabel(flag,stats) -- Set to current stats, otherwise still raise event
	end
end
function Lilac.checkop(case,boolean)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0x7f,0x7f,nil)
			for tc in aux.Next(g) do
				Lilac.RaiseEvent(tc,case,boolean,ep,re,r,rp)
		end
	end
end