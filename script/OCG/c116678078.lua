--Junk Temp
Duel.LoadScript("ARCHTYPES")
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(20932152)
	c:RegisterEffect(e1)
-- Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.gspcon)
	e2:SetTarget(s.gsptg)
	e2:SetOperation(s.gspop)
	c:RegisterEffect(e2)
	--effect gain
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e5:SetCondition(s.efcon)
	e5:SetOperation(s.efop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_JUNK,SET_SYNCHRON}
function s.gspconfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:GetSummonLocation(LOCATION_EXTRA)
end
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gspconfilter,1,nil,1-tp)
end
function s.disfilter(c,p)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and not c:IsControler(p)
	end
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		eg:IsExists(s.disfilter,1,nil,tp,nil) end
	    local tg=eg:Filter(s.disfilter,nil,tp,nil)
		Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	end
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	local tg=Duel.GetTargetCards(e)
	tg:ForEach(function(tc)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e2)
		end)
		end
	function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_SYNCHRO)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():GetReasonCard():IsSetCard(SET_JUNK)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e3=Effect.CreateEffect(rc)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(aux.StardustCost)
	e3:SetCondition(s.discon2)
	e3:SetTarget(s.distg2)
	e3:SetOperation(s.disop2)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e3,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	      end
      end
      function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end