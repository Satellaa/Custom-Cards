--Synchro Determination
local s,id=GetID()
function s.initial_effect(c)
c:EnableCounterPermit(0x120a)
	aux.AddPersistentProcedure(c,0,aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),nil,nil,0x1c0,0x1c1,nil,nil,nil,s.operation)
	--Activate 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e1)
--Substitute destruction once for the targeted monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--self destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADD_COUNTER+0x120a)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.counter_place_list={0x120a}
function s.repfilter(c,e)
	return aux.PersistentTargetFilter(e,c) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable(e) and eg:IsExists(s.repfilter,1,nil,e)
		and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
		return e:GetHandler():IsCanAddCounter(0x120a,1)
end
function s.repval(e,c)
	return s.repfilter(c,e)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   local ct=c:GetCounter(0x120a)
	e:GetHandler():AddCounter(0x120a,1)
	if c:GetCounter(0x120a)>ct then
		Duel.RaiseEvent(c,EVENT_ADD_COUNTER+0x120a,e,REASON_EFFECT,tp,tp,1)
end
end
function s.repfilter2(c,e)
	return aux.PersistentTargetFilter(e,c)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x120a)==3
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack()*1)
		tc:RegisterEffect(e1)
end
