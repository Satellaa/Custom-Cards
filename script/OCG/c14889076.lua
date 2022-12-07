--White Paladin The Blue-Eyes Knight
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1,Synchro.NonTunerEx(s.matfilter),1,99)
	--Card Effect indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Extra Attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(s.excon)
	e2:SetOperation(s.exop)
	c:RegisterEffect(e2)
	--Send to Grave
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.grtg)
	e3:SetOperation(s.grop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BLUE_EYES}

function s.matfilter(c,val,sc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,sc,sumtype,tp) and c:IsRace(RACE_DRAGON,sc,sumtype,tp)
end
function s.excon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsMonster()
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
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function s.grtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,LOCATION_ONFIELD)
end
function s.bwfilter(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster()
end
function s.grop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	  --Check if you have blue eyes in grave
		if Duel.IsExistingMatchingCard(s.bwfilter,tp,LOCATION_GRAVE,0,1,nil) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		end
	end
end