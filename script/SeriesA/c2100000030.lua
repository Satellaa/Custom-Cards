-- Azurist Invocation
-- Scripted by Lilac
Duel.LoadScript("custom_constant.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon 1 "Azurist" monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Normal Summon 1 "Azurist" monster from your hand or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.nscon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AZURIST}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_AZURIST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetOperation(s.thop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		Duel.SpecialSummonComplete()
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
function s.confilter(c)
	return c:IsFacedown() or not c:IsSetCard(SET_AZURIST)
end
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sumfilter(c,g)
	return c:IsSetCard(SET_AZURIST) and c:IsSummonable(true,nil) and not g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dn=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,dn) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,dn)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local dn=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sumfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,dn):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end