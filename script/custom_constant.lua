--Customconstant
SET_AZURIST                        = 0xf16
CARD_THE_AZURE_PROJECT          = 2100000027

function Auxiliary.BitSplit(v)
	local res={}
	local i=0
	while 2^i<=v do
		local p=2^i
		if v & p~=0 then
			table.insert(res,p)
		end
		i=i+1
	end
	return pairs(res)
end

function Auxiliary.GetTypeStrings(v)
	local t = {
		[TYPE_RITUAL] = 1057,
        [TYPE_FUSION] = 1056,
		[TYPE_SYNCHRO] = 1063,
		[TYPE_XYZ] = 1073,
		[TYPE_LINK] = 1076
	}
	local res={}
	local ct=0
	for _,type in Auxiliary.BitSplit(v) do
		if t[type] then
			table.insert(res,t[type])
			ct=ct+1
		end
	end
	return pairs(res)
end

-- This function takes a card or a group of cards, a card type and two locations and returns a group of cards in the adjacent column of the card or the cards
-- c_or_group: the card or the group of cards to get adjacent cards for
-- cardtype: the type of the cards to get (default TYPE_MONSTER)
-- loc1: the location of the cards on the same side as the card or the cards (default LOCATION_MZONE)
-- loc2: the location of the cards on the opposite side as the card or the cards (default LOCATION_MZONE)
function Auxiliary.GetAdjacent(c_or_group,cardtype,loc1,loc2)
  local result = Group.CreateGroup()
  cardtype = cardtype or TYPE_MONSTER
  loc1 = loc1 or LOCATION_MZONE
  loc2 = loc2 or LOCATION_MZONE
  local cards = Duel.GetMatchingGroup(Card.IsType,c_or_group:GetControler(),loc1,loc2,nil,cardtype)
  if type(c_or_group)=="Group" then
    for tc in aux.Next(c_or_group) do
      local seq = tc:GetSequence()
      for m in aux.Next(cards) do
        local mseq = m:GetSequence()
        if (seq - mseq) == 1 or (seq - mseq) == -1 or (seq == 0 and mseq == 5) or (seq == 4 and mseq == -1) then
          result:AddCard(m)
        end
      end
    end
    return result
  else
    local seq = c_or_group:GetSequence()
    for m in aux.Next(cards) do
      local mseq = m:GetSequence()
      if (seq - mseq) == 1 or (seq - mseq) == -1 or (seq == 0 and mseq == 5) or (seq == 4 and mseq == -1) then
        result:AddCard(m)
      end
    end
    return result
  end  
end

local Azurist={}
function Azurist.registerflag(id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,0,1,3399)
	end
end
function Azurist.resetflag(id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():ResetFlagEffect(id)
	end
end
function Azurist.matlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_SPELLCASTER)
end
function Auxiliary.CreateAzuristRestriction(c,id)
	-- Cannot be material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(Azurist.registerflag(id))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)>0 end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local ep1=Effect.CreateEffect(c)
	ep1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ep1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ep1:SetCode(EVENT_CUSTOM+id)
	ep1:SetRange(LOCATION_MZONE)
	ep1:SetCondition(function(e) return e:GetHandler():GetFlagEffect(CARD_THE_AZURE_PROJECT)>0 end)
	ep1:SetOperation(Azurist.resetflag(id))
	c:RegisterEffect(ep1)
	local ep2=Effect.CreateEffect(c)
	ep2:SetType(EFFECT_TYPE_SINGLE)
	ep2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ep2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	ep2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(CARD_THE_AZURE_PROJECT)>0 end)
	ep2:SetValue(Azurist.matlimit)
	c:RegisterEffect(ep2)
	return e1 and e2 and ep1 and ep2
end