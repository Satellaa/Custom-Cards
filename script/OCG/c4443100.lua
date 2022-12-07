--Charco, Evil Lord of Dark World 
local s,id=GetID()
Duel.LoadScript("utopia.lua")
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Dark World Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.retcon)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DWORLD)
	end
	s.listed_series={SET_DARK_WORLD}
	function s.cfilter(c,code)
	return c:IsSetCard(code) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND)) and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	 local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil,SET_DARK_WORLD)
	if chk==0 then return aux.SelectUnselectGroup(g1,e,tp,1,1,s.rescon,0) end
	local g=aux.SelectUnselectGroup(g1,e,tp,1,1,s.rescon,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g,REASON_COST+REASON_EFFECT+REASON_DISCARD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp and c:IsPreviousControler(tp) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	return c:IsPreviousLocation(LOCATION_HAND) and r&(REASON_DISCARD+REASON_EFFECT)==REASON_DISCARD+REASON_EFFECT
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local opp_chk=e:GetLabel()
	if opp_chk==1 then
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	else
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end 
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	local opp_chk=e:GetLabel()
	if opp_chk==0 then return end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
end