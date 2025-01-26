if not aux.RitualProcedure then
	aux.RitualProcedure = {}
	Ritual = aux.RitualProcedure
end
if not Ritual then
	Ritual = aux.RitualProcedure
end

EFFECT_EXTRA_RITUAL_LOCATION = 2500000001
EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN = 0x20000000
LOCATION_NOTHAND=LOCATION_DECK|LOCATION_REMOVED|LOCATION_GRAVE

--required functions
local function ExtraReleaseFilter(c,tp)
	return c:IsControler(1-tp) and c:IsHasEffect(EFFECT_EXTRA_RELEASE)
end
local function ForceExtraRelease(mg)
	return function(e,tp,g,c)
		return g:Includes(mg)
	end
end
local function WrapTableReturn(func)
	if func then
		return function(...)
			return {func(...)}
		end
	end
end
local function MergeForcedSelection(f1,f2)
	if f1==nil or f2==nil then
		return f1 or f2
	end
	return function(...)
		local ret1,ret2=f1(...)
		local repl1,repl2=f2(...)
		return ret1 and repl1,ret2 or repl2
	end
end
local function GetExtraLocationEffect(c,rc)
	local effs={c:IsHasEffect(EFFECT_EXTRA_RITUAL_LOCATION)}
	for _,eff in ipairs(effs) do
		local val=eff:GetValue()
		if not val or (type(val)=="function" and val(eff,c,rc)) or val==1 then
			return eff
		end
	end
end
local function ExtraLocationOPTCheck(c,rc,tp)
	local extra_loc_eff=GetExtraLocationEffect(c,rc)
	return extra_loc_eff,extra_loc_eff and not extra_loc_eff:CheckCountLimit(tp)
end
function Ritual.ExtraLocFilter(c,filter,_type,e,tp,m,m2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos,booltype,reqfunc)
	if not (c:IsOriginalType(TYPE_RITUAL) and c:IsOriginalType(TYPE_MONSTER)) or (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,sumpos) then return false end
	local extra_loc_eff,used=ExtraLocationOPTCheck(c,e:GetHandler(),tp)
	if not extra_loc_eff or extra_loc_eff and used then return false end
	if extra_loc_eff:GetProperty()&EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN>0 and Duel.HasFlagEffect(tp,EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN) then return false end
	
	local lv=(lv and (type(lv)=="function" and lv(c)) or lv) or c:GetLevel()
	lv=math.max(1,lv)
	Ritual.SummoningLevel=lv
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2-c)
	if c.ritual_custom_condition then
		return c:ritual_custom_condition(mg,forcedselection,_type)
	end
	if c.mat_filter then
		mg:Match(c.mat_filter,c,tp)
	end
	if specificmatfilter then
		mg:Match(specificmatfilter,nil,c,mg,tp)
	end
	forcedselection=MergeForcedSelection(c.ritual_custom_check,forcedselection)
	local res=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(c,lv,WrapTableReturn(forcedselection),_type,requirementfunc),0)
	Ritual.SummoningLevel=nil
	return res
