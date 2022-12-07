--Minstrel Vampire
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--xyzlv
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE +EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Damage and Recover 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_BATTLE_START)
	e4:SetCondition(s.rccon)
	e4:SetCost(s.rccost)
	e4:SetTarget(s.rctg)
	e4:SetOperation(s.rcop)
	c:RegisterEffect(e4)
	end
	function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_ZOMBIE,lc,sumtype,tp) and c:IsLevelAbove(5)
end
function s.cfilter(c,g)
	return c:IsRace(RACE_ZOMBIE) and c:IsSummonType(SUMMON_TYPE_XYZ) and g:IsContains(c)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and eg:IsExists(s.cfilter,1,nil,lg)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_MATERIAL)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.xyztg)
	e1:SetValue(s.xyzval)
	Duel.RegisterEffect(e1,tp)
end
function s.xyztg(e,c)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
	function s.xyzval(e,c,rc,tp)
	 local c=e:GetHandler()
	 local zone=c:GetLinkedZone(tp)
	return rc:IsRace(RACE_ZOMBIE) and c:GetToBeLinkedZone(rc,tp) and rc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false,POS_FACEUP,tp,zone)
	end
	function s.rccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,400)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,400)
	end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.SetLP(1-tp,Duel.GetLP(1-tp)-500)~=0 then
		Duel.BreakEffect()
		Duel.Recover(tp,500,REASON_EFFECT+REASON_COST)
	end
end