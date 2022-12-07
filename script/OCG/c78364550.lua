--Resonator Red Dragon Archfiend 
local s,id=GetID()
function s.initial_effect(c)
c:SetUniqueOnField(1,0,id)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(70902743)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Spsummon 1 level 5 or lower dragon, or fiend or Warrior
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
 s.listed_series={SET_RESONATOR}

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.ftarget(e,c)
	return not ((c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)) or (c:IsSetCard(SET_RESONATOR) and c:IsMonster()))
end
function s.dfilter(c,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and not ((c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR)) and c:IsControler(tp))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	local sg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return #eg==1 and tc:IsControler(tp) and  ((tc:IsRace(RACE_DRAGON) and tc:IsAttribute(ATTRIBUTE_DARK) and tc:IsType(TYPE_SYNCHRO)) 
	  or (tc:IsSetCard(SET_RESONATOR) and tc:IsMonster()))
	  and bc:IsReason(REASON_BATTLE) and (bc:GetBattlePosition()&POS_DEFENSE)~=0
end
function s.spfilter(c,e,tp)
  return c:IsLevelBelow(5) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
  end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,nil,e,tp)
    	if #sg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		--Cannot attack directly this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3207)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
end