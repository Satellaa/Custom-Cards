--Mystical Elf With Eyes of Blue
local s,id=GetID()
function s.initial_effect(c)
  --Spsummon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Gains 300 atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(200)
	e3:SetTarget(s.atktg)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e3)
end
s.listed_series={SET_BLUE_EYES}
s.listed_names={24382602}

function s.spfilter(c,ft)
	return c:IsFaceup() and c:IsMonster() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave() and (ft>0 or c:GetSequence()<5)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter(chkc,ft) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil,ft)
		and ft>-1 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
end
function s.thfilter(c)
  	if not c:IsAbleToHand() then return end
	if c:IsLocation(LOCATION_DECK) then 
	return c:IsCode(24382602)
	else
		return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER)
		end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.rescon(sg,e,tp,mg)
		return sg:FilterCount(Card.IsMonster,nil)<=1 and sg:FilterCount(Card.IsSpell,nil)<=1
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #sg<=2 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.atktg(e,c,tp,r,re)
    	return c:IsSetCard(SET_BLUE_EYES) and  c:IsMonster()
	end