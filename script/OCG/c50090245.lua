--Lunalight Cubs Dancer
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_LUNALIGHT),2,2)
	c:EnableReviveLimit()
	--Negate and Atk 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atcon)
	e1:SetOperation(s.atkup)
	c:RegisterEffect(e1)
	--Add 1 Fusion Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE +EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.addcon)
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
	--Add the Fusion Materials
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(aux.zptcon(s.mgfilter))
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_LUNALIGHT}
s.material_setcode={SET_LUNALIGHT}

function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return end
	if d:IsControler(tp) then
		e:SetLabelObject(d)
	return a:IsSetCard(SET_LUNALIGHT) and d and d:IsRelateToBattle() and d:IsFaceup() and not d:IsStatus(STATUS_BATTLE_DESTROYED)
	elseif a:IsControler(tp) then
		e:SetLabelObject(d)
		return d and a:IsRelateToBattle() 
	end
	return false
end
function s.atkup(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=e:GetLabelObject()
	local c=e:GetHandler()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		d:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		d:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		d:RegisterEffect(e2)
	end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.addfilter(c)
	return c:IsSetCard(SET_FUSION) and c:IsType(TYPE_SPELL)
 end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.addfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=g:Select(tp,1,1,nil)
		if #tc>0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsLocation(LOCATION_GRAVE)
end
function s.mgfilter(c,tp)
	local mg=c:GetMaterial()
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(SET_LUNALIGHT) 
		and c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and mg:IsExists(s.thfilter,1,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.mgfilter,1,nil,tp) end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local tc=nil
	if #eg==1 then
		tc=eg:GetFirst() --1 fusion summoned card
	else
		tc=eg:FilterSelect(tp,s.mgfilter,1,1,nil,tp):GetFirst() --1 fusion summoned card
	end
	local mg=tc:GetMaterial()
	mg:Filter(s.thfilter,nil)
	if #mg>0 then
		Duel.SendtoHand(mg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,mg)
	end
end