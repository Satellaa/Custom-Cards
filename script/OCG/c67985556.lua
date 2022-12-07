--Readen, Abyss Lord of Dark World
Duel.LoadScript("utopia.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),8,2)
	c:EnableReviveLimit()
	--Cannot be destroyed by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE)
	e3:SetValue(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.incon)
	c:RegisterEffect(e3)
	--Unaffected by your opponent's 
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(3113)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetCondition(s.mgcon)
		e1:SetValue(s.mgfilter2)
		c:RegisterEffect(e1)
    --Draw 1 card, then discard 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Dark World Effect 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(aux.bfgcost)
	e4:SetCondition(s.darcon)
	e4:SetTarget(s.dartg)
	e4:SetOperation(s.darop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	c:RegisterEffect(e5)
	end
	s.listed_series={SET_DARK_WORLD}
	function s.incon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_DARK_WORLD)
end
function s.mgcon(e,tp,eg,ep,ev,re,r,rp)
return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer() and e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_DARK_WORLD)
end
	function s.mgfilter2(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==1 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function s.darconfilter(c,tp)
	return c:IsSetCard(SET_DARK_WORLD) and c:IsType(TYPE_MONSTER) and c:IsHasEffect(id)
	end
    function s.darcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.darconfilter,1,nil,tp)
end
function s.dartg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) end
	if chk==0 then return eg:IsExists(s.darconfilter,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=eg:FilterSelect(tp,s.darconfilter,1,1,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.darop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
		local eff={tc:GetCardEffect(id)}
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(eff) do
			local temp=teh:GetLabelObject()
			local tg=temp:GetTarget()
				if (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
				table.insert(ac,teh)
				table.insert(acd,temp:GetDescription())
			end
		end
		if #ac==1 then te=ac[1] elseif #ac>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			op=Duel.SelectOption(tp,table.unpack(acd))
			op=op+1
			te=ac[op]
		end
		if not te then return end
		Duel.ClearTargetCard()
		local teh=te
		te=teh:GetLabelObject()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		Duel.BreakEffect()
		tc:CreateEffectRelation(te)
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for etc in aux.Next(g) do
			etc:CreateEffectRelation(te)
		end
		if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		tc:ReleaseEffectRelation(te)
		for etc in aux.Next(g) do
			etc:ReleaseEffectRelation(te)
		end
	 end