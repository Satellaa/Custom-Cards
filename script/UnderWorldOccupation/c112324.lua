--Copsop
local s,id=GetID()
local s,id=GetID()
function s.initial_effect(c) --Khai báo eff
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e2)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.spcon)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCost(s.retcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)

	--tự hủy
	local e3=Effect.CreateEffect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_TOGRAVE)
	e3:SetCondition(s.tgcond)
	c:RegisterEffect(e3)
end


function s.gfilter(c,tp)
	return (c:GetPreviousLocation()==LOCATION_HAND 
	or c:GetPreviousLocation()==LOCATION_MZONE
	or c:GetPreviousLocation()==LOCATION_EXTRA
	or c:GetPreviousLocation()==LOCATION_SZONE
	or c:GetPreviousLocation()==LOCATION_PZONE
	or c:GetPreviousLocation()==LOCATION_BANISHED_ZONE
	or c:GetPreviousLocation()==LOCATION_GRAVE)
	and (c:GetLocation()==LOCATION_DECK)
	and c:IsLevelBelow(3)

-- check card di chuyển tơi các vị trí và xem card đó có level là bao nhiêu
end


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1
-- Đếm số lượng?
end 

function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end


function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end	
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local val=300 --set giá trị atk tăng
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end

	--check quái, LP và thực hiện theo eff
	if Duel.GetLP(tp)<=1000 then
	local g=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_DECK,LOCATION_DECK,nil)
	local tc=g:GetFirst()
	local val=0
	val=tc:GetLevel()
	val = val*300
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(val)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,400)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
	end
end


-- set param tức set lượng LP, giữ nguyên mẫu để tăng LP
-- check có quái non fiend hoặc lv4 or higher
function s.sdesfilter(c) --sdes stand for self destroy
	return c:IsFaceup() and (c:IsLevelAbove(4) or not c:IsRace(RACE_FIEND)) --RACE + tộc, not tộc + race =))
end


function s.tgcond(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.sdesfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
	return #g > 0
end

--Duel.GetMatchingGroupCount(f, player, s, o, ex, ...)
 --Duel.GetMatchingGroupCount(s.sdesfilter,0,... 0 tức người điều khiển, thường là tp, nhung chắc bị trùng hay gì đó
 --done