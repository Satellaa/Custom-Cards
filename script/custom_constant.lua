--Custom constant

-- Set card
SET_AZURIST                        = 0xf16
SET_STARRYTAIL                     = 0xf13

-- Card id
CARD_THE_AZURE_PROJECT             = 2100000027

-- Flag
FLAG_PREV_ATK      = 1410
FLAG_PREV_DEF      = 1411
FLAG_ATK           = 1412
FLAG_DEF           = 1413

-- Event
EVENT_STATS_CHANGE = 0x50000

-- Case
CASE_JUST_CHANGE   = 0x50001
CASE_GAIN          = 0x50002
CASE_LOSE          = 0x50003
CASE_DOUBLE        = 0x50003
CASE_HALVED        = 0x50004

-- __________________________________________

-- A function used to check if (Card c) has more than one race
function Card.HasMultipleRaces(c)
    if not c:IsMonster() then return false end
    local races=c:GetRace()
    return races>0 and races&(races-1)~=0
end

function Card.IsStatsChanged(c)
	local val=0
	local prev_flag=0
	if c:GetFlagEffect(FLAG_PREV_ATK)>0 then val=c:GetFlagEffectLabel(FLAG_PREV_ATK) prev_flag=FLAG_PREV_ATK
	elseif c:GetFlagEffect(FLAG_PREV_DEF)>0 then val=c:GetFlagEffectLabel(FLAG_PREV_DEF) prev_flag=FLAG_PREV_DEF end
	if prev_flag==FLAG_PREV_ATK then
		return c:GetAttack()~=val
	elseif prev_flag==FLAG_PREV_DEF then
		return c:GetDefense()~=val
	end
end

function Card.GetPreviousStats(c)
	local val=0
	if c:GetFlagEffect(FLAG_PREV_ATK)>0 then val=c:GetFlagEffectLabel(FLAG_PREV_ATK)
	elseif c:GetFlagEffect(FLAG_PREV_DEF)>0 then val=c:GetFlagEffectLabel(FLAG_PREV_DEF) end
	return val
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


Lilac = {}

-- (Card c) is the card that will be the owner of this event
-- (int case) are cases where stats change
-- (bool stats) if true, an event occurs when the monster's ATK is changed, and vice versa if false
function Auxiliary.StatsChangeEvent(c,case,boolean)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetOperation(Lilac.RegisterFlag(case,boolean))
    Duel.RegisterEffect(e1,0)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetOperation(Lilac.RaiseEffect(case,boolean))
    Duel.RegisterEffect(e2,0)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetOperation(Lilac.SetPrevStats(boolean))
    Duel.RegisterEffect(e3,0)
end
function Lilac.RegisterFlag(case,boolean)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local stats=0
		local prev_stats=0
		local flag=boolean and FLAG_ATK or FLAG_DEF
		local prev_flag=boolean and FLAG_PREV_ATK or FLAG_PREV_DEF
		local g=Duel.GetMatchingGroup(nil,tp,0x7f,0x7f,nil)
			for tc in aux.Next(g) do
				if tc:GetFlagEffect(prev_flag)==0 and tc:GetFlagEffect(flag)==0 then
					stats=boolean and tc:GetAttack() or tc:GetDefense()
					prev_stats=boolean and tc:GetBaseAttack() or tc:GetBaseDefense()
					tc:RegisterFlagEffect(prev_flag,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0,prev_stats)
					tc:RegisterFlagEffect(flag,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0,stats)
			end
		end
	end
end
function Lilac.RaiseEvent(tc,case,boolean,e,ep,re,r,rp)
	-- stats is current stats
	-- prevstats is pre stats
	local prev_flag=boolean and FLAG_PREV_ATK or FLAG_PREV_DEF
	local stats=boolean and tc:GetAttack() or tc:GetDefense()
	local prev_stats=boolean and tc:GetBaseAttack() or tc:GetBaseDefense()
	local flag=boolean and FLAG_ATK or FLAG_DEF
	local prevstats=tc:GetFlagEffectLabel(flag)
	local c=e:GetHandler()
	if prevstats~=stats and case==CASE_JUST_CHANGE then
		Duel.RaiseEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseSingleEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0)
		c:RegisterFlagEffect(c:GetCode(),RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
	elseif (prevstats<stats and case==CASE_GAIN) or (prevstats>stats and case==CASE_LOSE) or (stats==prevstats*2 and case==CASE_DOUBLE) or (stats==prevstats/2 and case==CASE_HALVED) then
		Duel.RaiseEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseSingleEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0) 
		c:RegisterFlagEffect(c:GetCode(),RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
	end
	tc:SetFlagEffectLabel(flag,stats)
end
function Lilac.RaiseEffect(case,boolean)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(nil,tp,0x7f,0x7f,nil)
			for tc in aux.Next(g) do
				Lilac.RaiseEvent(tc,case,boolean,e,ep,re,r,rp)
		end
	end
end
function Lilac.ChangeLabel(tp,flag)
	local function cfilter(c)
	return c:GetAttack()~=c:GetFlagEffectLabel(flag)
	end
	local set_stats=nil
	local g=Duel.GetMatchingGroup(cfilter,tp,0x7f,0x7f,nil)
	for tc in aux.Next(g) do
		if flag==FLAG_PREV_ATK then set_stats=tc:GetAttack()
		elseif flag==FLAG_PREV_DEF then set_stats=tc:GetDefense() end
		tc:SetFlagEffectLabel(flag,set_stats)
	end
end
function Lilac.SetPrevStats(boolean)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local flag=0
		if c:GetFlagEffect(c:GetCode())>0 then
			if boolean then flag=FLAG_PREV_ATK
			else flag=FLAG_PREV_DEF end
			Lilac.ChangeLabel(tp,flag)
			c:ResetFlagEffect(c:GetCode())
		end
	end
end