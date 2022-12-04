local s,id=GetID()
function s.initial_effect(c)
	--Negate Spell effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
    --Special Summon from your GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x15a}
function s.cfilter(c,seq,p)
	return c:IsFaceup() and c:IsSetCard(0x15a) and c:IsColumn(seq,p,LOCATION_SZONE)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_SPELL) then return false end
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and (loc&LOCATION_SZONE==0 or rc:IsControler(1-p)) then
		if rc:IsLocation(LOCATION_SZONE) and rc:IsControler(p) then
			seq=rc:GetSequence()
			loc=LOCATION_SZONE
		else
			seq=rc:GetPreviousSequence()
			loc=rc:GetPreviousLocation()
		end
	end
	return loc&LOCATION_SZONE==LOCATION_SZONE and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,seq,p)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.thfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x15a) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.thfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x15a) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and c:GetSequence()<5
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x15a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		local b=false
		if ft>0 then
			b=Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		else
			b=Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_MZONE,0,1,nil)
		end
		return b and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g1=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	if ft>0 then
		g1=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	else
		g1=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	if tc1:IsRelateToEffect(e) and Duel.SendtoGrave(tc1,REASON_EFFECT)>0 and tc1:IsLocation(LOCATION_GRAVE) 
		and tc2:IsRelateToEffect(e) and (aux.nvfilter(tc2) or not Duel.IsChainDisablable(0)) then
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end