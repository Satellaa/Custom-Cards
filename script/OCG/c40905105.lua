--Throne of The Fallen
CARD_MORNING_STAR      = 25451652
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.drcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	--Add Darklord to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition (s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Prevent destruction by effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.indcon)
	e4:SetTarget(s.indtg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	end
	s.listed_series={SET_DARKLORD}
	s.listed_names={CARD_MORNING_STAR}
function s.discardfilter(c)
	return c:IsSetCard(SET_DARKLORD) and c:IsDiscardable()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.discardfilter,1,1,REASON_COST+REASON_DISCARD)
end
	function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DARKLORD)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,2,nil) 
end  
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5) and (c:IsSummonableCard()) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	Duel.BreakEffect()
	if tc and Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then
	Duel.ConfirmCards(1-tp,tc) 
		Duel.Summon(tp,tc,true,nil,1)
	end
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MORNING_STAR),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.indtg(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end