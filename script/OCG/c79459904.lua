--Princess Vampire Anne
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),5,2)
	c:EnableReviveLimit()
	--attach that vampire to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	--If your Zombie monster battles, its atk becomes double
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Special summon this card and the destroyed monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCountLimit(1,id+1)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.atcon)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
	end
	s.listed_series={SET_VAMPIRE}
	function s.filter(c)
	return c:IsSetCard(SET_VAMPIRE) and c:IsMonster()
	end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 local loc=LOCATION_GRAVE|LOCATION_HAND|LOCATION_ONFIELD
 local c=e:GetHandler()
	if chkc then return chkc:IsLocation(loc) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,loc,0,1,c) end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
local loc=LOCATION_GRAVE|LOCATION_HAND|LOCATION_ONFIELD
 local c=e:GetHandler()
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,loc,0,1,1,c)
	local tc=g:GetFirst()
	 local og=tc:GetOverlayGroup()
		if #og>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		Duel.Overlay(c,Group.FromCards(tc))
	end
	function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
	function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	if not tc then return false end
	if tc:IsControler(1-tp) then tc=Duel.GetAttacker() end
	e:SetLabelObject(tc)
	return tc and tc:IsRelateToBattle() and tc:IsRace(RACE_ZOMBIE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetDefense()*2)
		tc:RegisterEffect(e2)
	end
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
    local tc=eg:GetFirst()
    local rc=tc:GetReasonCard()
    return #eg==1 and rc:IsControler(tp) and rc:IsSetCard(SET_VAMPIRE) and tc:IsPreviousControler(1-tp) and c:IsLocation(LOCATION_GRAVE)
        and tc:IsMonster() and tc:IsReason(REASON_BATTLE) and tc:IsLocation(LOCATION_GRAVE) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
local a=Duel.GetAttacker()
	if not eg then return end
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	 and a:IsCanBeEffectTarget(e) end
	local g=Group.FromCards(a,tc)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ex1,tg1=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local ex2,tg2=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	if tg1:GetFirst():IsRelateToEffect(e) then
		Duel.SpecialSummon(tg1,0,tp,tp,false,false,POS_FACEUP)
		Duel.BreakEffect()
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
