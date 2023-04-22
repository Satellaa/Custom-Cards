--Custom constant

-- Set card
SET_AZURIST                        = 0xf16
SET_STARRYTAIL                     = 0xf13

-- Card id
CARD_THE_AZURE_PROJECT             = 2100000027

-- Stat
STAT_ATK           = 1400
STAT_DEF           = 1401
STAT_LEVEL         = 1402
STAT_RANK          = 1403
STAT_LINK          = 1404

-- Event
EVENT_STATS_CHANGE = 0x50000

-- Case
CASE_JUST_CHANGE   = 0x50001
CASE_GAIN          = 0x50002
CASE_LOSE          = 0x50003
CASE_DOUBLE        = 0x50003
CASE_HALVED        = 0x50004

-- __________________________________________
-- Custom function

-- Card method
function Card.HasMultipleRaces(c)
    if not c:IsMonster() then return false end
    local races=c:GetRace()
    return races>0 and races&(races-1)~=0
end

function Card.IsStatsChanged(c)
	local val=0
	local stat=0
	if c:GetFlagEffect(STAT_ATK)>0 then val=c:GetFlagEffectLabel(STAT_ATK+1000) stat=STAT_ATK
	elseif c:GetFlagEffect(STAT_DEF)>0 then val=c:GetFlagEffectLabel(STAT_DEF+1000) stat=STAT_DEF
	elseif c:GetFlagEffect(STAT_LEVEL)>0 then val=c:GetFlagEffectLabel(STAT_LEVEL+1000) stat=STAT_LEVEL
	elseif c:GetFlagEffect(STAT_LINK)>0 then val=c:GetFlagEffectLabel(STAT_LINK+1000) stat=STAT_LINK end
	return c:GetStats(stat)~=val
end

function Card.GetStats(c,stat)
  local val=0
  if stat==STAT_ATK then
  	val=c:GetAttack()
  elseif stat==STAT_DEF then
  	val=c:GetDefense()
  elseif stat==STAT_LEVEL then
  	val=c:GetLevel()
  elseif stats==STAT_RANK then
  	c:GetRank()
  elseif stat==STAT_LINK then
  	val=c:GetLink()
  end
  return val
end

function Card.GetPreviousStats(c)
	local val=0
	if c:GetFlagEffect(STAT_ATK)>0 then val=c:GetFlagEffectLabel(STAT_ATK+1000)
	elseif c:GetFlagEffect(STAT_DEF)>0 then val=c:GetFlagEffectLabel(STAT_DEF+1000)
	elseif c:GetFlagEffect(STAT_LEVEL)>0 then val=c:GetFlagEffectLabel(STAT_LEVEL+1000)
	elseif c:GetFlagEffect(STAT_LINK)>0 then val=c:GetFlagEffectLabel(STAT_LINK+1000) end
	return val
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



-- Lilac method
Lilac = {}
-- (Card c) is the card that will be the owner of this event
-- (int stat) is the stat that will be monitored
-- (int case) are cases where stats change
function Auxiliary.StatsChangeEvent(c,stat,case)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetOperation(Lilac.RegisterFlag(stat))
    Duel.RegisterEffect(e1,0)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetOperation(Lilac.RaiseEffect(stat,case))
    Duel.RegisterEffect(e2,0)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetOperation(Lilac.SetPrevStats(stat))
    Duel.RegisterEffect(e3,0)
end

function Lilac.RegisterFlag(stat)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(nil,tp,0x7f,0x7f,nil)
		for tc in g:Iter() do
			if tc:GetFlagEffect(stat)==0 then
				local value=tc:GetStats(stat) -- call the Card.GetStats function to get the value
				tc:RegisterFlagEffect(stat,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0,value) -- this flag stores the current value
				tc:RegisterFlagEffect(stat+1000,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,0,value) -- this flag stores the previous value
			end
		end
	end
end

function Lilac.RaiseEvent(tc,stat,case,e,tp,ep,re,r,rp)
	local value=tc:GetStats(stat)
	local prev_value=tc:GetFlagEffectLabel(stat) -- get the previous value from the flag
	if prev_value~=value and case==CASE_JUST_CHANGE then
		Duel.RaiseEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseSingleEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0)
	elseif (prev_value<value and case==CASE_GAIN) or (prev_value>value and case==CASE_LOSE) or (value==prev_value*2 and case==CASE_DOUBLE) or (value==prev_value/2 and case==CASE_HALVED) then
		Duel.RaiseEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0)
		Duel.RaiseSingleEvent(tc,EVENT_STATS_CHANGE,re,REASON_EFFECT,rp,ep,0) 
	end
	tc:SetFlagEffectLabel(stat,value)
end

function Lilac.RaiseEffect(stat,case)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(nil,tp,0x7f,0x7f,nil)
		for tc in g:Iter() do
			Lilac.RaiseEvent(tc,stat,case,e,tp,ep,re,r,rp)
		end
	end
end

function Lilac.ChangeLabel(tp,stat,rc)
	local function cfilter(c)
	return c:GetFlagEffectLabel(stat+1000)~=c:GetStats(stat)
	end
	local g=Duel.GetMatchingGroup(cfilter,tp,0x7f,0x7f,nil)
	for tc in g:Iter() do
		if rc==tc then
			rc:SetFlagEffectLabel(stat,rc:GetStats(stat))
			rc:SetFlagEffectLabel(stat+1000,rc:GetStats(stat))
		end
	end
end

function Lilac.SetPrevStats(stat)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(nil,tp,0x7f,0x7f,nil)
		for tc in g:Iter() do
			Lilac.ChangeLabel(tp,stat,tc)
		end
	end
end