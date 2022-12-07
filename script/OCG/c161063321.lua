--Power of The Creation
local s,id=GetID()
function s.initial_effect(c)
	--Special summon 1 Monster from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		atk=g:GetFirst():GetAttack()
		Duel.SetLP(tp,Duel.GetLP(tp)-atk*2)
		local tc=g:GetFirst()
		--you cannot lose the Duel
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_LOSE_DECK)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetLabel(1)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.con)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_LOSE_LP)
		Duel.RegisterEffect(e3,tp)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
		tc:RegisterEffect(e4)
		Duel.RegisterEffect(e4,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetLabel(1-tp)
		e3:SetOperation(s.loseop)
		e3:SetReset(RESET_EVENT+0xc020000)
		tc:RegisterEffect(e3,true)
		Duel.SpecialSummonComplete()
	end
end
function s.loseop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(e:GetLabel(),WIN_REASON_RELAY_SOUL)
end
function s.con(e)
	if e:GetLabelObject() and not e:GetLabelObject():IsReason(REASON_DESTROY) then
		return true
	end
	if e:GetLabel()==0 then
		e:SetLabelObject(nil)
		return false
	else
		e:SetLabel(0)
	end
	return false
   end
		
		
		