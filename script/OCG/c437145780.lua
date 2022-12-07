--Phantom of Fury 
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,0,s.tgfilter,nil,nil,0x1c0,0x1c1,nil,nil,nil,s.operation)
	--Activate 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.PersistentTargetFilter)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--destroy
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.descon)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	end
	s.listed_series={0x145}
	function s.tgfilter(c,e)
	return c:IsSetCard(0x145) and c:IsType(TYPE_FUSION)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_ONFIELD)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
  local tc=c:GetFirstCardTarget()
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	--cannot attack
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetTargetRange(LOCATION_MZONE,0)
			e3:SetLabelObject(tc)
			e3:SetTarget(s.atktg)
			e3:SetReset(RESET_PHASE+PHASE_END,2)
			Duel.RegisterEffect(e3,tp)
		end
function s.atktg(e,c)
	return e:GetLabelObject()~=c
end