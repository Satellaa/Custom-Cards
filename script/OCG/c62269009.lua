--Blod, Wicked Lord of Dark World
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),3,3)
	--Dark World Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.effcon)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--negate
  local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.discon)
    e4:SetCost(s.discost)
    e4:SetTarget(s.distg)
    e4:SetOperation(s.disop)
    c:RegisterEffect(e4)
    --Add 1 "Dark World" card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DARK_WORLD}
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE)
end
	function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
   local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_SEND_REPLACE)
    e1:SetValue(s.repval)
    e1:SetTarget(s.reptg)
    Duel.RegisterEffect(e1,1-tp)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repfilter(c,tp)
    return c:IsSetCard(SET_DARK_WORLD) and c:IsMonster() and c:GetDestination()==LOCATION_GRAVE
        and c:IsControler(1-tp) and c:IsLocation(LOCATION_HAND)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return re and r&REASON_EFFECT==REASON_EFFECT and e:GetHandler():IsInExtraMZone()
        and r&(REASON_REPLACE|REASON_REDIRECT)==0
        and eg:IsExists(s.repfilter,1,nil,tp) end
    local rg=eg:Filter(s.repfilter,nil,tp)
    Duel.SendtoGrave(rg,REASON_EFFECT+REASON_DISCARD+REASON_REDIRECT)
    for rc in rg:Iter() do
        if rc:GetReasonPlayer()==nil then rc:SetReasonPlayer(tp) end
    end
    return true
end
  function s.discon(e,tp,eg,ep,ev,re,r,rp)
	gc=e:GetHandler():GetLinkedGroup():FilterCount(aux.FaceupFilter(Card.IsSetCard,SET_DARK_WORLD),nil)
    if Duel.GetFlagEffect(tp,id)>=gc+1 then return end    
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep==1-tp and Duel.IsChainNegatable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_MONSTER) end
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	local tc1=g:GetFirst()
	local discard=Duel.SendtoGrave(tc1,REASON_COST+REASON_DISCARD+REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0
		and e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup() then
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.thfilter(c)
	return c:IsSetCard(SET_DARK_WORLD)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
		Duel.ConfirmCards(1-tp,g)
			Duel.SendtoHand(g,tp,REASON_EFFECT)
		end
	end

