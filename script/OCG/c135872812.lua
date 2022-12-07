--Ancient Gear Shark 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Prevent battle destruction 
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.econ)
	e3:SetTarget(s.efilter)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--decrease tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCost(aux.bfgcost)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x7}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_MACHINE,scard,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
function s.econ(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.efilter(e,c)
	return c:IsSetCard(0x7)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT))
		and c:IsPreviousPosition(POS_FACEUP)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
   e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7))
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(0x1)
   Duel.RegisterEffect(e1,tp)
 end