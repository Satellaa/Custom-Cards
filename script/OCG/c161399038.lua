--Rank-Up-Magic Odd-eyes Force
local s,id=GetID()
function s.initial_effect(c)
	--Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	end
	s.listed_series={SET_ODD_EYES}
	function s.thfilter(c)
	return c:IsSetCard(SET_ODD_EYES) and c:IsType(TYPE_PENDULUM)
end
function s.filter(c,e,tp)
	return c:IsSetCard(SET_ODD_EYES) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,tp,0,false,false)
end
function s.filter2(c,xyz)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetRank()<xyz:GetRank()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil) and
	Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g1=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
     if tc:IsRelateToEffect(e) and Duel.SendtoExtraP(tc,tp,REASON_EFFECT)>0 then
      local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_EXTRA ,0,1,1,nil,e,tp)
	local op=g:GetFirst()
	local count=0
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft1>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if op then
		Duel.SpecialSummon(op,0,tp,tp,false,false,POS_FACEUP)
	local ov=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE,0,nil,op)
	if #ov>0 then
	 local om=ov:Select(tp,1,99,nil)
			Duel.Overlay(op,om)
	end
		end
	         end 
     end 
        end