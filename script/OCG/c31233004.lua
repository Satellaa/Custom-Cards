--White Paladin of Eyes of Blue
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTuner(nil),1,99)
	--Special Summon 1 Lvl 8 Blue Eyes 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
	--Special Summon 1 Synchro Monster
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BLUE_EYES} 

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and tg and tg:IsContains(c) and Duel.IsChainDisablable(ev)
end
function s.bwfilter(c,e,tp)
  return c:IsSetCard(SET_BLUE_EYES) and c:GetLevel()==8 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
  end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bwfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  	local sc=Duel.SelectMatchingCard(tp,s.bwfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
  	if #sc>0 then
  		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.filter1(c,e,tp,lv)
	local clv=c:GetLevel()
	return clv>0 and not c:IsType(TYPE_TUNER) and c:IsRace(RACE_DRAGON) and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+clv)
end
function s.filter2(c,e,tp,lv)
	return c:GetLevel()==lv and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) 
		and e:GetHandler():IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetLevel()) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,c,e,tp,c:GetLevel())
	g:AddCard(c)
	local tc=g:GetFirst()
	local lv=c:GetLevel()+tc:GetLevel()
	local syn=Group.FromCards(c,tc)
	if Duel.Remove(syn,POS_FACEUP,REASON_EFFECT)==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
		if #sg>0 then
			Duel.SpecialSummon(sg,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		end
	end
end
