--Ruthless Inferno
 local s,id=GetID()
function s.initial_effect(c)
		--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--All monsters losses Atk equal and have their effects negated
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.chngtg)
	e2:SetOperation(s.chngop)
	c:RegisterEffect(e2)
end
function s.filter1(c,e,tp)
	local lv=c:GetLevel()
	return  ((c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)) or (c:IsRace(RACE_FIEND))) and c:IsType(TYPE_SYNCHRO) 
	   and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_REMOVED ,0,1,nil,tp,c)
end
function s.rescon(tuner,scard)
	return	function(sg,e,tp,mg)
				sg:AddCard(tuner)
				local res=Duel.GetLocationCountFromEx(tp,tp,sg,scard)>0 
					and sg:CheckWithSumEqual(Card.GetLevel,scard:GetLevel(),#sg,#sg)
				sg:RemoveCard(tuner)
				return res
			end
end
function s.filter2(c,tp,sc)
	local rg=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_REMOVED ,0,c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:HasLevel() and c:IsAbleToGrave()
		and aux.SelectUnselectGroup(rg,e,tp,nil,nil,s.rescon(c,sc),0)
end
function s.filter3(c)
	return c:HasLevel() and c:IsRace(RACE_FIEND) and not c:IsType(TYPE_TUNER) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		return #pg<=0 and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if #pg>0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=g1:GetFirst()
	if sc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_REMOVED ,0,1,1,nil,tp,sc)
		local tuner=g2:GetFirst()
		local rg=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_REMOVED ,0,tuner)
		local sg=aux.SelectUnselectGroup(rg,e,tp,nil,nil,s.rescon(tuner,sc),1,tp,HINTMSG_REMOVE,s.rescon(tuner,sc))
		sg:AddCard(tuner)
		Duel.SendtoGrave(sg,REASON_EFFECT)
		Duel.SpecialSummonStep(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		--Cannot attack this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1,true)
		sc:CompleteProcedure()
	end
	Duel.SpecialSummonComplete()
end
function s.redfilter(c)
  return c:IsType(TYPE_SYNCHRO) and c:IsMonster()
 end
 function s.chngtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.redfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.redfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.opfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  local g=Duel.SelectTarget(tp,s.redfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.opfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.chngop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
   local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.opfilter,tp,LOCATION_MZONE,LOCATION_MZONE,tc)
 local all=g:GetFirst()
 local atk=tc:GetBaseAttack()
	for all in aux.Next(g) do
	  --Lose Atk equal to the target
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		all:RegisterEffect(e1)
		--Effects are negated 
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		all:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		all:RegisterEffect(e3)
	end 
end