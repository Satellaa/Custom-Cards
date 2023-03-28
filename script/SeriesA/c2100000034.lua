-- The Azurist Origin
-- Scripted by Lilac
Duel.LoadScript("custom_constant.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- Link Summon procedure
	Link.AddProcedure(c,s.matfilter,1,1)
	-- Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Special Summon 1 Link-2 Spellcaster Link Monster from your Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AZURIST}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_AZURIST,scard,sumtype,tp) and c:IsLevel(4)
end
function s.spfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(SET_AZURIST) and not c:IsLinkMonster() and c:IsAbleToDeckOrExtraAsCost()
		and (ft>0 or c:GetSequence()<5)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,ft)
	return ft>-1 and #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,ft)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end
function s.splinkfilter(c,e,tp,mc)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLink(2) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)) then return end
	local mc=Group.FromCards(c,tc)
	if Duel.SendtoGrave(mc,REASON_EFFECT)==2 and Duel.IsExistingMatchingCard(s.splinkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mc) then
		local sc=Duel.SelectMatchingCard(tp,s.splinkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP) then
			sc:CompleteProcedure()
		end
	end
end