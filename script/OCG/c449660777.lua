--Performpal Dicenoble
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	--to hand (deck)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
	end
s.roll_dice=true
s.listed_series={SET_PERFORMAPAL,SET_PERFORMAGE}
function s.lvfilter(c)
	return c:IsFaceup() and c:HasLevel()
end
function s.spfilter(c,lv,e,tp)
	return c:IsSetCard(SET_PERFORMAPAL) and c:IsType(TYPE_PENDULUM) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) or
	   c:IsSetCard(SET_PERFORMAGE) and c:IsType(TYPE_PENDULUM) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end  
function s.spfilter1(c,e,tp)
	return (c:IsSetCard(SET_PERFORMAPAL) or c:IsSetCard(SET_PERFORMAGE)) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end  
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local res=Duel.TossDice(tp,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(res)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		Duel.BreakEffect()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND,0,nil,res,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.BreakEffect()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.psfilter(c)
	return c:IsFaceup() and c:HasLevel()
end
function s.addfilter(c,lv,e,tp)
	return c:IsSetCard(SET_PERFORMAPAL) and c:IsType(TYPE_PENDULUM) and c:GetScale()==lv and c:IsAbleToHand() or 
              c:IsSetCard(SET_PERFORMAGE) and c:IsType(TYPE_PENDULUM) and c:GetScale()==lv and c:IsAbleToHand()
end 
function s.pmfilter(c)
     return c:IsSetCard(SET_PERFORMAPAL) and c:IsType(TYPE_PENDULUM) or c:IsSetCard(SET_PERFORMAGE) and c:IsType(TYPE_PENDULUM)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(s.pmfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local ds=Duel.TossDice(tp,1)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.addfilter),tp,LOCATION_DECK,0,nil,ds,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
		end
	end
end