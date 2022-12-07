--Mystic Andere Gate
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Inflict Damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Destroy all cards 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	s.listed_series={0x190f,0x90f}
end
function s.desfilter(c)
	return c:IsSetCard(0x190f) or (c:IsSetCard(0x90f) and c:IsType(TYPE_PENDULUM))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
local loc=LOCATION_PZONE|LOCATION_MZONE
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,loc,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
local loc=LOCATION_PZONE|LOCATION_MZONE
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,loc,0,1,1,nil)
	local tc=g:GetFirst()
		Duel.Destroy(tc,REASON_EFFECT)
		Duel.Damage(1-tp,tc:GetScale()*300,REASON_EFFECT)
	end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.filter(c)
	return c:IsSetCard(0x90f)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
if not e:GetHandler():IsRelateToEffect(e) then return end
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
		local des=Duel.Destroy(sg,REASON_EFFECT)
		Duel.Damage(tp,des*1000,REASON_EFFECT)
		Duel.Damage(1-tp,des*1000,REASON_EFFECT)
end
