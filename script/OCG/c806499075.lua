--NEO
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--return
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCode(EFFECT_SEND_REPLACE)
	e5:SetCountLimit(1,id+1)
	e5:SetTarget(s.reptg)
	c:RegisterEffect(e5)
--Neos EnableNeosReturn 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+2)
	e1:SetCondition(Auxiliary.NeosReturnCondition1)
	e1:SetTarget(Auxiliary.NeosReturnTarget(c,extrainfo))
	e1:SetOperation(Auxiliary.NeosReturnOperation(c,extraop))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(0)
	e2:SetCondition(Auxiliary.NeosReturnCondition2)
	c:RegisterEffect(e2)
	if returneff then
		e1:SetLabelObject(returneff)
		e2:SetLabelObject(returneff)
	end
end
s.listed_names={CARD_NEOS}
s.listed_series={0x1f}
function s.filter2(c,e,tp)
	return c:IsSetCard(0x1f) and c:IsAbleToGrave() and c:IsCanBeFusionMaterial()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local o=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(o,REASON_COST)
	local o=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.SetTargetCard(o)
end
function s.filter(c,e,tp,mc)
if Duel.GetLocationCountFromEx(tp,tp,mc,c)<=0 then return false end
	local mustg=aux.GetMustBeMaterialGroup(tp,nil,tp,c,nil,REASON_FUSION)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false)
		and aux.IsMaterialListCode(c,mc:GetCode()) and (#mustg==0 or (#mustg==1 and mustg:IsContains(mc)))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeFusionMaterial() and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(Group.FromCards(tc))
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL)
			Duel.BreakEffect()
			Duel.SpecialSummon(sc,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
function Auxiliary.NeosReturnCondition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(42015635)
end
function Auxiliary.NeosReturnCondition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(42015635)
end
function Auxiliary.NeosReturnTarget(c,extrainfo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
		if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function Auxiliary.NeosReturnSubstituteFilter(c)
	return c:IsCode(14088859) and c:IsAbleToRemoveAsCost() or c:IsCode(806499075) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.NeosReturnOperation(c,extraop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		local sc=Duel.GetFirstMatchingCard(Auxiliary.NecroValleyFilter(Auxiliary.NeosReturnSubstituteFilter),tp,LOCATION_GRAVE,0,nil)
		if sc and Duel.SelectYesNo(tp,aux.Stringid(806499075,0)) then
			Duel.Remove(sc,POS_FACEUP,REASON_COST)
		else
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		end
		if c:IsLocation(LOCATION_EXTRA) then
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetDestination()==(LOCATION_REMOVED) end
		Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
end
