-- Tierkreis Stellarealm
-- Scripted by Lilac
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Monsters opponent controls cannot attack the turn they activate they effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	c:RegisterEffect(e1)
	-- Activate this card from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.actcost)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	-- Draw 1 card for every 1000 damage inflicted to your opponent
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.drwtg)
	e3:SetOperation(s.drwop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
	s[0]=0
	s[1]=0
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_CHAINING)
	ge1:SetOperation(s.checkop)
	Duel.RegisterEffect(ge1,0)
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge2:SetCode(EVENT_DAMAGE)
	ge2:SetCondition(s.gecon)
	ge2:SetOperation(s.checkop2)
	Duel.RegisterEffect(ge2,0)
	local ge3=Effect.CreateEffect(c)
	ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge3:SetCode(EVENT_ADJUST)
	ge3:SetCountLimit(1)
	ge3:SetOperation(s.clear)
	Duel.RegisterEffect(ge3,0)
  end)
end
s.listed_series={0xf11}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local c=re:GetHandler()
	if c:IsMonster() then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.atkcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end
function s.atktg(e,c)
	return c:GetFlagEffect(id)>0
end
function s.cfilter(c)
	return c:IsSetCard(0xf11) and c:IsDiscardable()
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.ActivateFieldSpell(c,e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.gecon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	return (r&REASON_EFFECT)~=0
end
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then
		s[tp]=s[tp]+ev
	end
	if ep==1-tp then
		s[1-tp]=s[1-tp]+ev
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=s[1-tp]
	local dct=math.floor(ct/500)
	if chk==0 then return dct>0 and Duel.IsPlayerCanDraw(tp,dct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(dct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,dct)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local ct=s[1-tp]
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Draw(p,math.floor(ct/500),REASON_EFFECT)
end
