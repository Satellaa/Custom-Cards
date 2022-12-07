--D/D/D Blood King Attila
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Attack all monsters 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Gain Atk equal to damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetCountLimit(1)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	end
	function s.filter(c,attribute)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:GetAttribute(attribute)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,att)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,att) end
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,att)
	local att=g:GetFirst():GetAttribute()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local tc=Duel.GetFirstTarget()
local att=tc:GetAttribute()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.ftarget)
	e2:SetLabel(c:GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabel(att)
		e1:SetValue(s.atkfilter)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
function s.atkfilter(e,c)
	return c:IsAttribute(e:GetLabel())
end
function s.attg(e,c)
	return c==e:GetLabel()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local ac=Duel.GetAttacker()
local dc=Duel.GetAttackTarget()
if c==ac and dc and dc:IsDefensePos() and Duel.GetBattleDamage(1-tp)>0 and c:IsHasEffect(EFFECT_PIERCE)
	then Duel.ChangeBattleDamage(1-tp,Duel.GetBattleDamage(1-tp)+1000)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r&REASON_BATTLE==0 and re
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
		end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	