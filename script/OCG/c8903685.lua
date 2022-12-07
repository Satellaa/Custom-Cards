--Blue-Eyes Battle Ox
--Scripted by Playmaker
local s,id=GetID()
function s.initial_effect(c)
	--spsumon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Fusion Summon Effect
		local e1=Fusion.CreateSummonEff({handler=c,fusfilter=s.fusfilter,matfilter=Fusion.OnFieldMat(Card.IsAbleToDeck)
	  ,extrafil=s.extrafil,extraop=Fusion.ShuffleMaterial,stage2=s.stage2})
	local tg=e1:GetTarget()
	local op=e1:GetOperation()
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetTarget(s.target(tg))
	e1:SetOperation(s.operation(op))
	e1:SetCost(s.cost(tg))
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup()
end
function s.spfilter(c,e,tp)
	return ((c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_TUNER)) or (c:IsMonster() and c:IsType(TYPE_NORMAL)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
		  local name=g:GetFirst():GetCode()
		  local lvl=g:GetFirst():GetLevel()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			--Change the code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(name)
	tc:RegisterEffect(e1)
	--Change the level
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(lvl)
	tc:RegisterEffect(e2)
		end
	end
end
function s.fusfilter(c)
	return c:IsLevel(6) or c:IsLevel(12) 
end
function s.target(target)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			if e:GetLabel()==0 then
				return target(e,tp,eg,ep,ev,re,r,rp,0)
			end
			e:SetLabel(0)
			return true
		end
		e:SetLabel(0)
		return target(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function s.operation(operation)
	return function(e,...)
		e:SetLabel(1)
		local res=operation(e,...)
		e:SetLabel(0)
		return res
	end
end
function s.check(e)
	return function(tp,sg,fc)
		return e:GetLabel()==1 or (not e:GetLabelObject() or not sg:IsContains(e:GetLabelObject()))
	end
end
function s.extrafil(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,c),s.check(e)
end
function s.costfilter(c,target,e,tp,eg,ep,ev,re,r,rp,chk,self)
	e:SetLabelObject(c)
	local res=c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
				and self:IsAbleToRemoveAsCost() and target(e,tp,eg,ep,ev,re,r,rp,0)
	e:SetLabelObject(nil)
	return res
end
function s.cost(target)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
		  local self=e:GetHandler()
			e:SetLabel(0)
			local res=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,target,e,tp,eg,ep,ev,re,r,rp,chk,self)
			if res then e:SetLabel(1) end
			return res
		end
		local self=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(self,POS_FACEUP,REASON_COST)
		e:SetLabelObject(self)
	end
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	if chk==1 then
		local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3208)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	   end
	end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
end