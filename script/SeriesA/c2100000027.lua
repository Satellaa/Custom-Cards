-- The Azure Project
-- Scripted by Lilac
Duel.LoadScript("custom_constant.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	-- Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- Negate the activated effects of all Level 4 "Azurist" monsters when they are Special Summoned to your field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_AZURIST}
function s.counterfilter(c)
	return c:IsRace(RACE_SPELLCASTER)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	-- Cannot Special Summon monsters, except Spellcaster monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	-- Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalRace(RACE_SPELLCASTER) end)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_SPELLCASTER)
end
function s.spfilter(c,e,tp,g)
	return c:IsSetCard(SET_AZURIST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.spfilter2(c,e,tp,g,cd)
	return c:IsSetCard(SET_AZURIST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not g:IsExists(Card.IsCode,1,nil,c:GetCode()) and not c:IsCode(cd)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dn=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,dn)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and g:GetClassCount(Card.GetCode)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<1 then return end
	local dn=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,dn)
	if #g>=2 and g:GetClassCount(Card.GetCode)>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sg1=g:Select(tp,1,1,nil)
		local tc1=sg1:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local sg2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,dn,tc1:GetCode())
		local tc2=sg2:GetFirst()
		Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)
	    Duel.SpecialSummon(tc2,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
function s.disfilter(c,tp)
	return c:IsSetCard(SET_AZURIST) and c:IsFaceup() and c:IsControler(tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.disfilter,1,nil,tp)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.disfilter,nil,tp)
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_FZONE)
		e1:SetCode(EVENT_CHAIN_ACTIVATING)
		e1:SetCondition(s.discon2)
		e1:SetOperation(s.disop2)
		e1:SetLabelObject(tc)
		Duel.RegisterEffect(e1,tp)
		if tc:GetFlagEffect(tc:GetCode())==0 then break end
		tc:RegisterFlagEffect(CARD_THE_AZURE_PROJECT,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,0,1,aux.Stringid(id,3))
		Duel.RaiseEvent(tc,EVENT_CUSTOM+tc:GetCode(),e,0,0,0,0)
	end
end
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local tc1=e:GetLabelObject()
	if not (re:IsActiveType(TYPE_MONSTER)
		and Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
		and rc:IsControler(tp) and rc:IsSetCard(SET_AZURIST) and rc==tc1 and rc:IsLevel(4)) then return false end
	local evp,evp_egp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	for tc2 in aux.Next(evp_egp) do
		if rc==tc2 and evp then return true end
	end
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end