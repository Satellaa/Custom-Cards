-- Lycansquad Golliat
-- Scripted by Eto, and fixed by Lilac
Duel.LoadScript("custom_constant&function.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- Link Summon Procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_LYCANSQUAD),3,3)
	aux.CreateLycansquadAlterLinkProc(c,2100000053)
	-- Excavate the top cards of your Deck equal to the Link Rating of the monster shuffled into the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- Special Summon 1 "Lycansquad" monster from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={2100000053}
s.listed_series={SET_LYCANSQUAD}
function s.tdcostfilter(c,tp)
	if not c:IsLinkMonster() then return false end
	local lr=c:GetLink()
	return c:IsAbleToExtraAsCost() and #Duel.GetDecktopGroup(tp,lr)>=lr
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdcostfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(Card.Discardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,nil,1,1,REASON_COST|REASON_DISCARD)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp,s.tdcostfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	e:SetLabel(sg:GetFirst():GetLink())
	Duel.SendtoDeck(sg,nil,0,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local lr=e:GetLabel()
	-- The Duel.ConfirmDecktop function has been rewritten to return a group of excavate cards
	local g=Duel.ConfirmDecktop(tp,lr):Filter(Card.IsSetCard,nil,SET_LYCANSQUAD)
	local atkg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g>0 and #atkg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		for tc in atkg:Iter() do
			tc:UpdateAttack(#g*700,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,e:GetHandler())
		end
	end
	if lr>0 then Duel.ShuffleDeck(tp) end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LYCANSQUAD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local g=Duel.GetMatchingGroup(aux.AND(Card.IsLinkMonster,Card.IsAbleToGrave),tp,LOCATION_EXTRA,0,nil)
        if tc:IsCode(2100000053) and #g>0 and 
			Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SendtoGrave(sg,REASON_EFFECT)
            end
        end
    end
end