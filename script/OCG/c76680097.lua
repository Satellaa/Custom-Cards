--Red Dragon Ascension
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Send "Resonator" monsters from deck to GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sdtg)
	e2:SetOperation(s.sdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RED_DRAGON_ARCHFIEND,SET_RESONATOR}
function s.filter(c)
	return (c:IsSetCard(SET_RED_DRAGON_ARCHFIEND) or c:IsType(TYPE_TUNER)) and c:IsFaceup() and c:HasLevel() and c:IsAbleToDeck()
end
function s.filter2(c,e,tp,level)
	return c:IsSetCard(SET_RED_DRAGON_ARCHFIEND) and c:IsType(TYPE_SYNCHRO)
		and c:IsLevel(level) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	local lvl = sg:GetSum(Card.GetLevel)
	return sg:FilterCount(Card.IsSetCard,nil,SET_RED_DRAGON_ARCHFIEND)==1
		and Duel.GetLocationCountFromEx(tp,tp,sg,TYPE_SYNCHRO)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,lvl)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>1 and aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(rg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,rg,#rg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tdg=Duel.GetTargetCards(e)
	if #tdg==0 then return end
	if Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.GetLocationCountFromEx(tp,tp,nil,nil)>0 then
		local og=Duel.GetOperatedGroup()
		local lv=og:GetSum(Card.GetLevel)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv):GetFirst()
		if tc then
			Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
function s.sdfilter(c)
	return c:IsSetCard(SET_RESONATOR) and c:IsMonster() and c:IsAbleToGrave()
end
function s.redfilter(c)
  return c:IsSetCard(SET_RED_DRAGON_ARCHFIEND) and c:IsType(TYPE_SYNCHRO)
  end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
 if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.redfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.sdfilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
  and ct>0 and Duel.IsExistingTarget(s.redfilter,tp,LOCATION_MZONE,0,1,nil) end
  local g=Duel.SelectTarget(tp,s.redfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
   local tc=Duel.GetFirstTarget()
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(s.sdfilter,tp,LOCATION_DECK,0,nil)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),#g,ct)
	if ft<=0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,nil,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(sg,REASON_EFFECT)
	local cto=sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(cto)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	    tc:RegisterEffect(e1)
end