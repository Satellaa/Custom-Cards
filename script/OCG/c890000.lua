--Mystic Aurora Gate     ---EVE DECK
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Return Cards your opponent controls 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
	end
	s.listed_series={0x190f}
function s.retfilter(c)
	return c:IsSetCard(0x190f) and c:IsType(TYPE_PENDULUM)
end
function s.retfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_PZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.retfilter2,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_PZONE,0,1,1,nil)
	local tc=g:GetFirst()
		Duel.Destroy(tc,REASON_EFFECT)
		local retc=tc:GetScale()
		local hg=Duel.GetMatchingGroup(s.retfilter2,tp,0,LOCATION_ONFIELD,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local ct=math.min(#hg,tc:GetScale()/2)
	if ct>0 then
		local sg=hg:Select(tp,1,ct,nil)
		Duel.HintSelection(sg)
		 Duel.SendtoHand(sg,nil,REASON_EFFECT) 
         local og=Duel.GetOperatedGroup()
        if og:FilterCount(Card.IsSpell,nil)>=3 then
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsSpell),tp,LOCATION_GRAVE,0,nil,e,tp)
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
		local g2=tg:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,g2)
		Duel.SendtoHand(g2,nil,REASON_EFFECT) 
	        end
        end
   end
end