/// Customizer entry representing a saved/loaded information about a /datum/customizer_choice and its related information.
/datum/customizer_entry
	/// Used for identification.
	var/customizer_type
	var/customizer_choice_type
	var/accessory_type
	var/accessory_colors
	var/disabled = FALSE

	/// Consolidated controls keep the original entries, including inactive styles/settings.
	/// Stored on the first entry in the group; null retains legacy selection precedence.
	var/group_selected_customizer
	var/group_disabled = FALSE
