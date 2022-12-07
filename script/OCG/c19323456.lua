--Mystic Lumen Gate
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Direct Attack 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	end
	s.listed_series={0x190f}
	s.listed_names={45556790}
	function s.desfilter(c)
	return c:IsSetCard(0x190f) and c:IsType(TYPE_PENDULUM)
end
function s.desfilter2(c)
	return c:IsType(TYPE_MONSTER)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
local loc=LOCATION_PZONE|LOCATION_MZONE
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_PZONE,0,1,nil) and Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
local loc=LOCATION_PZONE|LOCATION_MZONE
local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_PZONE,0,1,1,nil)
	local tc=g:GetFirst()
		Duel.Destroy(tc,REASON_EFFECT)
		local tc1=g1:GetFirst()
		local e1=Effect.CreateEffect(c)
	     e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_DIRECT_ATTACK)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc1:RegisterEffect(e1)
		if tc:IsCode(45556790) then
			Duel.BreakEffect()
			--Opponent cannot activate spells/traps until end of damage step
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetOperation(s.atkop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc1:RegisterEffect(e2)
		tc1:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,3201)
		end
	end
	function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and not re:GetHandler():IsImmuneToEffect(e)
end