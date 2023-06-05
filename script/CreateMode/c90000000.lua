local MoveMzone = {
function(c,p)
	return c:IsType(TYPE_MONSTER) and (Duel.GetLocationCount(p,LOCATION_MZONE)>0
			or (c:IsType(TYPE_EXTRA|TYPE_PENDULUM) and (Duel.CheckLocation(p,LOCATION_MZONE,5) or Duel.CheckLocation(p,LOCATION_MZONE,6))))
end,
function(c,p)
	local zone=c:IsType(TYPE_EXTRA|TYPE_PENDULUM) and 0x7f or 0xff
	Duel.MoveToField(c,0,p,LOCATION_MZONE,POS_FACEUP|POS_FACEDOWN,true,zone)
	c:CompleteProcedure()
	if c:IsType(TYPE_XYZ) then
		local ccount=0
		while ccount<5 and Duel.SelectYesNo(0,2214) do
			local ac=Duel.AnnounceCard(0,{OPCODE_ALLOW_ALIASES})
			local mat=Duel.CreateToken(p,ac)
			Duel.Remove(mat,POS_FACEUP,REASON_RULE)
			Duel.Overlay(c,mat)
			ccount=ccount+1
		end
	end
	if c:IsType(TYPE_GEMINI) and c:IsFaceup() and Duel.SelectYesNo(0,2213) then
		c:EnableGeminiState()
	end	
end,
2201
}

local MovePzone = {
function(c,p)
	return c:IsType(TYPE_PENDULUM) and (Duel.CheckLocation(p,LOCATION_PZONE,0) or Duel.CheckLocation(p,LOCATION_PZONE,1))
end,
function(c,p)
	Duel.MoveToField(c,0,p,LOCATION_PZONE,POS_FACEUP,false)
end,
2203
}

local MoveHand = {
function(c,p)
	return not (c:IsType(TYPE_EXTRA) and c:IsType(TYPE_MONSTER))
end,
function(c,p)
	Duel.SendtoHand(c,p,REASON_RULE)
end,
2206
}

local MoveDeck = {
function(c,p)
	return not (c:IsType(TYPE_EXTRA) and c:IsType(TYPE_MONSTER))
end,
function(c,p)
	local pos=Duel.SelectPosition(0,c,POS_ATTACK)
	Duel.SendtoDeck(c,p,0,REASON_RULE)
	if (pos&POS_FACEUP~=0) then
		Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
		c:ReverseInDeck()
	end
end,
2207
}

local MoveExtra = {
function(c,p)
	return (c:IsType(TYPE_EXTRA) and c:IsType(TYPE_MONSTER)) or c:IsType(TYPE_PENDULUM)
end,
function(c,p)
	local pos=POS_FACEDOWN
	if c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_EXTRA) then
		pos=Duel.SelectPosition(0,c,POS_ATTACK)
	elseif c:IsType(TYPE_PENDULUM) then
		pos=POS_FACEUP
	end
	if (pos&POS_FACEUP~=0) then Duel.SendtoExtraP(c,p,REASON_RULE) else Duel.SendtoHand(c,p,REASON_RULE) end
end,
2208
}

local MoveGrave = {
function(c,p)
	return true
end,
function(c,p)
	Duel.SendtoGrave(c,REASON_RULE,p)
end,
2205
}

local MoveBanished = {
function(c,p)
	return true
end,
function(c,p)
	Duel.Remove(c,Duel.SelectPosition(0,c,POS_ATTACK),REASON_RULE,p)
end,
2209
}

local function EquipCheck(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
local function UnionCheck(c,ec)
	return c:IsFaceup() and ec:CheckUnionTarget(c)
end
local MoveSzone = {
function(c,p)
	return c:IsType(TYPE_FIELD) or (Duel.GetLocationCount(p,LOCATION_SZONE)>0 and (c:IsType(TYPE_SPELL|TYPE_TRAP) or
			(c:IsType(TYPE_UNION) and Duel.IsExistingMatchingCard(UnionCheck,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c))))
end,
function(c,p)
	if c:IsType(TYPE_UNION) then
		Duel.Hint(HINT_SELECTMSG,0,HINTMSG_FACEUP)
		Duel.MoveToField(c,0,p,LOCATION_SZONE,POS_FACEUP,true)
		local tc=Duel.SelectMatchingCard(0,UnionCheck,0,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c):GetFirst()
		if Duel.Equip(p,c,tc) then
			aux.SetUnionState(c)
		end
	else
		if c:IsType(TYPE_FIELD) or c:IsType(TYPE_CONTINUOUS) then
			local loc=LOCATION_SZONE
			if c:IsType(TYPE_FIELD) then loc=LOCATION_FZONE end
			Duel.MoveToField(c,0,p,loc,Duel.SelectPosition(0,c,POS_ATTACK),true)
		elseif c:IsType(TYPE_EQUIP) and Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE):IsExists(Card.CheckUniqueOnField,1,nil,p) then
			if Duel.IsExistingTarget(EquipCheck,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,c) and Duel.SelectYesNo(0,2216) then
				Duel.MoveToField(c,0,p,LOCATION_SZONE,POS_FACEUP,true)
				local eq=Duel.SelectMatchingCard(0,EquipCheck,0,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c):GetFirst()
				Duel.Equip(p,c,eq)
			else
				Duel.MoveToField(c,0,p,LOCATION_SZONE,POS_FACEDOWN,true)
			end
		else
			Duel.MoveToField(c,0,p,LOCATION_SZONE,POS_FACEDOWN,true)
		end
	end
end,
2202
}

local function CheckOperation(op,c,p,ops,opts)
	if op[1](c,p) then
		table.insert(ops,op[2])
		table.insert(opts,op[3])
	end
end

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(LOCATION_ALL)
	e1:SetOperation(s.registercreatemode)
	c:RegisterEffect(e1)
end
function s.registercreatemode(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(_,tp) return aux.CanActivateSkill(tp) end)
	e1:SetOperation(s.CreateOrRemove)
	Duel.RegisterEffect(e1,tp)
	Duel.DisableShuffleCheck(true)
	Duel.RemoveCards(c)
	if c:IsPreviousLocation(LOCATION_HAND) then
		Duel.Draw(tp,1,REASON_RULE)
	end
	e:Reset()
end
function s.CreateOrRemove(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	if op==0 then
		while Duel.SelectYesNo(tp,2200) do
			local ac=Duel.AnnounceCard(tp,{OPCODE_ALLOW_ALIASES})
			if Duel.SelectYesNo(tp,2210) then p=tp else p=1-tp end
			local c=Duel.CreateToken(p,ac)
			local ops={}
			local opts={}
			CheckOperation(MovePzone,c,p,ops,opts)
			CheckOperation(MoveSzone,c,p,ops,opts)
			CheckOperation(MoveMzone,c,p,ops,opts)
			CheckOperation(MoveGrave,c,p,ops,opts)
			CheckOperation(MoveHand,c,p,ops,opts)
			CheckOperation(MoveDeck,c,p,ops,opts)
			CheckOperation(MoveExtra,c,p,ops,opts)
			CheckOperation(MoveBanished,c,p,ops,opts)
			ops[Duel.SelectOption(tp,false,table.unpack(opts))+1](c,p)
			Duel.AdjustInstantly()
		end
	else
		while Duel.SelectYesNo(tp,aux.Stringid(id,2)) do
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			local rg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ALL,LOCATION_ALL,1,99,nil)
			Duel.DisableShuffleCheck(true)
			Duel.RemoveCards(rg)
			Duel.AdjustInstantly()
		end
	end
end