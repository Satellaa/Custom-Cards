--Maiden Sacrifice To The Eyes of Blue 
local s,id=GetID()
function s.initial_effect(c)
	--Activate
  local e1= Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_EQUIP)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Special Summon 1 "Blue-eyes White Dragon" from hand , deck or gy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BLUE_EYES} 
s.listed_names={CARD_BLUEEYES_W_DRAGON}

 function s.filter(c,e,tp)
	return c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.matfilter(c)
	return c:IsCanBeFusionMaterial() and ((c:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and c:IsAbleToRemoveAsCost()) or (not c:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) 
	   and c:IsAbleToGraveAsCost()))
end
function s.rescon(c)
	return function(sg,e,tp,mg)
		return c:CheckFusionMaterial(sg) and Duel.GetMZoneCount(tp,sg)>0
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp) and (c:IsLocation(LOCATION_HAND) 
	    and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
end
function s.fusfilter(c,e,tp,tc)
	local fmat=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,tc)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false) 
	     and aux.SelectUnselectGroup(fmat,e,tp,c.min_material_count,c.max_material_count,s.rescon(c),0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local all_locs=LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc) or Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	local fmat=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,tc)
	local fc=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc):GetFirst()
	local mat=aux.SelectUnselectGroup(fmat,e,tp,fc.min_material_count,fc.max_material_count,s.rescon(fc),1,tp)
	local gmat,hfmat=mat:Split(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_MZONE)
	Duel.SendtoGrave(hfmat,REASON_COST)
	Duel.Remove(gmat,nil,REASON_COST)
	Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
	fc:SetMaterial(mat)
	fc:CompleteProcedure()
	mat:DeleteGroup()
	hfmat:DeleteGroup()
	gmat:DeleteGroup()
	if Duel.Equip(tp,tc,fc) then
	  tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		--Equip limit
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(fc)
		tc:RegisterEffect(e1)
   	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetLabelObject(tc)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	fc:RegisterEffect(e3)
			end
	end
	function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local tc=e:GetLabelObject()
	local c=e:GetHandler()
	if chk==0 then return not tc:IsStatus(STATUS_DESTROY_CONFIRMED) and tc and tc:GetEquipTarget() and tc:IsDestructable(e) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return true 
	 else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
  local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end