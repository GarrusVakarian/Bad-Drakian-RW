/datum/brewing_recipe/liquor
	name = "Gin"
	category = "Liquor"
	bottle_name = "gin"
	bottle_desc = "A bottle of locally-distilled gin. Has a strong, piney flavor."
	reagent_to_brew = /datum/reagent/consumable/ethanol/gin
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/gin
	pre_reqs = /datum/reagent/consumable/ethanol/voddena
	needed_items = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue = 2)
	brewed_amount = 4
	brew_time = 5 MINUTES
	sell_value = 100
	heat_required = 370

/datum/brewing_recipe/liquor/ricespirit
	name = "Rice Spirit"
	bottle_name = "rice spirit"
	bottle_desc = "A bottle of locally-distilled rice spirit. Has a clean flavor and a dry finish."
	reagent_to_brew = /datum/reagent/consumable/ethanol/ricespirit
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/ricespirit
	pre_reqs = /datum/reagent/consumable/ethanol/ricewine
	needed_items = null
	brewed_amount = 4
	sell_value = 90

/datum/brewing_recipe/liquor/rosegoldgin
	name = "Rose Gold Gin"
	bottle_name = "rose gold gin"
	bottle_desc = "A bottle of locally-distilled rose gold gin. Has a floral, citrus, and sweet flavour."
	reagent_to_brew = /datum/reagent/consumable/ethanol/rosegoldgin
	output_bottle_type = /obj/item/reagent_containers/glass/bottle/brewing_bottle/rosegoldgin
	pre_reqs = /datum/reagent/consumable/ethanol/voddena
	needed_items = list(
		/obj/item/reagent_containers/food/snacks/rogue/honey = 1,
		/obj/item/reagent_containers/food/snacks/grown/fruit/lemon = 1,
		/obj/item/reagent_containers/food/snacks/grown/fruit/lime = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/rosa_petals = 1,
	)
	brewed_amount = 6
	brew_time = 5 MINUTES
	sell_value = 90
	heat_required = 370

