--Grea's Inferno!
--Amatuer Script by Lucyper Regod <(")

local s,id=GetID()
function s.initial_effect(c)
	--Activate -> negate -> banish -> special summon.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end


s.listed_series={SET_AZURIST} --always treat as a "Azurist" card

--retrict.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	-- Cannot Special Summon monsters, except Spellcaster monsters for 2 turns.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2,tp)
	-- Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalRace(RACE_SPELLCASTER) end)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_SPELLCASTER)
end

--filter cho neg
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_AZURIST) and c:IsSummonLocation(LOCATION_EXTRA)
end
--filter cho summon
function s.spfilter(c,e,tp,g)
	return c:IsSetCard(SET_AZURIST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
	and c:IsLocation(LOCATION_GRAVE+LOCATION_HAND) and c:IsLevel(4)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND + LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and #g>1 end
	--không bị ảnh hưởng bởi CARD_BLUEEYES_SPIRIT, mỗi phần sân có 1 ô trống, có 2 quái thú hợp lệ trở lên để kích hoạt
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then 
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
	
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<1 then return end
		local dn=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		if #g>=2 then		
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))--sửa trong database sau.
			local sg1=g:Select(tp,1,1,nil)
			local tc1=sg1:GetFirst()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
			local sg2 =g:Select(tp, 1, 1,tc1)
			local tc2=sg2:GetFirst()
			Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)
			Duel.SpecialSummon(tc2,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