end
Ritual.Target = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter,requirementfunc,sumpos,extratg)
	location = location or LOCATION_HAND
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
					--add that forcedselection to the one of the Ritual Spell, if any
					local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					local func=forcedselection
					--if a card controlled by the opponent has EFFECT_EXTRA_RELEASE, then it MUST be
					--used as material
					local extra_mat_g=mg:Filter(ExtraReleaseFilter,nil,tp)
					if #extra_mat_g>0 then
						func=MergeForcedSelection(ForceExtraRelease(extra_mat_g),func)
					end
					if #extra_eff_g>0 then
						local prev_repl_function=nil
						for tmp_c in extra_eff_g:Iter() do
							local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
							for _,eff in ipairs(effs) do
								local repl_function=eff:GetLabelObject()
								if repl_function and prev_repl_function~=repl_function[1] then
									prev_repl_function=repl_function[1]
									func=MergeForcedSelection(func,repl_function[1])
								end
							end
						end
					end
					Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
					-- custom ----
					local final_group=Group.CreateGroup()
					local base_ritual_group=Duel.GetMatchingGroup(Ritual.Filter,tp,location,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos)
					local extra_loc_group=Duel.GetMatchingGroup(Ritual.ExtraLocFilter,tp,LOCATION_NOTHAND,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos)
					final_group:Merge(base_ritual_group)
					final_group:Merge(extra_loc_group)
					return #final_group>0
					--------------
				end
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","specificmatfilter","requirementfunc","sumpos","extratg")
Ritual.Operation = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos)
	location = location or LOCATION_HAND
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp) or Group.CreateGroup()
				--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
				--add that forcedselection to the one of the Ritual Spell, if any
				local func=forcedselection
				local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
				if #extra_eff_g>0 then
					local prev_repl_function=nil
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							local repl_function=eff:GetLabelObject()
							if repl_function and prev_repl_function~=repl_function[1] then
								prev_repl_function=repl_function[1]
								func=MergeForcedSelection(func,repl_function[1])
							end
						end
					end
				end
				--if a card controlled by the opponent has EFFECT_EXTRA_RELEASE, then it MUST be
				--used as material
				local extra_mat_g=mg:Filter(ExtraReleaseFilter,nil,tp)
				if #extra_mat_g>0 then
					func=MergeForcedSelection(ForceExtraRelease(extra_mat_g),func)
				end
				Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				-- custom ----
				local tg=Group.CreateGroup()
				local final_group=Group.CreateGroup()
				local base_ritual_group=Duel.GetMatchingGroup(aux.NecroValleyFilter(Ritual.Filter),tp,location,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos)
				local extra_loc_group=Duel.GetMatchingGroup(aux.NecroValleyFilter(Ritual.ExtraLocFilter),tp,LOCATION_NOTHAND,0,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos)
				final_group:Merge(base_ritual_group)
				final_group:Merge(extra_loc_group)
				if #final_group>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					tg=final_group:Select(tp,1,1,nil)
				end
				if #tg>0 then
					local tc=tg:GetFirst()
					local extra_loc_eff=GetExtraLocationEffect(tc,e:GetHandler())
					if extra_loc_eff and extra_loc_eff:CheckCountLimit(tp) then
						local extra_loc=extra_loc_eff:GetTargetRange()
						if extra_loc_eff:GetType()&EFFECT_TYPE_SINGLE>0 or extra_loc and tc:IsLocation(extra_loc) then
							extra_loc_eff:UseCountLimit(tp)
							if extra_loc_eff:GetProperty()&EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN>0 then
								Duel.RegisterFlagEffect(tp,EFFECT_FLAG_GAIN_ONLY_ONE_PER_TURN,RESET_PHASE|PHASE_END,0,1)
							end
						end
					end
				--------
					local lv=(lv and (type(lv)=="function" and lv(tc)) or lv) or tc:GetLevel()
					lv=math.max(1,lv)
					Ritual.SummoningLevel=lv
					local mat=nil
					mg:Match(Card.IsCanBeRitualMaterial,tc,tc)
					mg:Merge(mg2-tc)
					if specificmatfilter then
						mg:Match(specificmatfilter,nil,tc,mg,tp)
					end
					if tc.ritual_custom_operation then
						tc:ritual_custom_operation(mg,func,_type)
						mat=tc:GetMaterial()
					else
						func=MergeForcedSelection(tc.ritual_custom_check,func)
						if tc.mat_filter then
							mg:Match(tc.mat_filter,tc,tp)
						end
						if ft>0 and not func then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							if _type==RITPROC_EQUAL then
								mat=mg:SelectWithSumEqual(tp,requirementfunc or Card.GetRitualLevel,lv,1,#mg,tc)
							else
								mat=mg:SelectWithSumGreater(tp,requirementfunc or Card.GetRitualLevel,lv,tc)
							end
						else
							mat=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(tc,lv,WrapTableReturn(func),_type,requirementfunc),1,tp,HINTMSG_RELEASE,Ritual.Finishcon(tc,lv,WrapTableReturn(func),requirementfunc,_type))
						end
					end
					--check if a card from an "once per turn" EFFECT_EXTRA_RITUAL_MATERIAL effect was selected
					local extra_eff_g=mat:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							--if eff is OPT and tmp_c is not returned
							--by the Ritual Spell's exrafil
							--then use the count limit and register
							--the flag to turn the extra eff OFF
							--requires the EFFECT_EXTRA_RITUAL_MATERIAL effect
							--to check the flag in its condition
							local _,max_count_limit=eff:GetCountLimit()
							if max_count_limit>0 and not mg2:IsContains(tmp_c) then
								eff:UseCountLimit(tp,1)
								Duel.RegisterFlagEffect(tp,eff:GetHandler():GetCode(),RESET_PHASE+PHASE_END,0,1)
							end
						end
					end
					if not customoperation then
						tc:SetMaterial(mat)
						if extraop then
							extraop(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
						else
							Duel.ReleaseRitualMaterial(mat)
						end
						Duel.BreakEffect()
						Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,sumpos)
						tc:CompleteProcedure()
						if tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
						if stage2 then
							stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
						end
					else
						customoperation(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
					end
					Ritual.SummoningLevel=nil
				end
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos")