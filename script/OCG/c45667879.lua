--Scarlet Resonator
local s,id=GetID()
function s.initial_effect(c)
	--special summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Treat its level as another level, if will be used as synchro material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- Can be used as a non-Tuner for the Synchro Summon of a DARK Dragon monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_NONTUNER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.ntval)
	c:RegisterEffect(e3)
	end
	function s.cfilter(c)
	return c:IsFacedown() or not (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.lvfilter(c)
	if not c:IsMonster() then return end
	if c:IsLocation(LOCATION_MZONE) then 
	return c:IsFaceup() and c:GetOriginalLevel()>0 and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR))
	else
		return c:GetOriginalLevel()>0 and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_FIEND) or c:IsRace(RACE_WARRIOR)) 
		end
end
function s.opfilter(c)
  return c:IsMonster() and c:IsFaceup() and c:GetOriginalLevel()>0 
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
	if chk==0 then return true end
		local b1=Duel.IsExistingMatchingCard(s.opfilter,tp,0,LOCATION_MZONE,1,c)
		local b2=Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c)
		local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	e:SetCategory(0)
	if op==1 then
		e:SetCategory(CATEGORY_LVCHANGE)
		local g=Duel.GetMatchingGroup(s.opfilter,tp,0,LOCATION_MZONE,c)
		Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,1,tp,0)
		elseif op==2 then
		  e:SetCategory(CATEGORY_LVCHANGE)
		  local g1=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c)
			Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g1,1,tp,LOCATION_MZONE+LOCATION_HAND)
		 end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,s.opfilter,tp,0,LOCATION_MZONE,1,1,c)
		if #g>0 then
			local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_LEVEL)
		e1:SetValue(g:GetFirst():GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,g:GetFirst():GetOriginalLevel())
			 end
	elseif op==2 then
	  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g1=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,c)
		if #g1>0 then
			local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_LEVEL)
		e1:SetValue(g1:GetFirst():GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,g1:GetFirst():GetOriginalLevel())
		      end
		   end
end
 function s.ntval(c,sc,tp)
	return sc and sc:IsAttribute(ATTRIBUTE_DARK) and sc:IsRace(RACE_DRAGON) and sc:IsMonster()
end