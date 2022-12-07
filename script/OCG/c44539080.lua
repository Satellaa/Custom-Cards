--Dark Contract with The Dark World 
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
	--Unaffected by card effects 
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.immcon)
	e3:SetTarget(s.etg)
	e3:SetValue(s.efilter)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	--Activate 1 of the effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DD}
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.immcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.etg(e,c)
	return c:IsRace(RACE_FIEND) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.drcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsPreviousControler(tp)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drcfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
			--Check if the player can Draw
		local test1=Duel.IsPlayerCanDraw(tp,1)
		--Check if the player can Special summon D/D
		local test2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK,0,1,nil,e,tp)
		if not (test1 or test2) then return end
		local option=Duel.SelectEffect(tp,
			{test1,aux.Stringid(id,0)},
			{test2,aux.Stringid(id,1)})
		if option==1 then
			--Draw 2 cards then discard
				if Duel.Draw(tp,2,REASON_EFFECT)==2 then
				  Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
			end
		else
			--Special summon effect 
					local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #sc>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				end
		end
	end
