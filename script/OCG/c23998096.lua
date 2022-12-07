--Blue-Eyes Chaos Ultimate Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	--cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.indval)
	c:RegisterEffect(e3)
	--pierce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	--Change Battle Damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e5:SetCondition(s.damcon)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
	--Extra Attack
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_DAMAGE_STEP_END)
	e6:SetCondition(s.excon)
	e6:SetOperation(s.exop)
	c:RegisterEffect(e6)
end
s.listed_names={21082832}

function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  Debug.Message(Duel.GetBattleDamage(1-tp)<3000 and (Duel.GetAttacker()==e:GetHandler() or (Duel.GetAttackTarget() and Duel.GetAttackTarget()==e:GetHandler())))
	return Duel.GetBattleDamage(1-tp)<3000 and (Duel.GetAttacker()==e:GetHandler() or (Duel.GetAttackTarget() and Duel.GetAttackTarget()==e:GetHandler()))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckEvent(EVENT_PRE_BATTLE_DAMAGE) then
		Duel.ChangeBattleDamage(1-tp,3000)
	end
end
function s.excon(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	local tp=e:GetHandlerPlayer()
	return e:GetHandler()==Duel.GetAttacker() and d and Duel.GetLP(1-tp)>=3000
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:CanChainAttack(0)then
		--Needed for the end of the Damage Step
		Duel.ChainAttack()
		--Make another attack in a row
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(s.chainop)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		--needed to check that cannot direct attack
		local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
	end
end
function s.chainop(e)
	Duel.ChainAttack()
end
