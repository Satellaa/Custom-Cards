--Sanctuary in The Abyss
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Negate all monsters that were special summoned from extra deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.disable)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	--change attribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_DARK)
	e2:SetTarget(s.attribute)
	c:RegisterEffect(e2)
	--Special Summon 1 Darklord
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	end
	function s.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and not c:IsOriginalAttribute(ATTRIBUTE_DARK)
end
function s.disable(e,c)
	return (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT) and s.spfilter(c)
end
function s.attribute(e,c)
	return (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT) and s.spfilter(c)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.spfilter1(c,e,tp)
return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	end
	function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD+REASON_COST)
	local dg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #dg>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=dg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end