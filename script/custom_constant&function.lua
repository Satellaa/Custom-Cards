--Custom constant

-- Event
EVENT_DECKTOP_CONFIRM              = EVENT_CUSTOM+99912

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

function Card.GetExtraMonsterType(c)
  local extra_type = TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK
  local result = c:GetType()&extra_type
  return result
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

function Auxiliary.GetSummonType(c)
	local summon_type_table={
		[TYPE_RITUAL] = SUMMON_TYPE_RITUAL,
		[TYPE_FUSION] = SUMMON_TYPE_FUSION,
		[TYPE_SYNCHRO] = SUMMON_TYPE_SYNCHRO,
		[TYPE_XYZ] = SUMMON_TYPE_XYZ,
		[TYPE_PENDULUM] = SUMMON_TYPE_PENDULUM,
		[TYPE_LINK] = SUMMON_TYPE_LINK
	}
	local summon_type = summon_type_table[c:GetExtraMonsterType()]
	if not summon_type then
		summon_type = 0
	end
	return summon_type
end

function Auxiliary.GetReasonType(c)
	local reason_type_table={
		[TYPE_RITUAL] = REASON_RITUAL,
		[TYPE_FUSION] = REASON_FUSION,
		[TYPE_SYNCHRO] = REASON_SYNCHRO,
		[TYPE_XYZ] = REASON_XYZ,
		[TYPE_LINK] = REASON_LINK
	}
	local reason_type = reason_type_table[c:GetExtraMonsterType()]
	if not reason_type then
		reason_type = 0
	end
	return reason_type
end

-- Used to get columns other than the column of (card|group)
-- (int left|nil): left column
-- (int right|nil): right column
function Auxiliary.GetOtherColumnGroup(c_or_group,left,right)
	local result=Group.CreateGroup()
	if c_or_group then
		if type(c_or_group)=="Group" then
			for tc in aux.Next(c_or_group) do
				local seq=tc:GetColumnGroup(left,right)-tc:GetColumnGroup()
				result:AddCard(seq)
			end
		return result
		elseif type(c_or_group)=="Card" then
			local seq=c_or_group:GetColumnGroup(left,right)-c_or_group:GetColumnGroup()
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

local Lycansquad={}

function Lycansquad.lmfilter(c,lc,tp,id)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_LINK,tp,id) and c:IsCanBeLinkMaterial(lc,tp)
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0 and not c:IsDisabled()
end

function Lycansquad.condition(id)
	return function(e,c,must,g,min,max)
		if c==nil then return true end
		local tp=c:GetControler()
		local g=Duel.GetMatchingGroup(Lycansquad.lmfilter,tp,LOCATION_MZONE,0,nil,c,tp,id)
		local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
		if must then mustg:Merge(must) end
		return ((#mustg==1 and Lycansquad.lmfilter(mustg:GetFirst(),c,tp)) or (#mustg==0 and #g>0))
			and Duel.GetFlagEffect(tp,id+EVENT_CUSTOM)>=3
	end
end

function Lycansquad.target(id)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
		local g=Duel.GetMatchingGroup(Lycansquad.lmfilter,tp,LOCATION_MZONE,0,nil,c,tp,id)
		local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
		if must then mustg:Merge(must) end
		if #mustg>0 then
			if #mustg>1 then
				return false
			end
			mustg:KeepAlive()
			e:SetLabelObject(mustg)
			return true
		end
		local tc=g:SelectUnselect(Group.CreateGroup(),tp,false,true)
		if tc then
			local sg=Group.FromCards(tc)
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		else return false end
	end
end

function Lycansquad.operation(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_LINK)
end

function Auxiliary.CreateLycansquadAlterLinkProc(c,id)
	local ly1=Effect.CreateEffect(c)
	ly1:SetDescription(3401)
	ly1:SetType(EFFECT_TYPE_FIELD)
	ly1:SetCode(EFFECT_SPSUMMON_PROC)
	ly1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	ly1:SetRange(LOCATION_EXTRA)
	ly1:SetCondition(Lycansquad.condition(id))
	ly1:SetTarget(Lycansquad.target(id))
	ly1:SetOperation(Lycansquad.operation)
	ly1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(ly1)
	return ly1
end

-- Duel method
Duel.ConfirmDecktop=(function()
	local oldfunc=Duel.ConfirmDecktop
	return function(tp,count)
		local res=oldfunc(tp,count)
		local deckg=Duel.GetDecktopGroup(tp,count)
		local eg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,nil,EVENT_DECKTOP_CONFIRM)
		if #deckg>0 then
			for tc in deckg:Iter() do
				Duel.RegisterFlagEffect(tp,tc:GetCode()+EVENT_CUSTOM,RESET_PHASE+PHASE_END,0,1)
			end
			eg:Merge(deckg)
			Duel.RaiseEvent(eg,EVENT_DECKTOP_CONFIRM,nil,0,tp,tp,0)
		end
		return deckg
	end
end)()