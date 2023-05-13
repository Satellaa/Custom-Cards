-- Azurist Summoning Chains
-- Scripted by Lilac
Duel.LoadScript("custom_constant&function.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon 1 Rank 4 "Azurist" monster from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.xspcon)
	e1:SetTarget(s.xsptg)
	e1:SetOperation(s.xspop)
	c:RegisterEffect(e1)
	-- Special Summon 1 non-Xyz "Azurist" monster from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AZURIST}
function s.xspconfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
function s.xspcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xspconfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)>=2 and g:IsExists(aux.FaceupFilter(Card.IsSetCard,SET_AZURIST),1,nil)
end
function s.xspfilter(c,e,tp)
	return c:IsSetCard(SET_AZURIST) and c:IsType(TYPE_XYZ) and c:IsRank(4) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false,POS_FACEUP)
end
function s.attachfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.xsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.xspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if #g>0 and Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local xge=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.attachfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_MZONE,LOCATION_MZONE,1,1,tc)
		Duel.HintSelection(xge,true)
		Duel.Overlay(tc,xge,true)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_AZURIST) and not c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
		if tc:GetFlagEffect(tc:GetCode())==0 then return end
		tc:RegisterFlagEffect(CARD_THE_AZURE_PROJECT,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,0,1,aux.Stringid(id,2))
		Duel.RaiseEvent(tc,EVENT_CUSTOM+tc:GetCode(),e,0,0,0,0)
	end
end
