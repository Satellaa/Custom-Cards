--Blue-Eyes Radiant Dragon
local s,id=GetID()
function s.initial_effect(c)
  --Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,8,2,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)
	--how it's going to be revived
	c:EnableReviveLimit()
	--Check if Summoned this Way
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	--This cards original Atk become its material atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--Card Effect indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--copy effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetCost(aux.dxmcostgen(1,1,nil))
	e4:SetTarget(s.cptg)
	e4:SetOperation(s.cpop)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_BLUE_EYES}
s.listed_names={CARD_BLUEEYES_W_DRAGON}

 function s.ovfilter(c,tp,xyzc)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsSetCard(SET_BLUE_EYES,xyzc,SUMMON_TYPE_XYZ,tp)
	       and c:IsMonster(xyzc,SUMMON_TYPE_XYZ,tp) and c:GetSummonLocation(xyzc,SUMMON_TYPE_XYZ,tp)==LOCATION_EXTRA and not c:IsCode(id)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	return true
end
function s.valcheck(e,c)
local g=c:GetMaterial()
	local atk=0
	local def=0
	local tc=g:GetFirst()
		atk=tc:GetTextAttack()
		def=tc:GetTextDefense()
	e:SetLabel(atk,def)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and c:GetFlagEffect(id)~=0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk,def=e:GetLabelObject():GetLabel()
	if atk>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_TOFIELD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end
function s.copfilter(c)
    return c:IsAbleToRemoveAsCost() and c:ListsCode(CARD_BLUEEYES_W_DRAGON)
         and c:IsSpellTrap()and c:CheckActivateEffect(true,true,false)~=nil 
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        local te=e:GetLabelObject()
        return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
    end
    if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
    tc=g:GetFirst()
    local te=g:GetFirst():CheckActivateEffect(true,true,false)
    e:SetLabel(te:GetLabel())
    e:SetLabelObject(te:GetLabelObject())
    local tg=te:GetTarget()
    if tg then
        tg(e,tp,eg,ep,ev,re,r,rp,1)
    end
    te:SetLabel(e:GetLabel())
    te:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(te)
    Duel.ClearOperationInfo(0)
    Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_COST)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
    if te then
        e:SetLabel(te:GetLabel())
        e:SetLabelObject(te:GetLabelObject())
        local op=te:GetOperation()
        if op then op(e,tp,eg,ep,ev,re,r,rp) end
        te:SetLabel(e:GetLabel())
        te:SetLabelObject(e:GetLabelObject())
    end
end