--Darklord Samyaza
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Special summon 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--copy effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.cpcost)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DARKLORD}
function s.cfilter(c)
	return c:IsSetCard(SET_DARKLORD) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_ALL)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DARKLORD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_DECK+LOCATION_HAND) and s.spfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	 Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.cpfilter(c)
	return c:IsSetCard(SET_DARKLORD) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.cpfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	if not te then return end
	local tg=te:GetTarget()
	local op=te:GetOperation()
	if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
	Duel.BreakEffect()
	tc:CreateEffectRelation(te)
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	for etc in aux.Next(g) do
		etc:CreateEffectRelation(te)
	end
	if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
	tc:ReleaseEffectRelation(te)
	for etc in aux.Next(g) do
		etc:ReleaseEffectRelation(te)
	end
	Duel.BreakEffect()
	Duel.SendtoDeck(te:GetHandler(),nil,2,REASON_EFFECT)
end
