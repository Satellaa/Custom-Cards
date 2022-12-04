--Labrynth Welcome Master
--Scripted by Satella Claudius
local s,id=GetID()
function s.initial_effect(c)
	--Activate(Special Summon)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCost(s.cost)
    e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x17f}
function s.costfilter(c)
	return c:IsSetCard(0x17f) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.filter(c,tp)
	return c:IsAbleToDeck() and c:IsLocation(LOCATION_MZONE) and not c:IsRace(RACE_FIEND)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
function s.setfilter(c)
	return not c:IsSetCard(0x17f) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.filter,1,nil,1-tp) end
	local g=eg:Filter(s.filter,nil,1-tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
        if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		Duel.SSet(tp,sg)
end
    aux.WelcomeLabrynthTrapDestroyOperation(e,tp)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local c=e:GetHandler()
	-- Cannot Special Summon from the Deck or Extra Deck, except Fiend monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and not c:IsRace(RACE_FIEND) end)
	Duel.RegisterEffect(e1,tp)
	-- Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalRace(RACE_FIEND) end)
end