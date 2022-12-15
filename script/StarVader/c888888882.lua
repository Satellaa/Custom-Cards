--Doom Star-Vader, Chaos Breaker Deluge
--Scripted by Lilac-chan
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),8,3,s.ovfilter,aux.Stringid(id,0))
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
s.listed_series={0x7CC}
function s.ovfilter(c,tp,xyzc)
   return c:IsFaceup() and c:IsLevelAbove(8) and c:IsSetCard(0x7CC,xyzc,SUMMON_TYPE_XYZ,tp) and (Duel.GetCurrentPhase()==PHASE_MAIN1) and not Duel.CheckPhaseActivity()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,4) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>4 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,2,1-tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,1-tp,LOCATION_DECK)
end
function s.filter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(1-tp,4) then return end
    Duel.ConfirmDecktop(1-tp,5)
    local g=Duel.GetDecktopGroup(1-tp,5)
	local pg=g:Filter(s.filter,nil,e,1-tp)
	local ft=math.min(Duel.GetLocationCount(1-tp,LOCATION_MZONE),2)
	Duel.DisableShuffleCheck()
	if ft>0 and #pg>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local sg=pg:Select(1-tp,1,ft,nil)
		if #sg==0 then return end
		for sc in sg:Iter() do
		if Duel.SpecialSummonStep(sc,0,1-tp,1-tp,false,false,POS_FACEUP) then
        g:RemoveCard(sc)
			end
		end
	if Duel.SpecialSummonComplete()>0 then
	local og=Duel.GetOperatedGroup()
    if #og==0 then return end
    Duel.BreakEffect()
    local resetcount=1
    if Duel.IsTurnPlayer(1-tp) and Duel.GetCurrentPhase()==PHASE_END then resetcount=2 end
    aux.RemoveUntil(og,nil,REASON_EFFECT,PHASE_END,id,e,tp,
    aux.DefaultFieldReturnOp,
    function() return Duel.IsTurnPlayer(1-tp) end,
    RESET_PHASE+PHASE_END+RESET_OPPO_TURN,resetcount)
	end
end
Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REVEAL)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x7CC) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_REMOVED) then
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	if #g==2 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
  end
end