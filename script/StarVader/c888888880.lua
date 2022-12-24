--Star-Vader, Chaos Breaker Close
--Scripted by Lilac-chan
local s,id=GetID()
function s.initial_effect(c)
     	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.remtg)
	e1:SetOperation(s.remop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_VADER)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
    	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
    	e3:SetCondition(s.rcon)
	e3:SetTarget(s.rtg)
	e3:SetOperation(s.rop)
	c:RegisterEffect(e3)
    	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
end
s.listed_series={0x7CC}
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
   	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsFacedown() or tc:IsType(TYPE_SPELL+TYPE_TRAP) then Duel.SendtoGrave(tc,REASON_EFFECT)
        elseif tc:IsFaceup() and tc:IsMonster() then
    local resetcount=1
    if Duel.IsTurnPlayer(1-tp) and Duel.GetCurrentPhase()==PHASE_END then resetcount=2 end
    aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,
    aux.DefaultFieldReturnOp,
    function() return Duel.IsTurnPlayer(1-tp) end,
    RESET_PHASE+PHASE_END+RESET_OPPO_TURN,resetcount)
 end
end
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&REASON_DISCARD)~=0
end
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
    local resetcount=1
    if Duel.IsTurnPlayer(1-tp) and Duel.GetCurrentPhase()==PHASE_END then resetcount=2 end
    aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,
    aux.DefaultFieldReturnOp,
    function() return Duel.IsTurnPlayer(1-tp) end,
    RESET_PHASE+PHASE_END+RESET_OPPO_TURN,resetcount)
 end
end
