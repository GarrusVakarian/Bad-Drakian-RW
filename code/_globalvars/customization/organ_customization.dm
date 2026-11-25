GLOBAL_LIST_INIT(named_penis_sizes, list(
	"Tiny" = MIN_PENIS_SIZE,
	"Small" = SMALL_PENIS_SIZE,
	"Average" = DEFAULT_PENIS_SIZE,
	"Large" = MAX_PENIS_SIZE,
))

GLOBAL_LIST_INIT(named_ball_sizes, list(
	"Small" = 1,
	"Average" = 2,
	"Large" = 3,
))

GLOBAL_LIST_INIT(named_breast_sizes, list(
	"Flat" = 0,
	"Very Small" = 1,
	"Small" = 2,
	"Normal" = DEFAULT_BREASTS_SIZE,
	"Large" = LARGE_BREASTS_SIZE,
	"Enormous" = 5,
	"Towering" = 6,
	"Huge" = 7,
	"Gargantuan" = 8,
	"Colossal" = OBSCENE_BREASTS_SIZE,
	"Ungodly big" = 10,
	"Gigantic" = 11,
	"Titanic" = MAX_STANDARD_BREASTS_SIZE,
	"Extra Baothan" = MIN_OCHRE_BREASTS_SIZE,
	"Over-Baothan" = 18,
	"Downright Incredible" = MAX_BREASTS_SIZE,
))

/proc/is_valid_breast_size(size)
	return isnum(size) && round(size) == size && ((size >= MIN_BREASTS_SIZE && size <= MAX_STANDARD_BREASTS_SIZE) || (size >= MIN_OCHRE_BREASTS_SIZE && size <= MAX_BREASTS_SIZE))

/proc/get_breast_size_options(accessory_type)
	var/datum/sprite_accessory/breasts/style = SPRITE_ACCESSORY(accessory_type)
	var/max_size = style ? style.max_size : MAX_STANDARD_BREASTS_SIZE
	var/list/options = list()
	for(var/label in GLOB.named_breast_sizes)
		var/size = GLOB.named_breast_sizes[label]
		if(size <= max_size)
			options[label] = size
	return options

GLOBAL_LIST_INIT(customizer_choices, build_customizer_choices())
GLOBAL_LIST_INIT(customizers, build_customizers())

/proc/build_customizer_choices()
	. = list()
	for(var/type in typesof(/datum/customizer_choice))
		if(is_abstract(type))
			continue
		.[type] = new type()
	return .

/proc/build_customizers()
	. = list()
	for(var/type in typesof(/datum/customizer))
		if(is_abstract(type))
			continue
		.[type] = new type()
	return .

/proc/color_pick_sanitized(mob/user, description, title, default_value, min_tag = 0.07, max_tag = 1)
	var/color = input(user, description, title, default_value) as color|null
	var/good = TRUE
	if(!color)
		return
	color = sanitize_hexcolor(color)
	var/list/hsl = rgb2hsl(hex2num(copytext(color,1,3)),hex2num(copytext(color,3,5)),hex2num(copytext(color,5,7)))
	if(hsl[3] < min_tag)
		to_chat(user, span_warning("The picked color is too dark! Raising Luminosity to minimum [min_tag * 100]%."))
		hsl[3] = min_tag
		good = FALSE
	if(hsl[2] > max_tag)
		to_chat(user, span_warning("The picked color is too bright! Lowering Saturation to maximum 100%."))
		hsl[2] = max_tag
		good = FALSE
	if(!good)
		var/list/rgb = hsl2rgb(arglist(hsl))
		color = sanitize_hexcolor("[num2hex(rgb[1])][num2hex(rgb[2])][num2hex(rgb[3])]")

	return color
