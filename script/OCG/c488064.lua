--Mystic Humus Gate
local s,id=GetID()
function s.initial_effect(c)
--pendulum summon
	Pendulum.AddProcedure(c)
  --Indestructable by effect 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.indct)
	c:RegisterEffect(e1)
	--Negate attack
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
end
	s.listed_series={0x90f,0x190f}
     function s.indtg(e,c)
	return c:IsSetCard(0x90f) and c~=e:GetHandler()
end
function s.indct(e,re,r,rp)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 2 and rp==1-e:GetHandlerPlayer()
	else return 0 end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.filter(c)
	return c:IsSetCard(0x190f)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_PZONE,0,1,1,nil)
	local tc=g:GetFirst()
		Duel.Destroy(tc,REASON_EFFECT)
	Duel.NegateAttack()
end
