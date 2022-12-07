--Encode Talker Extended 
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2)
	--change name
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetRange(LOCATION_ONFIELD)
	e4:SetValue(6622715)
	c:RegisterEffect(e4)
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={6622715}
	function s.efilter(e,re,rp)
	return re:GetHandler():IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and tp~=e:GetHandlerPlayer()
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	local a=Duel.GetAttacker()
	local b=a:GetBattleTarget()
	if not b then return false end
	if a:IsControler(1-tp) then a,b=b,a end
	return a:GetControler()~=b:GetControler()
		and lg:IsContains(a) and a:IsFaceup() and b:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local b=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,b=b,a end
	if a:IsRelateToBattle() then
		Duel.Remove(b,POS_FACEUP,REASON_EFFECT)
		local e2=Effect.CreateEffect(c)
	    e2:SetType(EFFECT_TYPE_SINGLE)
	    e2:SetCode(EFFECT_UPDATE_ATTACK)
	    e2:SetValue(b:GetAttack())
	    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	    c:RegisterEffect(e2)
	end
end