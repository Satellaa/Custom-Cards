--you can not
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE, CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) > 0

end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end

end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local TopBan = Duel.GetDecktopGroup(tp,1)
	if Duel.Remove(TopBan,POS_FACEUP,REASON_COST) then
		local BanCard=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
		Duel.SendtoGrave(BanCard,REASON_EFFECT+REASON_RETURN)
		
		local GYcard = Duel.GetFieldGroup(tp, LOCATION_GRAVE,LOCATION_GRAVE)
		Duel.Remove(GYcard,POS_FACEUP,REASON_EFFECT)
	end
end
