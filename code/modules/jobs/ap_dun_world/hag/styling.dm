/proc/ap_perform_mirror_styling(mob/living/user, mob/living/carbon/human/H, atom/source)
	var/list/options = list("hairstyle", "facial hairstyle")
	var/chosen = input(user, "What would you like to style?", "Hair Styling") as null|anything in options
	if(!chosen)
		return

	switch(chosen)
		if("hairstyle")
			var/datum/customizer_choice/bodypart_feature/hair/head/humanoid/hair_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/head/humanoid)
			var/list/valid_hairstyles = list()
			for(var/hair_type in hair_choice.sprite_accessories)
				var/datum/sprite_accessory/hair/head/hair = new hair_type()
				valid_hairstyles[hair.name] = hair_type

			var/new_style = input(user, "Choose their hairstyle", "Hair Styling") as null|anything in valid_hairstyles
			if(!new_style)
				return

			user.visible_message(
				span_notice("[user] begins styling [H]'s hair..."),
				span_notice("You begin styling [H == user ? "your" : "[H]'s"] hair...")
			)

			if(!do_after(user, 30 SECONDS, target = H))
				to_chat(user, span_warning("The styling was interrupted!"))
				return

			var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
			if(!head || !head.bodypart_features)
				return

			var/datum/bodypart_feature/hair/head/current_hair = null
			for(var/datum/bodypart_feature/hair/head/hair_feature in head.bodypart_features)
				current_hair = hair_feature
				break
			if(!current_hair)
				return

			var/datum/customizer_entry/hair/hair_entry = new()
			hair_entry.hair_color = current_hair.hair_color

			// Preserve gradients and their colors.
			hair_entry.natural_gradient = current_hair.natural_gradient
			hair_entry.natural_color = current_hair.natural_color

			if(hasvar(current_hair, "hair_dye_gradient"))
				hair_entry.dye_gradient = current_hair.hair_dye_gradient
			if(hasvar(current_hair, "hair_dye_color"))
				hair_entry.dye_color = current_hair.hair_dye_color

			var/datum/bodypart_feature/hair/head/new_hair = new()
			new_hair.set_accessory_type(valid_hairstyles[new_style], hair_entry.hair_color, H)
			hair_choice.customize_feature(new_hair, H, null, hair_entry)

			head.remove_bodypart_feature(current_hair)
			head.add_bodypart_feature(new_hair)
			H.update_hair()

			playsound(source, 'sound/items/flint.ogg', 50, TRUE)
			user.visible_message(
				span_notice("[user] finishes styling [H]'s hair."),
				span_notice("You finish styling [H == user ? "your" : "[H]'s"] hair.")
			)

		if("facial hairstyle")
			if(H.gender != MALE)
				to_chat(user, span_warning("[H == user ? "You don't" : "They don't"] have facial hair to style!"))
				return

			var/datum/customizer_choice/bodypart_feature/hair/facial/humanoid/facial_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/hair/facial/humanoid)
			var/list/valid_facial_hairstyles = list()
			for(var/facial_type in facial_choice.sprite_accessories)
				var/datum/sprite_accessory/hair/facial/facial = new facial_type()
				valid_facial_hairstyles[facial.name] = facial_type

			var/new_style = input(user, "Choose their facial hairstyle", "Hair Styling") as null|anything in valid_facial_hairstyles
			if(!new_style)
				return

			user.visible_message(
				span_notice("[user] begins styling [H]'s facial hair..."),
				span_notice("You begin styling [H == user ? "your" : "[H]'s"] facial hair...")
			)
			if(!do_after(user, 60 SECONDS, target = H))
				to_chat(user, span_warning("The styling was interrupted!"))
				return

			var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
			if(!head || !head.bodypart_features)
				return

			var/datum/bodypart_feature/hair/facial/current_facial = null
			for(var/datum/bodypart_feature/hair/facial/facial_feature in head.bodypart_features)
				current_facial = facial_feature
				break
			if(!current_facial)
				return

			var/datum/customizer_entry/hair/facial/facial_entry = new()
			facial_entry.hair_color = current_facial.hair_color
			facial_entry.accessory_type = current_facial.accessory_type

			var/datum/bodypart_feature/hair/facial/new_facial = new()
			new_facial.set_accessory_type(valid_facial_hairstyles[new_style], facial_entry.hair_color, H)
			facial_choice.customize_feature(new_facial, H, null, facial_entry)

			head.remove_bodypart_feature(current_facial)
			head.add_bodypart_feature(new_facial)
			H.update_hair()

			playsound(source, 'sound/items/flint.ogg', 50, TRUE)
			user.visible_message(
				span_notice("[user] finishes styling [H]'s facial hair."),
				span_notice("You finish styling [H == user ? "your" : "[H]'s"] facial hair.")
			)
	return TRUE
