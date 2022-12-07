--Grae, Herotypic of Dark World
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,2)
	--Draw as many card(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--Target 1 Dark World
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Dark World Effect 
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.efcost)
    e3:SetOperation(s.efop)
    c:RegisterEffect(e3)
	end
	s.listed_series={0x6}
	function s.matfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_FIEND,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,scard,sumtype,tp)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE,0,nil)
		local ct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(ct)
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE,0,nil)
	local ct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,0,nil)
	local draw=Duel.Draw(p,ct,REASON_EFFECT)
	Duel.DiscardHand(p,nil,draw,draw,REASON_EFFECT+REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsSetCard(0x6)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) 
        and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0  and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND,0,1,nil,RACE_FIEND) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g1:GetFirst()
	local g=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_HAND,0,1,1,nil,RACE_FIEND)
	local tc1=g:GetFirst()
	local discard=Duel.SendtoGrave(tc1,REASON_COST+REASON_DISCARD+REASON_EFFECT)
	if discard>0 then 
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
     Duel.ConfirmCards(1-tp,tc)
     end
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    --Discard And treat as its negated opponent's
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_SEND_REPLACE)
    e1:SetValue(s.repval)
    e1:SetTarget(s.reptg)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,1-tp)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repfilter(c,tp)
    return c:IsSetCard(0x6) and c:IsMonster() and c:GetDestination()==LOCATION_GRAVE
        and c:IsControler(1-tp) and c:IsLocation(LOCATION_HAND)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return re and r&REASON_EFFECT==REASON_EFFECT
        and r&(REASON_REPLACE|REASON_REDIRECT)==0
        and eg:IsExists(s.repfilter,1,nil,tp) end
    local rg=eg:Filter(s.repfilter,nil,tp)
    Duel.SendtoGrave(rg,REASON_EFFECT+REASON_DISCARD+REASON_REDIRECT)
    for rc in rg:Iter() do
        if rc:GetReasonPlayer()==nil then rc:SetReasonPlayer(tp) end
    end
    return true
end