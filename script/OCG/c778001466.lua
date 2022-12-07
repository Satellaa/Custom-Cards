--Silent Sorcerer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.hdtg)
	e1:SetCondition(s.hdcon)
	e1:SetOperation(s.hdop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SILENT_MAGICIAN,SET_SILENT_SWORDSMAN}
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SILENT_MAGICIAN) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) or 
         c:IsSetCard(SET_SILENT_SWORDSMAN) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and e:GetHandler():IsFaceup() 
		and e:GetHandler():IsAbleToRemoveAsCost() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		Duel.Draw(tp,1,REASON_EFFECT)
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) and c:IsAbleToRemoveAsCost() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g2:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	              end
            end
       end