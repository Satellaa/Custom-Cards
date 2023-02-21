-- Tierkreis Astralstrike
-- Scripted by Lilac
local s,id=GetID()
function s.initial_effect(c)
	-- Place 1 "Tierkreis" monster on top of your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.plcost)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	-- Activate from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	-- Prevent battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.nodamcon)
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(s.nodamop)
	c:RegisterEffect(e3)
end
s.listed_series={0xf11}
function s.tgfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(0xf11) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
function s.filter1(c,att)
	return c:IsMonster() and c:IsSetCard(0xf11) and not c:IsAttribute(att)
end
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.DiscardHand(tp,s.tgfilter,1,1,REASON_COST+REASON_DISCARD,nil,tp)
	e:SetLabel(Duel.GetOperatedGroup():GetFirst():GetAttribute())
end
function s.filter2(c)
	return c:IsSetCard(0xf11) and c:IsMonster()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local tc=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel()):GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end
function s.handcon(e,c)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(1-e:GetHandlerPlayer(),LOCATION_ONFIELD,0)>0
end
function s.nodamcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>0 and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_AVOID_BATTLE_DAMAGE)
end
function s.nodamop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_AVOID_BATTLE_DAMAGE) then return end
	--No battle damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end