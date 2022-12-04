--Number C89: Infierno the Mind Hacker
local s,id=GetID()
function s.initial_effect(c)
	--Phải được Triệu hồi đúng cách trước khi gọi lại từ GY
	c:EnableReviveLimit()
	--Điều kiện Xyz
	Xyz.AddProcedure(c,nil,8,3,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.rmvcon)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.rmvtg)
	e1:SetOperation(s.rmvop)
	c:RegisterEffect(e1)
    --banish deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCost(s.dkcost)
    e2:SetCondition(s.dkcon)
	e2:SetTarget(s.dktg)
	e2:SetOperation(s.dkop)
	c:RegisterEffect(e2)
end
s.xyz_number=89
s.listed_names={95474755}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,95474755)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.rmvcon(e,tp,eg,ep,ev,re,r,rp)
	local activateLocation = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION)
    return ep~=tp and re:IsActiveType(TYPE_MONSTER) and (activateLocation==LOCATION_GRAVE or activateLocation==LOCATION_HAND)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil,tp,POS_FACEDOWN) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g~=0 then
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
 end
end
function s.dkcfilter2(c)
	return c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.dkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dkfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.dkfilter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.dkfilter(c,tp)
	return c:IsFacedown() and c:IsControler(1-tp) and not (c:GetReasonEffect():GetHandler():IsCode(999880995) or Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE)==999880995)
end
function s.dkcon(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   return eg:IsExists(s.dkfilter,1,nil,tp) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,95474755)
end
function s.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
function s.dkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3)
	if #g==0 then return end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end