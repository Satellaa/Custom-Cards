--Sinsiter Domination
CARD_MORNING_STAR      = 25451652
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Disable SPsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.dispcon)
	e2:SetTargetRange(0,1)
	c:RegisterEffect(e2)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.intgcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Destroy Itself
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.seldescon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARKLORD}
s.listed_names={CARD_MORNING_STAR}
	function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DARKLORD) and c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.dispcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) 
end  
function s.intgcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MORNING_STAR),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.selffilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.seldescon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.selffilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end