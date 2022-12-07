--Magician of Silent Chaos
Duel.LoadScript("SP_CARDS.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--change name
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_CHANGE_CODE)
	e6:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e6:SetValue(CARD_S_MAGICIAN)
	c:RegisterEffect(e6)
    --Draw Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCountLimit(1,id)
	e1:SetCode(EVENT_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+2)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	end
s.listed_series={SET_CHAOS,SET_SILENT_SWORDSMAN}
s.listed_names={CARD_S_MAGICIAN,CARD_CFORM}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsControler,nil,1-tp)
	if #sg>0 then
	local ct=e:GetLabel()
		local ct=Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		Duel.Draw(tp,ct,REASON_EFFECT)
	else
		local dg=sg:Select(ep,1,1,nil)
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
  return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and 
            re:IsActiveType(TYPE_SPELL)  and Duel.IsChainNegatable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	end
function s.filter2(c)
	return c:IsType(TYPE_SPELL) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
	end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
	and Duel.IsExistingMatchingCard(s.filter2,1-tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) then
   Duel.Draw(tp,1,REASON_EFFECT)
  end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CHAOS) and c:IsRitualMonster() and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) or
         c:IsSetCard(SET_SILENT_SWORDSMAN) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
	end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
