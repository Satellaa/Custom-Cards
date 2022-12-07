--Performapal Odd-Eyes Magickid
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Negate effect when Pendulum summoned
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Negate effect when Summoned
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Special Summon 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1,EFFECT_COUNT_CODE_DUEL)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Gains 300 atk
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(300)
	e4:SetTarget(s.pntg)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	c:RegisterEffect(e4)
	--Cannot be destroyed battle for first time 
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetValue(s.indct)
	c:RegisterEffect(e5)
	end
	s.listed_series={SET_PERFORMAPAL,SET_MAGICIAN,SET_ODD_EYES}
	
	function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
	end
	function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,nil,tp,LOCATION_MZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_PZONE,0,e:GetHandler())
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,ct,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_PZONE,0,e:GetHandler())
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,ct,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local checkfunc=aux.PropertyTableFilter(Card.GetSetCard,SET_ODD_EYES,SET_PERFORMAPAL,SET_MAGICIAN)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	if c:GetSequence()<5 then ft=ft+1 end
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon(checkfunc),0) and ft>2
		  and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
end
function s.spfilter(c,e,tp)
	return (c:IsSetCard(SET_PERFORMAPAL) or c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_MAGICIAN)) and c:IsMonster() and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(checkfunc)
	return function(sg,e,tp,mg)
		return true,not sg:CheckDifferentProperty(checkfunc)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	  if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		local checkfunc=aux.PropertyTableFilter(Card.GetSetCard,SET_ODD_EYES,SET_PERFORMAPAL,SET_MAGICIAN)
			if #g<3 then return end
			tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon(checkfunc),1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
		end
function s.pntg(e,c,tp,r,re)
	local g=c:GetMaterial()
    	return c:IsSummonLocation(LOCATION_EXTRA) and g:IsExists(Card.IsSetCard,1,nil,SET_PERFORMAPAL)
	end
function s.indct(e,re,r,rp)
	if (r&REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end