-- フォービデン・ノレッジ
-- Forbidden Knowledge
-- Scripted by Lilac
local s,id=GetID()
function s.initial_effect(c)
    	-- Add 1 card from your Deck to your hand
     	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Opponent can negate this effect by halve their LP
	if Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.SetLP(1-tp,math.floor(Duel.GetLP(1-tp)/2),REASON_EFFECT)
		if Duel.IsChainDisablable(0) then
			Duel.NegateEffect(0)
			return
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
        	e1:SetLabel(1-tp)
		e1:SetOperation(s.loseop)
		Duel.RegisterEffect(e1,tp)
	end
 end
function s.loseop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(e:GetLabel(),0x99)
end
