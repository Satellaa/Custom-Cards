-- Reform Ancient Gear Golem
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--material check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.valop)
	c:RegisterEffect(e1)
	--Activation limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.actcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--pierce
	 local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_PIERCE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	end
s.listed_series={SET_ANCIENT_GEAR}
function s.valop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_SYNCHRO) then return end
	local g=c:GetMaterial():Filter(Card.IsSetCard,nil,SET_ANCIENT_GEAR):GetMaxGroup(Card.GetAttack)
	local tc=g:GetMaxGroup(Card.GetAttack)
	local atk=0
	for tc in aux.Next(g) do
		local tatk=tc:GetTextAttack()/2
		if tatk<0 then tatk=0 end
		atk=atk+tatk
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
function s.actcon(e)
local tp=e:GetHandlerPlayer()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and Duel.IsBattlePhase() 
end