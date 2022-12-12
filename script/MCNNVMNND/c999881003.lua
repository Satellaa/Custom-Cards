-- リアンの蟲惑魔
-- Traptrix Heliamphora
-- Scripted by Lilac-chan
local s,id=GetID()
function s.initial_effect(c)
	-- Unaffected by the effects of "Hole" Normal Traps
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.immfilter)
	c:RegisterEffect(e1)
	-- SpSummon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetCondition(s.spcon2)
	c:RegisterEffect(e3)
    -- Allow Trap activation in the same turn it's set
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SSET)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.atstg)
	e4:SetOperation(s.atsop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_TRAPTRIX,SET_HOLE}
function s.immfilter(e,te)
	local c=te:GetOwner()
	return c:IsNormalTrap() and (c:IsSetCard(SET_HOLE) or c:IsSetCard(SET_TRAP_HOLE))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:GetType()==TYPE_TRAP and (c:IsSetCard(SET_HOLE) or c:IsSetCard(SET_TRAP_HOLE))
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and c:IsSetCard(SET_TRAPTRIX)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atsfilter(c,tp)
	return c:IsFacedown() and c:IsPreviousLocation(LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED) and c:GetSequence()<5 and c:IsControler(tp)
end
function s.atstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.atsfilter,1,nil,tp) end
	local g=eg:Filter(s.atsfilter,nil,tp)
	Duel.SetTargetCard(eg)
end
function s.atsfilter2(c)
	return c:IsNormalTrap() and (c:IsSetCard(SET_HOLE) or c:IsSetCard(SET_TRAP_HOLE))
end
function s.atsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
    if #g>0 then
    Duel.ConfirmCards(tp,g)
    if g:IsExists(s.atsfilter2,1,nil) then
    local tc=g:Filter(s.atsfilter2,nil)
    if tc then end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCountLimit(1,{id,2})
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetCondition(s.accon)
	e1:SetTarget(function(e,c) return c:GetType()==TYPE_TRAP end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
   end
  end
 end
function s.accon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_TRAPTRIX),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
 end