--Firewall Fatal Dragon 
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local g2=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g1>0 or #g2>0 end
	if #g1>0 and #g2<=0 then
		e:SetLabel(0) 
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
	elseif #g2>0 and #g1<=0 then
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,#g2,0,0)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		e:SetLabel(op)
		if op==0 then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
		else
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,#g2,0,0)
		end
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g
	if e:GetLabel()==0 then
		g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	else 
		g=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_ONFIELD,nil) 
	end
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_EFFECT+REASON_BATTLE)~=0
end
function s.spfilter(c,e,tp)
	return c:IsLinkMonster() and c:IsRace(RACE_CYBERSE) and c:GetLink()==4 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

