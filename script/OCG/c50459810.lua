--Performapal Odd-Eyes Mufflertiger
local s,id=GetID()
function s.initial_effect(c)
	--Enable pendulum summon
	Pendulum.AddProcedure(c,false)
--Cannot be used as Synchro material 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.synlimit)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(id)
	c:RegisterEffect(e2)
	--This card's original Atk/Def is doubled
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atkup)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE)
	e4:SetValue(s.defup)
	c:RegisterEffect(e4)
	--Place 1 Face-up Performapal
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCountLimit(1,id)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg2)
	e5:SetOperation(s.thop2)
	c:RegisterEffect(e5)
	--Register the effect when activated
	local a1=Effect.CreateEffect(c)
	a1:SetType(EFFECT_TYPE_ACTIVATE)
	a1:SetCode(EVENT_FREE_CHAIN)
	a1:SetRange(LOCATION_HAND)
    a1:SetCost(s.pend)
    c:RegisterEffect(a1)
     --Draw 1 card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_PZONE)
	e6:SetCountLimit(1,id+1)
	e6:SetCondition(s.drcon)
	e6:SetTarget(s.drtg)
	e6:SetOperation(s.drop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_PERFORMAPAL}

function s.synlimit(e,c)
	if not c then return false end
	return not c:IsType(TYPE_PENDULUM)
end
function s.atkcon(e,tp,eg,ev,re,r,rp)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,1,nil,RACE_FIEND)
end
function s.atkup(e,c)
 return (c:GetBaseAttack()*2)
end
function s.defup(e,c)
 return (c:GetBaseDefense()*2)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.emfilter(c)
	return c:IsSetCard(SET_PERFORMAPAL) and c:IsType(TYPE_PENDULUM)
	end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.emfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.emfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
	   and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	 	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,nil,tp,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.SelectTarget(tp,s.emfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if #g1>0 and	Duel.SendtoExtraP(g1,tp,REASON_EFFECT)>0 and #g2>0 then
	    Duel.Destroy(g2,REASON_EFFECT)
		       end
end 
function s.pend(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
   if chk==0 then return true end
     c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	 return e:GetHandler():GetFlagEffect(id)>0 
end
function s.emfilter2(c)
	return c:IsSetCard(SET_PERFORMAPAL) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
	end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
   Duel.Draw(tp,1,1,REASON_EFFECT)
    Duel.ShuffleHand(tp)
     Duel.BreakEffect()
      local g=Duel.SelectMatchingCard(tp,s.emfilter2,tp,LOCATION_EXTRA,0,1,1,nil)
      if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
         Duel.ConfirmCards(1-tp,g)
         Duel.ShuffleHand(tp)
  else
      local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
      Duel.SendtoGrave(sg,REASON_EFFECT)
      end
   end