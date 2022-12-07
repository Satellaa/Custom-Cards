--Decode Talker HeatRokket
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_LINK),3)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.imfilter)
	e2:SetCondition(s.imcon)
	c:RegisterEffect(e2)
	--atk gain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Second attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(s.atcon)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
	end
function s.imcon(e)
	return not Duel.IsExistingMatchingCard(aux.NOT(aux.FaceupFilter(Card.IsType,TYPE_LINK)),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
 end 
	function s.imfilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),nil)
	return g:GetSum(Card.GetLink)*300
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():CanChainAttack()
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	Duel.ChainAttack()
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end