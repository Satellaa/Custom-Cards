--Vampire Caller
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	end
	s.listed_series={SET_VAMPIRE}
	function s.filter(c,e,tp)
	return c:IsSetCard(SET_VAMPIRE) and c:IsMonster() and c:IsCanBeEffectTarget()
end
function s.spfilter(c,e,tp,vamp)
	return c:GetLevel()==vamp:GetLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsCanBeEffectTarget()
	end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
		--Check if the player can summon
		local sp1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		--Check if the player can Special summon other monster 
		local sp2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,tc) and tc:IsAbleToRemoveAsCost()
		if not (sp1 or sp2) then return end
		local option=Duel.SelectEffect(tp,
			{sp1,aux.Stringid(id,0)},
			{sp2,aux.Stringid(id,1)})
		if option==1 then
			-- SpecialSummon the targeted monster 
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			--Specialsummon the other monster from opponent's GY 
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local oc=Duel.SelectMatchingCard(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,tc)
			if #oc>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(oc,0,tp,tp,false,false,POS_FACEUP)
		--Treated as a Zombie monster
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		oc:GetFirst():RegisterEffect(e1)
			end
		end
	end