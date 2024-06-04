--Stage

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--return and normal summon

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(s.rmcost)
	--e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	--atkdown
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
--	e8:SetCategory(CATEGORY)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetCondition(s.discon)
	e8:SetTarget(s.distg)
	e8:SetOperation(s.disop)
	c:RegisterEffect(e8)

end

--Restrict for normal summoned monster
function s.disfilter(c,tp)
	return c:IsControler(tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.disfilter,1,nil,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetTargetCard(eg:Filter(s.disfilter,nil,tp))
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #g==0 then return end
	--local dg=Group.CreateGroup()
	local c=e:GetHandler()
	for tc in g:Iter() do 
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_UNRELEASABLE_SUM)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		e5:SetValue(1)
		tc:RegisterEffect(e5)
		local e6=e5:Clone()
		e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e6)
		local e3=e5:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		tc:RegisterEffect(e3)
		local e8=e5:Clone()
		e8:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e8)
		local e9=e5:Clone()
		e9:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e9)
		local e10=e5:Clone()
		--lock lock lock
		e10:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e10:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e10)
	end
end

--Filter for cost
function s.rtilter(c,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_FIEND)
end

--cost, return level 3 or lower fiend monster 
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local cg=Duel.SelectMatchingCard(tp,s.rtilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SendtoHand(cg,nil,1,REASON_COST)
end
-- Filter for normal summon
function s.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsLevelBelow(3) and c:IsRace(RACE_FIEND)
end
-- Normal summon
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local sg1=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
		if #sg1>0 then --and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg2=sg1:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sg2,true,nil)
		end
		
end



