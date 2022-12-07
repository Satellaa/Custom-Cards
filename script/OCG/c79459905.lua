--Crimson Prince Vampire William
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	--Send all monsters your opponent controls without level 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.nolvcost)
	e1:SetTarget(s.nolvtg)
	e1:SetOperation(s.nolvop)
	c:RegisterEffect(e1,false, REGISTER_FLAG_DETACH_XMAT)
  --Use as Xyz material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2 :SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	--Targeted for opponent's card effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCondition(s.vampcon)
	e3:SetTarget(s.vamptg)
	e3:SetOperation(s.vampop)
	c:RegisterEffect(e3)
	--be target for an attack 
	local e4=e3:Clone()
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCondition(s.vampcon2)
	c:RegisterEffect(e4)
	end
	s.listed_series={SET_VAMPIRE}
function s.lvlfilter(c)
	return c:IsFaceup() and not c:HasLevel()
end
function s.nolvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.nolvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.lvlfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and g:FilterCount(Card.IsAbleToGrave,nil)==#g end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,#g,1,tp,LOCATION_MZONE)
end
function s.nolvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.lvlfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsCanBeXyzMaterial() and not c:IsHasEffect(EFFECT_XYZ_MATERIAL)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.xyzfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_XYZ_MATERIAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.vampcon(e,tp,eg,ep,ev,re,r,rp) 
	return eg:IsContains(e:GetHandler()) and e:GetHandler():GetOverlayCount()==0
end
function s.vampcon2(e,tp,eg,ep,ev,re,r,rp) 
	return e:GetHandler():GetOverlayCount()==0
end
function s.vamplter(c,e,tp,mc,pg)
	return c:IsSetCard(SET_VAMPIRE) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c,tp) and (#pg<=0 or pg:IsContains(mc)) 
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,true)
	end
function s.vamptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return #pg<=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 
			and Duel.IsExistingMatchingCard(s.vamplter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,pg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.vampop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.vamplter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,pg)
	local sc=g:GetFirst()
	if sc then
		local mg=c:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(c))
		Duel.Overlay(sc,Group.FromCards(c))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,true,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
