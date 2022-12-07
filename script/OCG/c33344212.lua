--Emerad, General of Dark World 
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,2,nil,nil,99)
	c:EnableReviveLimit()
	--Acclimit
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.aclcon)
	e1:SetTarget(s.acltg)
	e1:SetOperation(s.aclop)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	c:RegisterEffect(e2)
	--Add Dark World Card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCountLimit(1)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_ALL)
	e3:SetCondition(s.addcon)
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DARK_WORLD}
function s.aclcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_DARK_WORLD)
end
function s.acltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local names={}
	local cm=c:GetOverlayGroup()
	local ct=cm:FilterCount(Card.IsSetCard,nil,SET_DARK_WORLD)
	for i=1,c:GetMaterialCount() and ct do
		if i>1 and not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then break end
		local name=Duel.AnnounceCard(tp)
		table.insert(names,name)
	end
	e:SetLabelObject(names)
end
function s.aclop(e,tp,eg,ep,ev,re,r,rp)
	local names=e:GetLabelObject()
	local c=e:GetHandler()
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.effcon)
	e3:SetOperation(s.effop)
	e3:SetLabelObject(names)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local names=e:GetLabelObject()
	return re:GetHandler():IsCode(table.unpack(names))
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.changop)
end
function s.changop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return true
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.addfilter(c,e,tp)
	return c:IsSetCard(SET_DARK_WORLD) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
