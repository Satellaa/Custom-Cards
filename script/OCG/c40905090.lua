--Sentence Darklord
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DARKLORD),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
	--Spsummon success
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	--Destroy 1 card your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	end
	s.material_setcode={SET_DARKLORD}
	s.listed_series={SET_DARKLORD}
	if contact then sumtype=0 end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
end
function s.sumfilter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,5) then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g>0 then
		Duel.DisableShuffleCheck()
		if g:IsExists(s.sumfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:FilterSelect(tp,s.sumfilter,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	end
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:GetPreviousControler()==tp
		and (c:IsPreviousLocation(LOCATION_GRAVE)) and c:IsSetCard(SET_DARKLORD)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)~=0 and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.GetFirstTarget()
		Duel.Destroy(tc,REASON_EFFECT)
	end
