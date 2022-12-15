--Star-Vader, Chaos Breaker Dragon
--Scripted by Lilac-chan
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCountLimit(1)
	e2:SetTarget(s.rtg)
	e2:SetOperation(s.rop)
	c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
  end)
end
s.listed_series={0x7CC}
function s.cfilter(c,p)
	return c:IsPreviousControler(p) and c:IsFaceup() and c:IsMonster()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local tg=eg:Filter(s.cfilter,nil,p)
		for tc in aux.Next(tg) do
			Duel.RegisterFlagEffect(1-p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>=2 and Duel.IsMainPhase()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
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
    if aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,
    aux.DefaultFieldReturnOp,
    function() return Duel.IsTurnPlayer(1-tp) end,
    RESET_PHASE+PHASE_END+RESET_OPPO_TURN,resetcount) then
     if Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) then
     Duel.Draw(tp,1,REASON_EFFECT)
	 Duel.Draw(1-tp,1,REASON_EFFECT)
end
end
end
end
function s.tgfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_REMOVED) and c:IsControler(tp) and not c:IsReason(REASON_SPSUMMON)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_END) and eg:IsExists(s.tgfilter,1,nil,1-tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return (Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 or 
    Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0) and Duel.IsPlayerCanDraw(tp) end
	local g=eg:Filter(s.tgfilter,nil,1-tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.tgfilter,nil,1-tp)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT) then
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	if ct>0 and Duel.DiscardHand(tp,nil,ct,ct,REASON_EFFECT+REASON_DISCARD) then
	Duel.Draw(tp,ct,REASON_EFFECT)
end
end
end