--Paladin Armor
Duel.LoadScript("SP_CARDS.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.addcon)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
	--disable field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1)
	e4:SetCondition(s.discon)
	e4:SetCost(s.discost)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_POLYMERIZATION,CARD_EYE_TIMAEUS}
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.thfilter(c)
	return (c:IsCode(CARD_POLYMERIZATION) or c:IsCode(CARD_EYE_TIMAEUS)) and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()&PHASE_MAIN1+PHASE_MAIN2~=0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.tgfilter(c,tp)
	return c:GetColumnGroup():IsExists(s.gyfilter,1,nil,tp)
end
function s.gyfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_FUSION)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.disop(e,tp)
    local c=e:GetHandler()
    local fg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_FUSION),tp,LOCATION_MZONE,0,nil)
    local zone=0
    for tc in fg:Iter() do
        local dz=tc:GetColumnZone(LOCATION_MZONE,nil,nil,1-tp)
        zone=zone|dz<< 16
     local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PUBLIC)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.ngop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
    end
    return zone
end
function s.ngop(e,tp)
	local c=e:GetHandler()
    local fg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_FUSION),tp,LOCATION_MZONE,0,nil)
    local zone=0
    for tc in fg:Iter() do
        local dz=tc:GetColumnZone(LOCATION_MZONE,nil,nil,1-tp)
        zone=zone|dz<< 16
    end
    return zone
end