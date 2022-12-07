--Time Judge
local s,id=GetID()
function s.initial_effect(c)
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Return to Extra Deck and Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.retcost)
	e3:SetOperation(s.retop)
	c:RegisterEffect(e3)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCondition(s.spcon2)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_SEPHYLON}
s.listed_series={SET_TIMELORD}
	function s.sprcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0 and
		Duel.IsExistingMatchingCard(tp,c:GetControler(),LOCATION_HAND,0,1,c,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local rg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_DISCARD,nil,nil,true)
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
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
	g:DeleteGroup()
end
function s.costfilter(c)
	return c:IsSetCard(SET_TIMELORD) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and not c:IsCode(CARD_SEPHYLON)
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	c:CopyEffect(e:GetLabel(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
end

--Check for synchro monster in the extra deck
function s.scfilter(c,monster1,tuner)
	if not monster1:IsLevel(9) then
		monster1:AssumeProperty(ASSUME_LEVEL,9)
	end
	local mg=Group.FromCards(monster1,tuner)
	return c:IsSynchroSummonable(nil,mg)
end
--Check for timelord monster from hand or GY
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_TIMELORD) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,c,e:GetHandler())
end
--Condition for "Be targeted by an opponent's effect"
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and rp==1-tp
end
--Condition for "be targeted by an opponent's attack"
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and Duel.GetAttacker():IsControler(1-tp)
end
--Activation legality check
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	local c=e:GetHandler()
	--Special Summon monster from hand or GY
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Level becomes 9
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(9)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
	if not c:IsRelateToEffect(e) then return end
	local mg=Group.FromCards(c,tc)
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,tc,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end