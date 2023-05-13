-- 霊炎転生
-- Reinflamenation
-- Scripted by Lilac
Duel.LoadScript("custom_constant.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- Is also treated as a "Salamangreat" card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(SET_SALAMANGREAT)
	c:RegisterEffect(e1)
	-- Special Summon 1 "Salamangreat" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_SALAMANGREAT_SANCTUARY}
s.listed_series={SET_SALAMANGREAT}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SALAMANGREAT_SANCTUARY),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.IsEnvironment(CARD_SALAMANGREAT_SANCTUARY)
end
function s.targetfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_SALAMANGREAT) and c:IsType(TYPE_EXTRA|TYPE_RITUAL)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.tdfilter(c,e,tp,tc)
	return c:IsStatus(STATUS_PROC_COMPLETE) and c:IsCode(tc:GetCode()) and c:IsAbleToDeck()
		and c:IsCanBeSpecialSummoned(e,aux.GetSummonType(c),tp,false,false) and Duel.GetMZoneCount(tp,tc)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.targetfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.targetfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.targetfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tdc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc):GetFirst()
		if tdc and Duel.SendtoDeck(tdc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) then
			local sc=tdc
			local rt=0
			if sc:IsRitualMonster() then
				rt=REASON_RELEASE
			else
				rt=REASON_MATERIAL
			end
			sc:SetMaterial(Group.FromCards(tc))
			if sc:IsType(TYPE_XYZ) then
				Duel.Overlay(sc,tc)
			else
				Duel.SendtoGrave(tc,REASON_EFFECT+rt+aux.GetReasonType(tc))
			end
			Duel.SpecialSummon(sc,aux.GetSummonType(sc),tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end