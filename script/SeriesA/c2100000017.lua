-- Lishenna's Prayer
-- Scripted by Lilac
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0xf15)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Place 1 counter on this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.placecounter)
	c:RegisterEffect(e2)
	-- Gain LP
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.effcon)
	e3:SetTarget(s.lptg)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
	-- Place 1 "Lishenna's Destruction" from your Deck or GY to your Spell & Trap Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.effcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
s.listed_names={2100000018}
s.counter_place_list={0xf15}
function s.counterfilter(c)
	return c:GetPreviousLocation()==LOCATION_MZONE
end
function s.placecounter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.counterfilter,1,nil) then
		local ct1=eg:FilterCount(s.counterfilter,nil)
		e:GetHandler():AddCounter(0xf15,ct1)
	end
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0xf15)>7 and Duel.IsTurnPlayer(tp)
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetTargetPlayer(tp)
	local rec=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_ONFIELD,nil)*200
	Duel.SetTargetParam(rec)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_ONFIELD,nil)*200
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.Recover(p,val,REASON_EFFECT)
	if ct>199 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,2100000018),tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.BreakEffect()
		Duel.Damage(1-tp,ct,REASON_EFFECT)
	end
end
function s.setfilter(c)
	return c:IsCode(2100000018) and not c:IsForbidden()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end