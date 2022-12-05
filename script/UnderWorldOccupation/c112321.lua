local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local orig=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local g=Duel.GetDecktopGroup(tp,orig)
		return g:FilterCount(Card.IsAbleToHand,nil)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil)
	local ids={}
	for tc in aux.Next(g) do
		ids[tc:GetCode()]=true
	end
	s.announce_filter={}
	for code,i in pairs(ids) do
		if #s.announce_filter==0 then
			table.insert(s.announce_filter,code)
			table.insert(s.announce_filter,OPCODE_ISCODE)
		else
			table.insert(s.announce_filter,code)
			table.insert(s.announce_filter,OPCODE_ISCODE)
			table.insert(s.announce_filter,OPCODE_OR)
		end
	end
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.rmfilter(c,ac)
	return c:IsCode(ac) and c:IsAbleToRemove()
end

function s.Indeckfilter(c,ac)
	return c:IsCode(ac)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)

	local g=Duel.GetMatchingGroup( s.rmfilter,tp,LOCATION_DECK,0,nil,ac) --Trong deck có thể banish
	local Indeck=Duel.GetMatchingGroup(s.Indeckfilter,tp,LOCATION_DECK,0,nil,ac) --Trong deck

	local trueMount = #g
	if #g>0 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	elseif #Indeck == 1 then
		Duel.Hint(HINTMSG_CONFIRM,tp,HINTMSG_CONFIRM)
	end
	--Kiểm tra số lượng cần, 3 ban 2 2 ban1 1 ban 0, <(") hơi nhiều if
	local ban = 2

	if trueMount == 2 then
		ban = 1 
	end
	if trueMount == 1 then 
		ban = 0
	end	
	if trueMount == 0 and #Indeck > 1 then 
	
		return
	elseif #Indeck == 1 then 
		ban = 0	
	end		
	
	--Kết thúc kiểm tra

	if ban >= 1 then
	
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,ban,ban,nil,ac)
	else
	
		local g=Duel.SelectMatchingCard(tp,s.Indeckfilter,tp,LOCATION_DECK,0,1,1,nil,ac)
	end

	if ban ==1 or ban ==2 then --nếu như không ban được thì effect resolve no eff? ví dụ như Lancea
		local tc=g:GetFirst()
		if ban == 1 and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT) then
		Duel.ShuffleDeck(tp)
		local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local dem = 0
		local target = Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,nil,ac)
		TrueTarget=target:GetFirst()
		for TrueTarget in aux.Next(g) do
			dem = TrueTarget:GetSequence()
		end	
		local chay = 1 
		Duel.ConfirmDecktop(tp,dcount-dem)
		Duel.SendtoHand(TrueTarget,nil,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		local g=Duel.GetDecktopGroup(tp,dcount-dem-1)
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)	
		end

		local tc2=g:GetNext()
		if ban == 2 and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT) and Duel.Remove(tc2,POS_FACEDOWN,REASON_EFFECT)	then
		Duel.ShuffleDeck(tp)
		local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local dem = 0
		local target = Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,nil,ac)
		TrueTarget=target:GetFirst()
		for TrueTarget in aux.Next(g) do
			dem = TrueTarget:GetSequence()
		end	
		local chay = 1 
		Duel.ConfirmDecktop(tp,dcount-dem)
		Duel.SendtoHand(TrueTarget,nil,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		local g=Duel.GetDecktopGroup(tp,dcount-dem-1)
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	else --trường hợp ban = 0
		Duel.ShuffleDeck(tp)
		local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local dem = 0
		local TrueTarget = Duel.GetMatchingGroup(s.Indeckfilter,tp,LOCATION_DECK,0,nil,ac)

		for TrueTarget in aux.Next(Indeck) do
			dem = TrueTarget:GetSequence()
		end	
		local chay = 1 
		Duel.ConfirmDecktop(tp,dcount-dem)
		Duel.SendtoHand(TrueTarget,nil,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		local g=Duel.GetDecktopGroup(tp,dcount-dem-1)
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)	
		end
end


